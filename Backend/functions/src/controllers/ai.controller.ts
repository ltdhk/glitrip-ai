/**
 * AI Controller
 *
 * 处理AI生成相关的HTTP请求
 */

import { Response, NextFunction } from 'express';
import { GeminiService } from '../services/ai/gemini.service';
import { UserService } from '../services/user/user.service';
import { UsageService } from '../services/user/usage.service';
import { createSuccessResponse, createErrorResponse, PlanningContext } from '../models';
import { HttpStatus, ErrorCode } from '../config/constants';
import { AuthRequest } from '../middleware/auth.middleware';

export class AiController {
  private geminiService: GeminiService;
  private userService: UserService;
  private usageService: UsageService;

  constructor() {
    this.geminiService = new GeminiService();
    this.userService = new UserService();
    this.usageService = new UsageService();
  }

  /**
   * 生成AI行程规划
   * POST /api/v1/ai/generate-plan
   */
  generatePlan = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    const userId = req.user!.id;
    const context: PlanningContext = req.body;

    try {
      // 1. 获取用户信息
      const user = await this.userService.getUser(userId);
      if (!user) {
        res
          .status(HttpStatus.NOT_FOUND)
          .json(createErrorResponse(ErrorCode.USER_NOT_FOUND, '用户不存在'));
        return;
      }

      // 2. 检查订阅是否有效（VIP用户）
      if (user.subscription_type === 'vip' && !this.userService.isSubscriptionActive(user)) {
        // VIP已过期，降级为免费用户
        await this.userService.updateSubscription(userId, 'free');
        user.subscription_type = 'free';
      }

      // 3. 检查并扣除使用次数
      const usageCheck = await this.usageService.checkAndDeductUsage(
        userId,
        user.subscription_type
      );

      if (!usageCheck.allowed) {
        res.status(HttpStatus.FORBIDDEN).json({
          success: false,
          error: {
            code: ErrorCode.QUOTA_EXCEEDED,
            message: `您今年的${
              user.subscription_type === 'free' ? '免费' : 'VIP'
            }AI规划次数已用尽`,
            details: {
              used: usageCheck.limit,
              limit: usageCheck.limit,
              subscriptionType: user.subscription_type,
            },
          },
          upgradeUrl:
            user.subscription_type === 'free'
              ? '/api/v1/subscriptions/upgrade'
              : null,
        });
        return;
      }

      // 4. 调用AI生成
      console.log(`Generating plan for user ${userId}:`, context);
      const plan = await this.geminiService.generateDestinationPlan(context);

      // 5. 记录生成历史
      await this.userService.recordAiGeneration(userId, context, 'success');

      // 6. 返回结果
      res.json({
        success: true,
        data: plan,
        usage: {
          remaining: usageCheck.remaining,
          limit: usageCheck.limit,
        },
      });
    } catch (error: any) {
      console.error('AI生成失败:', error);

      // 记录失败并尝试退还使用次数
      try {
        await this.userService.recordAiGeneration(
          userId,
          context,
          'failed',
          error.message
        );
        await this.usageService.refundUsage(userId);
      } catch (refundError) {
        console.error('退还使用次数失败:', refundError);
      }

      // 传递错误到错误处理中间件
      next(error);
    }
  };

  /**
   * 获取使用量信息
   * GET /api/v1/ai/usage
   */
  getUsage = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const userId = req.user!.id;

      const user = await this.userService.getUser(userId);
      if (!user) {
        res
          .status(HttpStatus.NOT_FOUND)
          .json(createErrorResponse(ErrorCode.USER_NOT_FOUND, '用户不存在'));
        return;
      }

      const usage = await this.usageService.getUsage(userId);

      const limit = user.subscription_type === 'vip' ? 1000 : 3;
      const used = usage?.ai_generation_count || 0;
      const remaining = Math.max(0, limit - used);

      res.json(
        createSuccessResponse({
          year: new Date().getFullYear(),
          used,
          limit,
          remaining,
          subscriptionType: user.subscription_type,
          resetDate: `${new Date().getFullYear() + 1}-01-01T00:00:00Z`,
        })
      );
    } catch (error: any) {
      next(error);
    }
  };

  /**
   * 获取AI生成历史
   * GET /api/v1/ai/history
   */
  getHistory = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const userId = req.user!.id;
      const limit = parseInt(req.query.limit as string) || 10;

      const history = await this.userService.getAiGenerationHistory(userId, limit);

      res.json(createSuccessResponse(history));
    } catch (error: any) {
      next(error);
    }
  };
}
