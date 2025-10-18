/**
 * Prompt Builder Service
 *
 * 构建发送给Gemini API的提示词
 */

import { PlanningContext } from '../../models';

export class PromptBuilderService {
  /**
   * 构建完整的Prompt
   */
  build(context: PlanningContext): string {
    const language = context.language || 'zh'; // 默认中文

    // 根据语言选择不同的Prompt模板
    if (language === 'en') {
      return this.buildEnglishPrompt(context);
    } else {
      return this.buildChinesePrompt(context);
    }
  }

  /**
   * 构建中文Prompt
   */
  private buildChinesePrompt(context: PlanningContext): string {
    const days = this.calculateDays(context.startDate, context.endDate);
    const budgetText = this.getBudgetLevelText(context.budgetLevel, 'zh');
    const destinationInfo = context.country
      ? `${context.destinationName}, ${context.country}`
      : context.destinationName;

    return `
你是一位专业的旅行规划师，请为以下旅行生成详细的规划方案。

## 旅行信息
- 目的地：${destinationInfo}
- 预算级别：${budgetText}
- 开始日期：${context.startDate}
- 结束日期：${context.endDate}
- 旅行天数：${days}天

## 生成要求

请严格按照以下JSON格式返回结果，确保是有效的JSON：

\`\`\`json
{
  "tagline": "一句话特色描述（20字以内）",
  "tags": ["标签1", "标签2", "标签3"],
  "detailedDescription": "详细描述（200-300字）",
  "country": "目的地所在国家",
  "itineraries": [
    {
      "dayNumber": 1,
      "date": "2025-07-01",
      "title": "第一天标题",
      "activities": [
        {
          "title": "活动名称",
          "startTime": "09:00",
          "endTime": "11:00",
          "location": "具体地点",
          "description": "活动描述",
          "estimatedCost": 150
        }
      ]
    }
  ],
  "packingItems": [
    {
      "name": "物品名称",
      "category": "clothing",
      "quantity": 2,
      "isEssential": true
    }
  ],
  "todoChecklist": [
    {
      "title": "待办事项",
      "description": "详细说明",
      "priority": "high"
    }
  ]
}
\`\`\`

## 详细要求

### 1. 一句话特色描述（tagline）
- 简洁有力，20字以内
- 突出目的地最大特色
- 富有感染力和吸引力

### 2. 标签（tags）
- 必须提供恰好3个标签
- 反映目的地的核心特征（如：浪漫、艺术、美食、自然、历史等）
- 中文标签

### 3. 详细描述（detailedDescription）
- 200-300字
- 包含目的地历史、文化、特色景点、美食、氛围等
- 生动形象，激发旅行欲望

### 4. 国家（country）
- 识别目的地所在的国家名称
- 使用标准中文国家名称（如：日本、法国、美国等）
- 如果目的地本身就是国家，则返回该国家名称

### 5. 行程规划（itineraries）
- 为每一天生成详细行程
- 每天3-5个活动
- 活动时间要合理，考虑交通和休息
- 根据预算级别调整住宿、餐饮、活动选择：
  - 高预算：五星酒店、米其林餐厅、私人导览
  - 中预算：四星酒店、特色餐厅、热门景点
  - 低预算：经济型酒店、当地小吃、免费景点
- estimatedCost单位为人民币（CNY）

### 6. 打包物品（packingItems）
- 根据目的地气候、季节、活动类型定制
- category可选值：clothing（衣物）, electronics（电子产品）, cosmetics（化妆品）, health（健康用品）, accessories（配件）, books（书籍）, entertainment（娱乐）, other（其他）
- 标注是否必需（isEssential）
- 提供15-25个物品

### 7. 待办事项（todoChecklist）
- 包含出行前必须完成的事项
- 如：订机票、订酒店、办签证、购买保险、兑换货币、预订餐厅等
- priority可选值：high（高）, medium（中）, low（低）
- 提供6-10个待办事项

## 注意事项
1. 所有费用单位为人民币（CNY）
2. 时间格式严格遵守要求（日期：YYYY-MM-DD，时间：HH:MM）
3. 确保返回的是有效的JSON格式
4. 行程要符合实际，考虑交通时间和体力安排
5. 根据预算级别调整所有建议的档次和价格
6. 使用中文回答

请现在生成这个旅行规划。
`.trim();
  }

