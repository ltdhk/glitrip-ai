/**
 * Laozhang.ai Configuration
 *
 * 配置Laozhang.ai API（使用OpenAI标准接口）用于生成旅行规划
 */

import OpenAI from 'openai';
import dotenv from 'dotenv';

dotenv.config();

const laozhangApiKey = process.env.LAOZHANG_API_KEY;
const laozhangBaseUrl = process.env.LAOZHANG_BASE_URL || 'https://api.laozhang.ai/v1';

if (!laozhangApiKey) {
  throw new Error('Missing required environment variable: LAOZHANG_API_KEY');
}

/**
 * Laozhang.ai OpenAI客户端实例
 */
export const laozhangClient = new OpenAI({
  apiKey: laozhangApiKey,
  baseURL: laozhangBaseUrl,
});

/**
 * Laozhang.ai模型配置
 */
export const LAOZHANG_MODEL = process.env.LAOZHANG_MODEL || 'gpt-4'; // 默认使用GPT-4

/**
 * 生成配置（OpenAI格式）
 */
export const LAOZHANG_GENERATION_CONFIG = {
  temperature: 0.7, // 创造性程度
  max_tokens: 8192, // 最大输出长度
  top_p: 0.95,
  response_format: { type: 'json_object' as const }, // 返回JSON格式
};

/**
 * 获取Laozhang.ai客户端实例
 */
export function getLaozhangClient(): OpenAI {
  return laozhangClient;
}
