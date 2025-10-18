/**
 * AI Planning Models
 */

/**
 * 规划上下文（用户输入）
 */
export interface PlanningContext {
  destinationName: string;
  country?: string; // 可选，如果不提供则由AI生成
  budgetLevel: 'high' | 'medium' | 'low';
  startDate: string; // YYYY-MM-DD
  endDate: string; // YYYY-MM-DD
  language?: 'zh' | 'en'; // 语言，默认zh
}

/**
 * 活动
 */
export interface Activity {
  title: string;
  startTime: string; // HH:MM
  endTime: string; // HH:MM
  location: string;
  description: string;
  estimatedCost?: number;
}

/**
 * 每日行程
 */
export interface DailyItinerary {
  dayNumber: number;
  date: string; // YYYY-MM-DD
  title: string;
  activities: Activity[];
}

/**
 * 打包物品
 */
export interface PackingItem {
  name: string;
  category: string;
  quantity?: number;
  isEssential?: boolean;
}

/**
 * 待办事项
 */
export interface TodoItem {
  title: string;
  description?: string;
  priority?: 'high' | 'medium' | 'low';
}

/**
 * AI生成的目的地计划
 */
export interface AiDestinationPlan {
  tagline: string; // 一句话特色描述
  tags: string[]; // 3个标签
  detailedDescription: string; // 详细描述
  country: string; // 国家（由AI生成）
  itineraries: DailyItinerary[]; // 行程规划
  packingItems: PackingItem[]; // 打包物品
  todoChecklist: TodoItem[]; // 待办事项
}

/**
 * AI生成请求
 */
export interface GeneratePlanRequest extends PlanningContext {}

/**
 * AI生成响应
 */
export interface GeneratePlanResponse {
  success: boolean;
  data?: AiDestinationPlan;
  usage?: {
    remaining: number;
    limit: number;
  };
  error?: {
    code: string;
    message: string;
    details?: any;
  };
  upgradeUrl?: string;
}

/**
 * 使用量信息
 */
export interface UsageInfo {
  year: number;
  used: number;
  limit: number;
  remaining: number;
  subscriptionType: 'free' | 'vip';
  resetDate: string;
}
