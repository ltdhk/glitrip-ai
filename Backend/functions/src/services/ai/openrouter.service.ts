/**
 * OpenRouter Service
 *
 * 调用OpenRouter（OpenAI兼容接口）生成旅行规划
 */

import {
  buildOpenRouterHeaders,
  OPENROUTER_BASE_URL,
  OPENROUTER_MODEL,
  OPENROUTER_GENERATION_CONFIG,
} from '../../config/openrouter.config';
import { PlanningContext, AiDestinationPlan } from '../../models';
import { ErrorCode } from '../../config/constants';
import { PromptBuilderService } from './prompt-builder.service';
import { PlanParserService } from './plan-parser.service';

export class OpenRouterService {
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

      // 2. 调用OpenRouter API
      const headers = buildOpenRouterHeaders();
      const fetchFn = (globalThis as any).fetch;

      if (typeof fetchFn !== 'function') {
        throw new Error('当前环境不支持fetch，请升级Node版本或引入fetch polyfill');
      }

      const response = await fetchFn(`${OPENROUTER_BASE_URL}/chat/completions`, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          model: OPENROUTER_MODEL,
          messages: [
            {
              role: 'system',
              content:
                '你是一位专业的旅行规划师，请严格按照要求的JSON格式返回旅行规划。',
            },
            {
              role: 'user',
              content: prompt,
            },
          ],
          ...OPENROUTER_GENERATION_CONFIG,
        }),
      });

      if (!response.ok) {
        const errorBody = await response.text();
        console.error('OpenRouter non-200 response:', response.status, errorBody);
        throw new Error(
          response.status === 401
            ? 'OpenRouter API密钥无效或未配置'
            : `OpenRouter请求失败: ${response.status}`
        );
      }

      const rawBody = await response.text();
      if (!rawBody) {
        throw new Error('OpenRouter API返回空响应');
      }

      let completion: any;
      try {
        completion = JSON.parse(rawBody);
      } catch (parseError) {
        console.error('Failed to parse OpenRouter JSON response:', parseError);

        // 部分模型会以SSE形式返回，需要从data段提取
        const ssePayload = this.extractSseJson(rawBody);
        if (ssePayload) {
          completion = ssePayload;
        } else {
          console.error('Raw OpenRouter response:', rawBody);
          throw new Error('OpenRouter响应解析失败，请稍后重试');
        }
      }

      // 3. 获取响应
      const message = completion?.choices?.[0]?.message;
      const responseText = this.normalizeMessageContent(message?.content);
      if (!responseText) {
        throw new Error('OpenRouter API返回空响应');
      }

      console.log('OpenRouter response received, length:', responseText.length);

      // 4. 解析结果
      const plan = this.planParser.parse(responseText);

      // 5. 清理和标准化数据
      const sanitizedPlan = this.planParser.sanitize(plan);

      console.log('Successfully generated plan for:', context.destinationName);

      return sanitizedPlan;
    } catch (error: any) {
      console.error('OpenRouter API call failed:', error);

      // 处理特定错误
      if (error.message?.includes('API key') || error.status === 401) {
        throw new Error('OpenRouter API密钥无效或未配置');
      }

      if (error.message?.includes('quota') || error.status === 429) {
        throw new Error('OpenRouter API配额已用尽，请稍后重试');
      }

      if (error.message?.includes('timeout') || error.code === 'ETIMEDOUT') {
        throw new Error('AI生成超时，请重试');
      }

      if (
        error.message?.includes('terminated') ||
        error.code === 'UND_ERR_SOCKET' ||
        error.cause?.code === 'UND_ERR_SOCKET' ||
        error.name === 'AbortError'
      ) {
        throw new Error('OpenRouter连接中断，请稍后重试');
      }

      if (error.status === 500 || error.status === 503) {
        throw new Error('OpenRouter服务暂时不可用，请稍后重试');
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

  /**
   * 将不同格式的消息内容标准化为纯文本
   */
  private normalizeMessageContent(content: unknown): string | null {
    if (!content) {
      return null;
    }

    if (typeof content === 'string') {
      return content.trim();
    }

    if (Array.isArray(content)) {
      const text = content
        .map((part) => {
          if (!part) return '';
          if (typeof part === 'string') return part;
          if (typeof (part as any).text === 'string') {
            return (part as any).text;
          }
          if (Array.isArray((part as any).content)) {
            return (part as any).content
              .map((nested: any) => nested?.text || '')
              .join('\n');
          }
          return '';
        })
        .filter((segment) => segment.trim().length > 0)
        .join('\n')
        .trim();

      return text.length > 0 ? text : null;
    }

    return null;
  }

  /**
   * 从SSE响应中提取JSON
   */
  private extractSseJson(raw: string): any | null {
    const dataLines = raw
      .split('\n')
      .map((line) => line.trim())
      .filter((line) => line.startsWith('data:'))
      .map((line) => line.replace(/^data:\s*/, '').trim())
      .filter((line) => line && line !== '[DONE]');

    for (let i = dataLines.length - 1; i >= 0; i--) {
      try {
        return JSON.parse(dataLines[i]);
      } catch {
        continue;
      }
    }

    return null;
  }
}
