/**
 * AI Service Factory
 *
 * 根据环境配置选择AI服务提供商（Google Gemini 或 Laozhang.ai）
 */

import { GeminiService } from './gemini.service';
import { LaozhangService } from './laozhang.service';
import { PlanningContext, AiDestinationPlan } from '../../models';

/**
 * AI服务接口
 * 统一Google Gemini和Laozhang.ai的接口
 */
export interface IAiService {
  generateDestinationPlan(context: PlanningContext): Promise<AiDestinationPlan>;
  generateWithRetry(
    context: PlanningContext,
    maxRetries?: number
  ): Promise<AiDestinationPlan>;
  estimateTokens(context: PlanningContext): { input: number; output: number };
}

/**
 * 支持的AI提供商类型
 */
export type AiProvider = 'google' | 'laozhang';

/**
 * AI服务工厂类
 */
export class AiServiceFactory {
  /**
   * 创建AI服务实例
   * @param provider AI提供商类型，如果不指定则从环境变量读取
   */
  static createService(provider?: AiProvider): IAiService {
    const aiProvider = provider || (process.env.AI_PROVIDER as AiProvider) || 'laozhang';

    console.log(`Using AI provider: ${aiProvider}`);

    switch (aiProvider) {
      case 'google':
        return new GeminiService();

      case 'laozhang':
        return new LaozhangService();

      default:
        console.warn(
          `Unknown AI provider "${aiProvider}", falling back to Laozhang.ai`
        );
        return new LaozhangService();
    }
  }

  /**
   * 获取当前配置的AI提供商名称
   */
  static getCurrentProvider(): AiProvider {
    return (process.env.AI_PROVIDER as AiProvider) || 'laozhang';
  }

  /**
   * 检查AI提供商是否可用
   */
  static isProviderAvailable(provider: AiProvider): boolean {
    try {
      switch (provider) {
        case 'google':
          return !!process.env.GEMINI_API_KEY;

        case 'laozhang':
          return !!process.env.LAOZHANG_API_KEY;

        default:
          return false;
      }
    } catch {
      return false;
    }
  }

  /**
   * 获取所有可用的AI提供商
   */
  static getAvailableProviders(): AiProvider[] {
    const providers: AiProvider[] = [];

    if (this.isProviderAvailable('google')) {
      providers.push('google');
    }

    if (this.isProviderAvailable('laozhang')) {
      providers.push('laozhang');
    }

    return providers;
  }
}
