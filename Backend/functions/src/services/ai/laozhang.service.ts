/**
 * Laozhang.ai Service
 *
 * 调用Laozhang.ai API（OpenAI标准接口）生成旅行规划
 */

import { getLaozhangClient, LAOZHANG_MODEL, LAOZHANG_GENERATION_CONFIG } from '../../config/laozhang.config';
import { PlanningContext, AiDestinationPlan } from '../../models';
import { ErrorCode } from '../../config/constants';
import { PromptBuilderService } from './prompt-builder.service';
import { PlanParserService } from './plan-parser.service';

export class LaozhangService {
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

      // 2. 调用Laozhang.ai API（OpenAI格式）
      const client = getLaozhangClient();
      const completion = await client.chat.completions.create({
        model: LAOZHANG_MODEL,
        messages: [
          {
            role: 'system',
            content: '你是一位专业的旅行规划师，请严格按照要求的JSON格式返回旅行规划。',
          },
          {
            role: 'user',
            content: prompt,
          },
        ],
        ...LAOZHANG_GENERATION_CONFIG,
      });

      // 3. 获取响应
      const response = completion.choices[0]?.message?.content;
      if (!response) {
        throw new Error('Laozhang.ai API返回空响应');
      }

      console.log('Laozhang.ai response received, length:', response.length);

      // 4. 解析结果
      const plan = this.planParser.parse(response);

      // 5. 清理和标准化数据
      const sanitizedPlan = this.planParser.sanitize(plan);

      console.log('Successfully generated plan for:', context.destinationName);

      return sanitizedPlan;
    } catch (error: any) {
      console.error('Laozhang.ai API call failed:', error);

      // 处理特定错误
      if (error.message?.includes('API key') || error.status === 401) {
        throw new Error('Laozhang.ai API密钥无效或未配置');
      }

      if (error.message?.includes('quota') || error.status === 429) {
        throw new Error('Laozhang.ai API配额已用尽，请稍后重试');
      }

      if (error.message?.includes('timeout') || error.code === 'ETIMEDOUT') {
        throw new Error('AI生成超时，请重试');
      }

      if (error.status === 500 || error.status === 503) {
        throw new Error('Laozhang.ai服务暂时不可用，请稍后重试');
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
