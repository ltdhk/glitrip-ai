/**
 * Global Error Handler Middleware
 *
 * 统一处理所有错误，返回标准化的错误响应
 */

import { Request, Response, NextFunction } from 'express';
import { ErrorCode, HttpStatus } from '../config/constants';
import { createErrorResponse } from '../models';

/**
 * 错误码到HTTP状态码的映射
 */
const ERROR_CODE_TO_HTTP_STATUS: Record<string, number> = {
  // 认证错误
  [ErrorCode.UNAUTHORIZED]: HttpStatus.UNAUTHORIZED,
  [ErrorCode.INVALID_TOKEN]: HttpStatus.UNAUTHORIZED,
  [ErrorCode.TOKEN_EXPIRED]: HttpStatus.UNAUTHORIZED,

  // 用户错误
  [ErrorCode.USER_NOT_FOUND]: HttpStatus.NOT_FOUND,
  [ErrorCode.USER_ALREADY_EXISTS]: HttpStatus.CONFLICT,
  [ErrorCode.INVALID_CREDENTIALS]: HttpStatus.UNAUTHORIZED,

  // 配额错误
  [ErrorCode.QUOTA_EXCEEDED]: HttpStatus.FORBIDDEN,

  // AI错误
  [ErrorCode.AI_GENERATION_FAILED]: HttpStatus.INTERNAL_SERVER_ERROR,
  [ErrorCode.INVALID_INPUT]: HttpStatus.BAD_REQUEST,

  // 系统错误
  [ErrorCode.INTERNAL_ERROR]: HttpStatus.INTERNAL_SERVER_ERROR,
  [ErrorCode.DATABASE_ERROR]: HttpStatus.INTERNAL_SERVER_ERROR,
  [ErrorCode.VALIDATION_ERROR]: HttpStatus.BAD_REQUEST,
};

/**
 * 全局错误处理中间件
 */
export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // 记录错误日志
  console.error('Error occurred:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    timestamp: new Date().toISOString(),
  });

  // 确定HTTP状态码
  const statusCode =
    ERROR_CODE_TO_HTTP_STATUS[err.message] ||
    HttpStatus.INTERNAL_SERVER_ERROR;

  // 确定错误码
  const errorCode =
    Object.values(ErrorCode).includes(err.message)
      ? err.message
      : ErrorCode.INTERNAL_ERROR;

  // 确定错误消息
  let message = err.message;
  if (statusCode === HttpStatus.INTERNAL_SERVER_ERROR && errorCode === ErrorCode.INTERNAL_ERROR) {
    message = '服务器内部错误，请稍后重试';
  }

  // 返回错误响应
  res.status(statusCode).json(createErrorResponse(errorCode, message, err.details));
};

/**
 * 404 Not Found 处理
 */
export const notFoundHandler = (req: Request, res: Response) => {
  res
    .status(HttpStatus.NOT_FOUND)
    .json(
      createErrorResponse(
        'NOT_FOUND',
        `路径 ${req.method} ${req.path} 不存在`
      )
    );
};
