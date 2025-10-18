/**
 * User Service
 *
 * 处理用户相关的业务逻辑
 */

import { supabase } from '../../config/supabase.config';
import { User, SafeUser, sanitizeUser, PlanningContext } from '../../models';
import { ErrorCode } from '../../config/constants';

export class UserService {
  /**
   * 通过ID获取用户
   */
  async getUser(userId: string): Promise<SafeUser | null> {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        // PostgreSQL未找到记录
        return null;
      }
      console.error('Failed to get user:', error);
      throw new Error(ErrorCode.DATABASE_ERROR);
    }

    return sanitizeUser(data as User);
  }

  /**
   * 通过邮箱获取用户
   */
  async getUserByEmail(email: string): Promise<SafeUser | null> {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null;
      }
      console.error('Failed to get user by email:', error);
      throw new Error(ErrorCode.DATABASE_ERROR);
    }

    return sanitizeUser(data as User);
  }

  /**
   * 更新用户订阅状态
   */
  async updateSubscription(
    userId: string,
    subscriptionType: 'free' | 'vip',
    startDate?: Date,
    endDate?: Date
  ): Promise<void> {
    const updateData: any = {
      subscription_type: subscriptionType,
    };

    if (startDate) {
      updateData.subscription_start_date = startDate.toISOString();
    }

    if (endDate) {
      updateData.subscription_end_date = endDate.toISOString();
    }

    const { error } = await supabase
      .from('users')
      .update(updateData)
      .eq('id', userId);

    if (error) {
      console.error('Failed to update subscription:', error);
      throw new Error(ErrorCode.DATABASE_ERROR);
    }
  }

  /**
   * 记录AI生成历史
   */
  async recordAiGeneration(
    userId: string,
    context: PlanningContext,
    status: 'success' | 'failed',
    errorMessage?: string,
    tokensUsed?: number
  ): Promise<void> {
    try {
      const { error } = await supabase.from('ai_generations').insert({
        user_id: userId,
        destination_name: context.destinationName,
        country: context.country || '未知', // 提供默认值，因为country现在是可选的
        budget_level: context.budgetLevel,
        start_date: context.startDate,
        end_date: context.endDate,
        status,
        error_message: errorMessage || null,
        tokens_used: tokensUsed || null,
      });

      if (error) {
        console.error('Failed to record AI generation:', error);
        // 不抛出错误，避免影响主流程
      }
    } catch (error) {
      console.error('Error recording AI generation:', error);
      // 静默失败，不影响主流程
    }
  }

  /**
   * 获取用户的AI生成历史
   */
  async getAiGenerationHistory(
    userId: string,
    limit: number = 10
  ): Promise<any[]> {
    const { data, error } = await supabase
      .from('ai_generations')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) {
      console.error('Failed to get AI generation history:', error);
      throw new Error(ErrorCode.DATABASE_ERROR);
    }

    return data || [];
  }

  /**
   * 检查用户订阅是否过期
   */
  isSubscriptionActive(user: SafeUser): boolean {
    if (user.subscription_type === 'free') {
      return true; // 免费用户始终有效
    }

    if (!user.subscription_end_date) {
      return false;
    }

    const endDate = new Date(user.subscription_end_date);
    return endDate > new Date();
  }
}
