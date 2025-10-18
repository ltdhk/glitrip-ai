/**
 * Plan Parser Service
 *
 * 解析Gemini API返回的结果
 */

import { AiDestinationPlan } from '../../models';
import { ErrorCode } from '../../config/constants';

export class PlanParserService {
  /**
   * 解析JSON文本为结构化数据
   */
  parse(jsonText: string): AiDestinationPlan {
    try {
      // 尝试直接解析JSON
      const parsed = JSON.parse(jsonText);

      // 验证必需字段
      this.validatePlan(parsed);

      return parsed as AiDestinationPlan;
    } catch (error: any) {
      console.error('Failed to parse AI response:', error);
      console.error('Raw response:', jsonText);

      // 尝试从markdown代码块中提取JSON
      const extracted = this.extractJsonFromMarkdown(jsonText);
      if (extracted) {
        try {
          const parsed = JSON.parse(extracted);
          this.validatePlan(parsed);
          return parsed as AiDestinationPlan;
        } catch (e) {
          console.error('Failed to parse extracted JSON:', e);
        }
      }

      // 尝试修复截断的JSON
      const fixed = this.tryFixTruncatedJson(jsonText);
      if (fixed) {
        try {
          const parsed = JSON.parse(fixed);
          this.validatePlan(parsed);
          console.log('Successfully parsed fixed JSON');
          return parsed as AiDestinationPlan;
        } catch (e) {
          console.error('Failed to parse fixed JSON:', e);
        }
      }

      throw new Error(ErrorCode.AI_GENERATION_FAILED);
    }
  }

  /**
   * 从Markdown代码块中提取JSON
   */
  private extractJsonFromMarkdown(text: string): string | null {
    // 匹配 ```json ... ``` 或 ``` ... ```
    const jsonBlockRegex = /```(?:json)?\s*([\s\S]*?)\s*```/;
    const match = text.match(jsonBlockRegex);

    if (match && match[1]) {
      return match[1].trim();
    }

    // 尝试匹配裸JSON（以{开头，以}结尾）
    const nakedJsonRegex = /(\{[\s\S]*\})/;
    const nakedMatch = text.match(nakedJsonRegex);

    if (nakedMatch && nakedMatch[1]) {
      return nakedMatch[1].trim();
    }

    return null;
  }

  /**
   * 验证计划数据的完整性
   */
  private validatePlan(plan: any): void {
    const errors: string[] = [];

    // 检查必需字段
    if (!plan.tagline || typeof plan.tagline !== 'string') {
      errors.push('缺少tagline字段或类型错误');
    }

    if (!Array.isArray(plan.tags) || plan.tags.length !== 3) {
      errors.push('tags必须是包含3个元素的数组');
    }

    if (!plan.detailedDescription || typeof plan.detailedDescription !== 'string') {
      errors.push('缺少detailedDescription字段或类型错误');
    }

    if (!Array.isArray(plan.itineraries) || plan.itineraries.length === 0) {
      errors.push('itineraries必须是非空数组');
    }

    if (!Array.isArray(plan.packingItems)) {
      errors.push('packingItems必须是数组');
    }

    if (!Array.isArray(plan.todoChecklist)) {
      errors.push('todoChecklist必须是数组');
    }

    // 验证行程数据
    if (Array.isArray(plan.itineraries)) {
      plan.itineraries.forEach((day: any, index: number) => {
        if (!day.dayNumber || !day.date || !day.title) {
          errors.push(`第${index + 1}天的行程缺少必需字段`);
        }
        if (!Array.isArray(day.activities) || day.activities.length === 0) {
          errors.push(`第${index + 1}天的行程没有活动`);
        }
      });
    }

    if (errors.length > 0) {
      console.error('Plan validation errors:', errors);
      throw new Error(`AI生成的数据不完整: ${errors.join('; ')}`);
    }
  }

  /**
   * 尝试修复截断的JSON
   */
  private tryFixTruncatedJson(jsonText: string): string | null {
    try {
      // 查找最后一个完整的闭合点
      let fixed = jsonText.trim();

      // 移除末尾的不完整字符串
      fixed = fixed.replace(/,?\s*"[^"]*$/g, '');

      // 计算需要闭合的括号和数组
      let openBraces = 0;
      let openBrackets = 0;
      let inString = false;
      let escaped = false;

      for (let i = 0; i < fixed.length; i++) {
        const char = fixed[i];

        if (escaped) {
          escaped = false;
          continue;
        }

        if (char === '\\') {
          escaped = true;
          continue;
        }

        if (char === '"') {
          inString = !inString;
          continue;
        }

        if (inString) continue;

        if (char === '{') openBraces++;
        if (char === '}') openBraces--;
        if (char === '[') openBrackets++;
        if (char === ']') openBrackets--;
      }

      // 移除末尾的逗号
      fixed = fixed.replace(/,\s*$/, '');

      // 添加必要的闭合括号
      while (openBrackets > 0) {
        fixed += ']';
        openBrackets--;
      }

      while (openBraces > 0) {
        fixed += '}';
        openBraces--;
      }

      return fixed;
    } catch (error) {
      console.error('Failed to fix truncated JSON:', error);
      return null;
    }
  }

  /**
   * 清理和标准化数据
   */
  sanitize(plan: AiDestinationPlan): AiDestinationPlan {
    return {
      tagline: plan.tagline.trim(),
      tags: plan.tags.map((tag) => tag.trim()).slice(0, 3), // 确保只有3个标签
      detailedDescription: plan.detailedDescription.trim(),
      country: plan.country.trim(),
      itineraries: plan.itineraries.map((day) => ({
        ...day,
        title: day.title.trim(),
        activities: day.activities.map((activity) => ({
          ...activity,
          title: activity.title.trim(),
          location: activity.location.trim(),
          description: activity.description.trim(),
        })),
      })),
      packingItems: plan.packingItems.map((item) => ({
        ...item,
        name: item.name.trim(),
        category: item.category.trim(),
        quantity: item.quantity || 1,
        isEssential: item.isEssential !== undefined ? item.isEssential : false,
      })),
      todoChecklist: plan.todoChecklist.map((item) => ({
        ...item,
        title: item.title.trim(),
        description: item.description?.trim(),
        priority: item.priority || 'medium',
      })),
    };
  }
}
