/**
 * OpenRouter Configuration
 *
 * 提供调用OpenRouter所需的配置和默认请求头
 */

import dotenv from 'dotenv';

dotenv.config();

export const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY || '';
export const OPENROUTER_BASE_URL =
  process.env.OPENROUTER_BASE_URL || 'https://openrouter.ai/api/v1';
export const OPENROUTER_SITE_URL = process.env.OPENROUTER_SITE_URL;
export const OPENROUTER_SITE_NAME = process.env.OPENROUTER_SITE_NAME;

/**
 * OpenRouter模型配置
 */
export const OPENROUTER_MODEL =
  process.env.OPENROUTER_MODEL || 'z-ai/glm-4.5-air:free';

/**
 * 生成配置
 */
export const OPENROUTER_GENERATION_CONFIG = {
  temperature: 0.7,
  max_tokens: 8192,
  top_p: 0.95,
};

/**
 * 获取请求头
 */
export function buildOpenRouterHeaders(): Record<string, string> {
  if (!OPENROUTER_API_KEY) {
    throw new Error('OpenRouter API密钥无效或未配置');
  }

  const headers: Record<string, string> = {
    Authorization: `Bearer ${OPENROUTER_API_KEY}`,
    'Content-Type': 'application/json',
    Accept: 'application/json',
  };

  if (OPENROUTER_SITE_URL) {
    headers['HTTP-Referer'] = OPENROUTER_SITE_URL;
  }

  if (OPENROUTER_SITE_NAME) {
    headers['X-Title'] = OPENROUTER_SITE_NAME;
  }

  return headers;
}
