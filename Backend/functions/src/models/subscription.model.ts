/**
 * Subscription Models
 */

/**
 * 订阅记录
 */
export interface Subscription {
  id: string;
  user_id: string;
  type: 'vip';
  status: 'active' | 'expired' | 'cancelled';
  price: number;
  currency: string;
  start_date: string;
  end_date: string;
  payment_method: string | null;
  transaction_id: string | null;
  created_at: string;
}

/**
 * 用户使用量
 */
export interface UserUsage {
  id: string;
  user_id: string;
  year: number;
  ai_generation_count: number;
  ai_generation_limit: number;
  last_reset_date: string;
  updated_at: string;
}

/**
 * AI生成历史记录
 */
export interface AiGeneration {
  id: string;
  user_id: string;
  destination_name: string;
  country: string;
  budget_level: 'high' | 'medium' | 'low';
  start_date: string;
  end_date: string;
  status: 'success' | 'failed';
  tokens_used: number | null;
  error_message: string | null;
  created_at: string;
}

/**
 * 升级VIP请求
 */
export interface UpgradeRequest {
  plan: 'vip_yearly' | 'vip_monthly';
  payment_method: 'alipay' | 'wechat' | 'stripe';
}

/**
 * 升级VIP响应
 */
export interface UpgradeResponse {
  subscriptionId: string;
  paymentUrl: string;
  amount: number;
  currency: string;
}

/**
 * 当前订阅状态
 */
export interface CurrentSubscription {
  subscriptionType: 'free' | 'vip';
  status: 'active' | 'expired' | 'none';
  startDate: string | null;
  endDate: string | null;
  features: {
    aiGenerationsPerYear: number;
  };
}
