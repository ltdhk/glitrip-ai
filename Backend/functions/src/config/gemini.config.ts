/**
 * Google Gemini AI Configuration
 *
 * 配置Gemini API用于生成旅行规划
 */

import { GoogleGenerativeAI } from '@google/generative-ai';
import dotenv from 'dotenv';

dotenv.config();

const geminiApiKey = process.env.GEMINI_API_KEY;

if (!geminiApiKey) {
  throw new Error('Missing required environment variable: GEMINI_API_KEY');
}

/**
 * Google Generative AI实例
 */
export const genAI = new GoogleGenerativeAI(geminiApiKey);

/**
 * Gemini模型配置
 */
export const GEMINI_MODEL = 'gemini-2.0-flash'; // 使用Flash模型，快速且便宜

/**
 * 生成配置
 */
export const GENERATION_CONFIG = {
  temperature: 0.7, // 创造性程度
  topP: 0.95,
  topK: 40,
  maxOutputTokens: 8192, // 最大输出长度 - 增加以避免截断
  responseMimeType: 'application/json', // 返回JSON格式
};

/**
 * 获取Gemini模型实例
 */
export function getGeminiModel() {
  return genAI.getGenerativeModel({
    model: GEMINI_MODEL,
  });
}
