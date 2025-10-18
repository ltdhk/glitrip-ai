/**
 * JWT Authentication Middleware
 *
 * 验证请求中的JWT Token，并将用户信息附加到请求对象
 */

import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth/auth.service';
import { ErrorCode, HttpStatus } from '../config/constants';
import { createErrorResponse } from '../models';

/**
 * 扩展Request接口，添加用户信息
 */
export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
  };
}

const authService = new AuthService();

/**
 * JWT认证中间件
 */
export const authenticateUser = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
      res
        .status(HttpStatus.UNAUTHORIZED)
        .json(createErrorResponse(ErrorCode.UNAUTHORIZED, '未提供认证令牌'));
      return;
    }

    const token = authHeader.substring(7);

    // 验证JWT Token
    const decoded = authService.verifyToken(token);

    // 将用户信息附加到请求
    req.user = {
      id: decoded.userId,
      email: decoded.email,
    };

    next();
  } catch (error: any) {
    const isExpired = error.message === ErrorCode.TOKEN_EXPIRED;

    res
      .status(HttpStatus.UNAUTHORIZED)
      .json(
        createErrorResponse(
          isExpired ? ErrorCode.TOKEN_EXPIRED : ErrorCode.INVALID_TOKEN,
          isExpired ? '令牌已过期，请重新登录' : '无效的认证令牌'
        )
      );
  }
};

/**
 * 可选认证中间件（Token可选，不强制要求）
 */
export const optionalAuth = async (
  req: AuthRequest,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader?.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const decoded = authService.verifyToken(token);
      req.user = {
        id: decoded.userId,
        email: decoded.email,
      };
    }

    next();
  } catch (error) {
    // Token无效也继续，不阻止请求
    next();
  }
};
