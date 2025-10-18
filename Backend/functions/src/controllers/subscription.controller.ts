/**
 * Subscription Controller
 *
 * 处理订阅相关的HTTP请求
 */

import { Request, Response, NextFunction } from 'express';
import { UserService } from '../services/user/user.service';
import { UsageService } from '../services/user/usage.service';
import { createSuccessResponse, createErrorResponse, CurrentSubscription } from '../models';
import { HttpStatus, ErrorCode, USAGE_LIMITS } from '../config/constants';
import { AuthRequest } from '../middleware/auth.middleware';

export class SubscriptionController {
  private userService: UserService;
  private usageService: UsageService;

  constructor() {
    this.userService = new UserService();
    this.usageService = new UsageService();
  }

  /**
   * 获取当前订阅状态
   * GET /api/v1/subscriptions/current
   */
  getCurrentSubscription = async (
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

      const isActive = this.userService.isSubscriptionActive(user);

      const subscription: CurrentSubscription = {
        subscriptionType: user.subscription_type,
        status: isActive ? 'active' : user.subscription_type === 'vip' ? 'expired' : 'none',
        startDate: user.subscription_start_date,
        endDate: user.subscription_end_date,
        features: {
          aiGenerationsPerYear: USAGE_LIMITS[user.subscription_type],
        },
      };

      res.json(createSuccessResponse(subscription));
    } catch (error: any) {
      next(error);
    }
  };

  /**
   * 升级到VIP
   * POST /api/v1/subscriptions/upgrade
   *
   * 注意：这里只是示例，实际需要集成支付网关
   */
  upgrade = async (
    req: AuthRequest,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { plan, paymentMethod } = req.body;

      const user = await this.userService.getUser(userId);
      if (!user) {
        res
          .status(HttpStatus.NOT_FOUND)
          .json(createErrorResponse(ErrorCode.USER_NOT_FOUND, '用户不存在'));
        return;
      }

      // 检查是否已经是VIP
      if (
        user.subscription_type === 'vip' &&
        this.userService.isSubscriptionActive(user)
      ) {
        res
          .status(HttpStatus.BAD_REQUEST)
          .json(
            createErrorResponse(
              'ALREADY_VIP',
              '您已经是VIP用户，无需重复订阅'
            )
          );
        return;
      }

      // 计算订阅时间
      const startDate = new Date();
      const endDate = new Date();
      if (plan === 'vip_yearly') {
        endDate.setFullYear(endDate.getFullYear() + 1);
      } else if (plan === 'vip_monthly') {
        endDate.setMonth(endDate.getMonth() + 1);
      }

      // 价格配置
      const prices: Record<string, number> = {
        vip_yearly: 99,
        vip_monthly: 12,
      };

      const amount = prices[plan] || 99;

      // TODO: 这里应该调用实际的支付网关API
      // 例如：Stripe, Alipay, WeChat Pay等
      // 生成支付链接并返回

      // 模拟支付URL（实际应该是真实的支付链接）
      const paymentUrl = `https://payment.example.com/pay?order_id=mock_${Date.now()}&amount=${amount}`;

      // 注意：实际情况下，只有在支付成功回调后才更新用户订阅状态
      // 这里为了演示，直接返回支付信息

      res.json(
        createSuccessResponse(
          {
            subscriptionId: `sub_${Date.now()}`,
            paymentUrl,
            amount,
            currency: 'CNY',
            message:
              '此为示例响应。实际部署时，请集成真实的支付网关（如Stripe、支付宝、微信支付）',
          },
          '订阅升级请求已创建，请完成支付'
        )
      );
    } catch (error: any) {
      next(error);
    }
  };

  /**
   * 支付回调处理（Webhook）
   * POST /api/v1/subscriptions/webhook
   *
   * 注意：这个端点应该由支付网关调用，需要验证签名
   */
  webhook = async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      // TODO: 验证支付网关的签名
      // const signature = req.headers['x-payment-signature'];
      // verifySignature(req.body, signature);

      const { userId, plan, transactionId, status } = req.body;

      if (status === 'success') {
        // 支付成功，更新用户订阅
        const startDate = new Date();
        const endDate = new Date();

        if (plan === 'vip_yearly') {
          endDate.setFullYear(endDate.getFullYear() + 1);
        } else if (plan === 'vip_monthly') {
          endDate.setMonth(endDate.getMonth() + 1);
        }

        // 更新用户为VIP
        await this.userService.updateSubscription(
          userId,
          'vip',
          startDate,
          endDate
        );

        // 更新使用量限制
        await this.usageService.updateLimit(userId, USAGE_LIMITS.vip);

        // TODO: 记录订阅记录到subscriptions表

        console.log(`User ${userId} upgraded to VIP successfully`);
      }

      res.json({ received: true });
    } catch (error: any) {
      next(error);
    }
  };

  /**
   * 取消订阅
   * POST /api/v1/subscriptions/cancel
   */
  cancel = async (
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

      if (user.subscription_type !== 'vip') {
        res
          .status(HttpStatus.BAD_REQUEST)
          .json(
            createErrorResponse('NOT_VIP', '您当前不是VIP用户')
          );
        return;
      }

      // 将用户降级为免费用户
      await this.userService.updateSubscription(userId, 'free');

      // 更新使用量限制
      await this.usageService.updateLimit(userId, USAGE_LIMITS.free);

      res.json(createSuccessResponse(null, 'VIP订阅已取消'));
    } catch (error: any) {
      next(error);
    }
  };
}
