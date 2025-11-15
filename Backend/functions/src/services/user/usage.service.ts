/**
 * Usage Service
 *
 * 处理用户使用量相关的业务逻辑
 */

import { supabase } from '../../config/supabase.config';
import { USAGE_LIMITS } from '../../config/constants';
import { UserUsage } from '../../models';

export class UsageService {
  /**
   * 检查并扣除使用次数
   * 返回是否允许使用以及剩余次数
   */
  async checkAndDeductUsage(
    userId: string,
    subscriptionType: 'free' | 'vip'
  ): Promise<{ allowed: boolean; remaining: number; limit: number }> {
    const year = new Date().getFullYear();
    const defaultLimit = USAGE_LIMITS[subscriptionType];

    try {
      // 1. 查询当前使用量
      const { data: usage, error: fetchError } = await supabase
        .from('user_usage')
        .select('*')
        .eq('user_id', userId)
        .eq('year', year)
        .single();

      // 2. 处理未找到记录的情况
      if (fetchError && fetchError.code !== 'PGRST116') {
        console.error('Failed to fetch usage:', fetchError);
        throw fetchError;
      }

      // 3. 如果没有记录，创建新记录
      if (!usage) {
        const { error: insertError } = await supabase
          .from('user_usage')
          .insert({
            user_id: userId,
            year,
            ai_generation_count: 1,
            ai_generation_limit: defaultLimit,
          });

        if (insertError) {
          console.error('Failed to create usage record:', insertError);
          throw insertError;
        }

        return {
          allowed: true,
          remaining: defaultLimit - 1,
          limit: defaultLimit,
        };
      }

      const effectiveLimit = usage.ai_generation_limit ?? defaultLimit;

      // 4. 检查是否超限
      if (usage.ai_generation_count >= effectiveLimit) {
        return {
          allowed: false,
          remaining: 0,
          limit: effectiveLimit,
        };
      }

      // 5. 扣除使用次数
      const newCount = usage.ai_generation_count + 1;
      const { error: updateError } = await supabase
        .from('user_usage')
        .update({
          ai_generation_count: newCount,
        })
        .eq('user_id', userId)
        .eq('year', year);

      if (updateError) {
        console.error('Failed to update usage:', updateError);
        throw updateError;
      }

      return {
        allowed: true,
        remaining: effectiveLimit - newCount,
        limit: effectiveLimit,
      };
    } catch (error) {
      console.error('Error in checkAndDeductUsage:', error);
      throw new Error('无法检查使用量');
    }
  }

  /**
   * 获取用户当前年度的使用量，如果不存在则创建
   */
  async getUsage(
    userId: string,
    subscriptionType: 'free' | 'vip'
  ): Promise<UserUsage> {
    const year = new Date().getFullYear();
    const limit = USAGE_LIMITS[subscriptionType];

    const { data, error } = await supabase
      .from('user_usage')
      .select('*')
      .eq('user_id', userId)
      .eq('year', year)
      .single();

    if (error && error.code !== 'PGRST116') {
      console.error('Failed to get usage:', error);
      throw error;
    }

    if (data) {
      return data as UserUsage;
    }

    const { data: newUsage, error: insertError } = await supabase
      .from('user_usage')
      .insert({
        user_id: userId,
        year,
        ai_generation_count: 0,
        ai_generation_limit: limit,
        last_reset_date: new Date().toISOString(),
      })
      .select('*')
      .single();

    if (insertError) {
      console.error('Failed to create usage record:', insertError);
      throw insertError;
    }

    return newUsage as UserUsage;
  }

  /**
   * 退还使用次数（用于失败回滚）
   */
  async refundUsage(userId: string): Promise<void> {
    const year = new Date().getFullYear();

    try {
      // 调用数据库函数进行原子递减
      const { error } = await supabase.rpc('decrement_usage', {
        p_user_id: userId,
        p_year: year,
      });

      if (error) {
        console.error('Failed to refund usage:', error);
        // 不抛出错误，避免影响主流程
      }
    } catch (error) {
      console.error('Error refunding usage:', error);
      // 静默失败
    }
  }

  /**
   * 重置用户使用量（用于新年度或管理操作）
   */
  async resetUsage(
    userId: string,
    year?: number,
    subscriptionType?: 'free' | 'vip'
  ): Promise<void> {
    const targetYear = year || new Date().getFullYear();
    const limit = subscriptionType
      ? USAGE_LIMITS[subscriptionType]
      : USAGE_LIMITS.free;

    const { error } = await supabase.from('user_usage').upsert(
      {
        user_id: userId,
        year: targetYear,
        ai_generation_count: 0,
        ai_generation_limit: limit,
        last_reset_date: new Date().toISOString(),
      },
      {
        onConflict: 'user_id,year',
      }
    );

    if (error) {
      console.error('Failed to reset usage:', error);
      throw error;
    }
  }

  /**
   * 更新使用量限制（用于升级/降级）
   */
  async updateLimit(
    userId: string,
    newLimit: number,
    year?: number
  ): Promise<void> {
    const targetYear = year || new Date().getFullYear();

    const { error } = await supabase
      .from('user_usage')
      .update({
        ai_generation_limit: newLimit,
      })
      .eq('user_id', userId)
      .eq('year', targetYear);

    if (error) {
      console.error('Failed to update usage limit:', error);
      throw error;
    }
  }
}