  /**
   * 计算旅行天数
   */
  private calculateDays(startDate: string, endDate: string): number {
    const start = new Date(startDate);
    const end = new Date(endDate);
    const diffTime = Math.abs(end.getTime() - start.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays + 1; // 包含开始和结束日期
  }

  /**
   * 构建英文Prompt
   */
  private buildEnglishPrompt(context: PlanningContext): string {
    const days = this.calculateDays(context.startDate, context.endDate);
    const budgetText = this.getBudgetLevelText(context.budgetLevel, 'en');
    const destinationInfo = context.country
      ? `${context.destinationName}, ${context.country}`
      : context.destinationName;

    return `
You are a professional travel planner. Please generate a detailed travel plan for the following trip.

## Trip Information
- Destination: ${destinationInfo}
- Budget Level: ${budgetText}
- Start Date: ${context.startDate}
- End Date: ${context.endDate}
- Duration: ${days} days

## Requirements

Please return the result strictly in the following JSON format, ensuring it is valid JSON:

\`\`\`json
{
  "tagline": "One-sentence feature description (within 50 characters)",
  "tags": ["Tag1", "Tag2", "Tag3"],
  "detailedDescription": "Detailed description (200-300 words)",
  "country": "Country where the destination is located",
  "itineraries": [
    {
      "dayNumber": 1,
      "date": "2025-07-01",
      "title": "Day 1 Title",
      "activities": [
        {
          "title": "Activity Name",
          "startTime": "09:00",
          "endTime": "11:00",
          "location": "Specific Location",
          "description": "Activity Description",
          "estimatedCost": 150
        }
      ]
    }
  ],
  "packingItems": [
    {
      "name": "Item Name",
      "category": "clothing",
      "quantity": 2,
      "isEssential": true
    }
  ],
  "todoChecklist": [
    {
      "title": "To-do Item",
      "description": "Detailed Description",
      "priority": "high"
    }
  ]
}
\`\`\`

## Detailed Requirements

### 1. Tagline
- Concise and powerful, within 50 characters
- Highlight the destination's main feature
- Attractive and engaging

### 2. Tags
- Provide exactly 3 tags
- Reflect the core characteristics of the destination (e.g., romantic, artistic, culinary, natural, historical, etc.)
- Use English tags

### 3. Detailed Description
- 200-300 words
- Include the destination's history, culture, featured attractions, cuisine, atmosphere, etc.
- Vivid and inspiring

### 4. Country
- Identify the country where the destination is located
- Use standard English country names (e.g., Japan, France, United States, etc.)
- If the destination itself is a country, return that country name

### 5. Itinerary Planning
- Generate detailed itinerary for each day
- 3-5 activities per day
- Activity times should be reasonable, considering transportation and rest
- Adjust accommodation, dining, and activity choices based on budget level:
  - High budget: 5-star hotels, Michelin restaurants, private tours
  - Medium budget: 4-star hotels, specialty restaurants, popular attractions
  - Low budget: Budget hotels, local street food, free attractions
- estimatedCost in CNY (Chinese Yuan)

### 6. Packing Items
- Customized based on destination climate, season, and activity types
- category options: clothing, electronics, cosmetics, health, accessories, books, entertainment, other
- Mark if essential (isEssential)
- Provide 15-25 items

### 7. To-do Checklist
- Include essential tasks to complete before the trip
- Such as: book flights, book hotels, apply for visa, buy insurance, exchange currency, reserve restaurants, etc.
- priority options: high, medium, low
- Provide 6-10 to-do items

## Important Notes
1. All costs in CNY (Chinese Yuan)
2. Strictly follow time formats (Date: YYYY-MM-DD, Time: HH:MM)
3. Ensure the returned JSON is valid
4. Itinerary should be realistic, considering travel time and physical arrangement
5. Adjust all suggestions' level and prices based on budget level
6. Use English for all responses

Please generate this travel plan now.
`.trim();
  }

  /**
   * 获取预算级别文本
   */
  private getBudgetLevelText(level: string, language: 'zh' | 'en' = 'zh'): string {
    const budgetMapZh: Record<string, string> = {
      high: '高预算（奢华游）',
      medium: '中等预算（舒适游）',
      low: '低预算（经济游）',
    };

    const budgetMapEn: Record<string, string> = {
      high: 'High Budget (Luxury Travel)',
      medium: 'Medium Budget (Comfortable Travel)',
      low: 'Low Budget (Budget Travel)',
    };

    const budgetMap = language === 'en' ? budgetMapEn : budgetMapZh;
    return budgetMap[level] || (language === 'en' ? 'Medium Budget' : '中等预算');
  }
}
