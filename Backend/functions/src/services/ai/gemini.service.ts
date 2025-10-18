/**
 * Gemini Service
 *
 * 调用Google Gemini API生成旅行规划
 */

import { getGeminiModel, GENERATION_CONFIG } from '../../config/gemini.config';
import { PlanningContext, AiDestinationPlan } from '../../models';
import { ErrorCode } from '../../config/constants';
import { PromptBuilderService } from './prompt-builder.service';
import { PlanParserService } from './plan-parser.service';

export class GeminiService {
  private promptBuilder: PromptBuilderService;
  private planParser: PlanParserService;

  constructor() {
    this.promptBuilder = new PromptBuilderService();
    this.planParser = new PlanParserService();
  }

  /**
   * 生成目的地规划
   */
  async generateDestinationPlan(
    context: PlanningContext
  ): Promise<AiDestinationPlan> {
    try {
      // 1. 构建Prompt
      const prompt = this.promptBuilder.build(context);
      console.log('Generated prompt length:', prompt.length);

      // 2. 调用Gemini API
      const model = getGeminiModel();
      const result = await model.generateContent({
        contents: [
          {
            role: 'user',
            parts: [{ text: prompt }],
          },
        ],
        generationConfig: {
          ...GENERATION_CONFIG,
          responseMimeType: 'application/json',
        },
      });

      // 3. 获取响应
      const response = result.response;
      const jsonText = response.text();

      console.log('Gemini response received, length:', jsonText.length);

      // 4. 解析结果
      const plan = this.planParser.parse(jsonText);

      // 5. 清理和标准化数据
      const sanitizedPlan = this.planParser.sanitize(plan);

      console.log('Successfully generated plan for:', context.destinationName);

      return sanitizedPlan;
    } catch (error: any) {
      console.error('Gemini API call failed:', error);

      // 处理特定错误
      if (error.message?.includes('API key')) {
        throw new Error('Gemini API密钥无效或未配置');
      }

      if (error.message?.includes('quota')) {
        throw new Error('Gemini API配额已用尽，请稍后重试');
      }

      if (error.message?.includes('timeout')) {
        throw new Error('AI生成超时，请重试');
      }

      // 通用错误
      throw new Error(ErrorCode.AI_GENERATION_FAILED);
    }
  }

  /**
   * 带重试的生成（可选）
   */
  async generateWithRetry(
    context: PlanningContext,
    maxRetries: number = 2
  ): Promise<AiDestinationPlan> {
    let lastError: Error | null = null;

    for (let i = 0; i < maxRetries; i++) {
      try {
        return await this.generateDestinationPlan(context);
      } catch (error: any) {
        console.error(`Attempt ${i + 1} failed:`, error.message);
        lastError = error;

        // 如果是配额或API密钥错误，不重试
        if (
          error.message?.includes('quota') ||
          error.message?.includes('API key')
        ) {
          throw error;
        }

        // 等待一段时间后重试
        if (i < maxRetries - 1) {
          await this.delay(2000 * (i + 1)); // 递增延迟
        }
      }
    }

    throw lastError || new Error(ErrorCode.AI_GENERATION_FAILED);
  }

  /**
   * 延迟函数
   */
  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  /**
   * 估算Token使用量（粗略估算）
   */
  estimateTokens(context: PlanningContext): { input: number; output: number } {
    const prompt = this.promptBuilder.build(context);
    const inputTokens = Math.ceil(prompt.length / 4); // 粗略估算：4字符≈1 token
    const outputTokens = 2000; // 预期输出约2000 tokens

    return {
      input: inputTokens,
      output: outputTokens,
    };
  }
}
