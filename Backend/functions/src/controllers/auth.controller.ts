/**
 * Authentication Controller
 *
 * 处理认证相关的HTTP请求
 */

import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth/auth.service';
import { createSuccessResponse } from '../models';
import { HttpStatus, ErrorCode } from '../config/constants';
import { AuthRequest } from '../middleware/auth.middleware';

export class AuthController {
  private authService: AuthService;

  constructor() {
    this.authService = new AuthService();
  }

  /**
   * 用户注册
   * POST /api/v1/auth/register
   */
  register = async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const { email, password, display_name } = req.body;

      const result = await this.authService.register({
        email,
        password,
        display_name,
      });

      res
        .status(HttpStatus.CREATED)
        .json(createSuccessResponse(result, '注册成功'));
    } catch (error: any) {
      next(error);
    }
  };

  /**
   * 用户登录
   * POST /api/v1/auth/login
   */
  login = async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const { email, password } = req.body;

      const result = await this.authService.login({ email, password });

      res.json(createSuccessResponse(result, '登录成功'));
    } catch (error: any) {
      next(error);
    }
  };

  /**
   * 获取当前用户信息
   * GET /api/v1/auth/me
   */
  me = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      // 通过Token获取用户完整信息
      const authHeader = req.headers.authorization!;
      const token = authHeader.substring(7);
      const user = await this.authService.getUserByToken(token);

      res.json(createSuccessResponse(user));
    } catch (error: any) {
      next(error);
    }
  };

  /**
   * 刷新Token（可选功能）
   * POST /api/v1/auth/refresh
   */
  refreshToken = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const userId = req.user!.id;
      const email = req.user!.email;

      // 生成新Token
      const newToken = this.authService.generateToken(userId, email);

      res.json(
        createSuccessResponse(
          { token: newToken },
          'Token刷新成功'
        )
      );
    } catch (error: any) {
      next(error);
    }
  };

  /**
   * 删除当前用户账户
   * DELETE /api/v1/auth/delete
   */
  deleteAccount = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const userId = req.user?.id;

      if (!userId) {
        throw new Error(ErrorCode.UNAUTHORIZED);
      }

      await this.authService.deleteAccount(userId);

      res.json(createSuccessResponse(null, '账户删除成功'));
    } catch (error: any) {
      next(error);
    }
  };
}
