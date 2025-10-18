# GliTrip Backend - 完整实现指南

本文档提供了完成Backend所有代码的详细步骤和代码实现。您可以按照此指南逐步实现剩余的代码文件。

## 📋 当前已完成的文件

✅ 数据库迁移文件和文档
✅ 项目配置文件（package.json, tsconfig.json, .env.example）
✅ 所有配置模块（supabase, gemini, constants）
✅ 所有数据模型（user, ai-plan, subscription, api-response）
✅ JWT认证服务（auth.service.ts）

## 🔨 待实现的文件清单

### 优先级1：核心中间件（必须完成）

#### 1. JWT认证中间件
**文件**: `src/middleware/auth.middleware.ts`

```typescript
import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth/auth.service';
import { ErrorCode, HttpStatus } from '../config/constants';
import { createErrorResponse } from '../models';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
  };
}

const authService = new AuthService();

export const authenticateUser = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
      return res
        .status(HttpStatus.UNAUTHORIZED)
        .json(createErrorResponse(ErrorCode.UNAUTHORIZED, '未提供认证令牌'));
    }

    const token = authHeader.substring(7);
    const decoded = authService.verifyToken(token);

    req.user = {
      id: decoded.userId,
      email: decoded.email,
    };

    next();
  } catch (error: any) {
    return res
      .status(HttpStatus.UNAUTHORIZED)
      .json(
        createErrorResponse(
          error.message === ErrorCode.TOKEN_EXPIRED
            ? ErrorCode.TOKEN_EXPIRED
            : ErrorCode.INVALID_TOKEN,
          error.message === ErrorCode.TOKEN_EXPIRED
            ? '令牌已过期，请重新登录'
            : '无效的认证令牌'
        )
      );
  }
};
```

---

#### 2. 错误处理中间件
**文件**: `src/middleware/error-handler.middleware.ts`

```typescript
import { Request, Response, NextFunction } from 'express';
import { ErrorCode, HttpStatus } from '../config/constants';
import { createErrorResponse } from '../models';

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error:', err);

  // 已知错误码
  const errorCodeToStatus: Record<string, number> = {
    [ErrorCode.UNAUTHORIZED]: HttpStatus.UNAUTHORIZED,
    [ErrorCode.INVALID_TOKEN]: HttpStatus.UNAUTHORIZED,
    [ErrorCode.TOKEN_EXPIRED]: HttpStatus.UNAUTHORIZED,
    [ErrorCode.USER_NOT_FOUND]: HttpStatus.NOT_FOUND,
    [ErrorCode.USER_ALREADY_EXISTS]: HttpStatus.CONFLICT,
    [ErrorCode.INVALID_CREDENTIALS]: HttpStatus.UNAUTHORIZED,
    [ErrorCode.QUOTA_EXCEEDED]: HttpStatus.FORBIDDEN,
    [ErrorCode.AI_GENERATION_FAILED]: HttpStatus.INTERNAL_SERVER_ERROR,
    [ErrorCode.INVALID_INPUT]: HttpStatus.BAD_REQUEST,
    [ErrorCode.VALIDATION_ERROR]: HttpStatus.BAD_REQUEST,
  };

  const statusCode =
    errorCodeToStatus[err.message] || HttpStatus.INTERNAL_SERVER_ERROR;
  const errorCode = err.message || ErrorCode.INTERNAL_ERROR;
  const message =
    statusCode === HttpStatus.INTERNAL_SERVER_ERROR
      ? '服务器内部错误'
      : err.message;

  res.status(statusCode).json(createErrorResponse(errorCode, message));
};
```

---

#### 3. 请求验证中间件
**文件**: `src/middleware/validation.middleware.ts`

```typescript
import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { HttpStatus } from '../config/constants';
import { createErrorResponse } from '../models';

export const validateRequest = (schema: Joi.Schema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body, { abortEarly: false });

    if (error) {
      const errorMessages = error.details.map((detail) => detail.message);
      return res
        .status(HttpStatus.BAD_REQUEST)
        .json(
          createErrorResponse('VALIDATION_ERROR', '请求验证失败', errorMessages)
        );
    }

    next();
  };
};

// 验证规则
export const registerSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': '请输入有效的邮箱地址',
    'any.required': '邮箱为必填项',
  }),
  password: Joi.string().min(8).required().messages({
    'string.min': '密码至少需要8个字符',
    'any.required': '密码为必填项',
  }),
  displayName: Joi.string().optional(),
});

export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

export const generatePlanSchema = Joi.object({
  destinationName: Joi.string().required().messages({
    'any.required': '目的地名称为必填项',
  }),
  country: Joi.string().required().messages({
    'any.required': '国家为必填项',
  }),
  budgetLevel: Joi.string().valid('high', 'medium', 'low').required(),
  startDate: Joi.string()
    .pattern(/^\d{4}-\d{2}-\d{2}$/)
    .required()
    .messages({
      'string.pattern.base': '开始日期格式必须为 YYYY-MM-DD',
    }),
  endDate: Joi.string()
    .pattern(/^\d{4}-\d{2}-\d{2}$/)
    .required()
    .messages({
      'string.pattern.base': '结束日期格式必须为 YYYY-MM-DD',
    }),
});
```

---

### 优先级2：业务服务层（核心逻辑）

#### 4. 用户服务
**文件**: `src/services/user/user.service.ts`

```typescript
import { supabase } from '../../config/supabase.config';
import { User, SafeUser, sanitizeUser } from '../../models';
import { PlanningContext } from '../../models';
import { ErrorCode } from '../../config/constants';

export class UserService {
  /**
   * 通过ID获取用户
   */
  async getUser(userId: string): Promise<SafeUser | null> {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return null; // 未找到
      throw new Error(ErrorCode.DATABASE_ERROR);
    }

    return sanitizeUser(data as User);
  }

  /**
   * 更新用户订阅状态
   */
  async updateSubscription(
    userId: string,
    subscriptionType: 'free' | 'vip',
    startDate?: Date,
    endDate?: Date
  ): Promise<void> {
    const { error } = await supabase
      .from('users')
      .update({
        subscription_type: subscriptionType,
        subscription_start_date: startDate?.toISOString(),
        subscription_end_date: endDate?.toISOString(),
      })
      .eq('id', userId);

    if (error) {
      throw new Error(ErrorCode.DATABASE_ERROR);
    }
  }

  /**
   * 记录AI生成历史
   */
  async recordAiGeneration(
    userId: string,
    context: PlanningContext,
    status: 'success' | 'failed',
    errorMessage?: string,
    tokensUsed?: number
  ): Promise<void> {
    const { error } = await supabase.from('ai_generations').insert({
      user_id: userId,
      destination_name: context.destinationName,
      country: context.country,
      budget_level: context.budgetLevel,
      start_date: context.startDate,
      end_date: context.endDate,
      status,
      error_message: errorMessage,
      tokens_used: tokensUsed,
    });

    if (error) {
      console.error('Failed to record AI generation:', error);
      // 不抛出错误，避免影响主流程
    }
  }
}
```

---

#### 5. 使用量服务
**文件**: `src/services/user/usage.service.ts`

```typescript
import { supabase } from '../../config/supabase.config';
import { USAGE_LIMITS } from '../../config/constants';
import { UserUsage } from '../../models';

export class UsageService {
  /**
   * 检查并扣除使用次数
   */
  async checkAndDeductUsage(
    userId: string,
    subscriptionType: 'free' | 'vip'
  ): Promise<{ allowed: boolean; remaining: number; limit: number }> {
    const year = new Date().getFullYear();
    const limit = USAGE_LIMITS[subscriptionType];

    try {
      // 查询当前使用量
      const { data: usage, error: fetchError } = await supabase
        .from('user_usage')
        .select('*')
        .eq('user_id', userId)
        .eq('year', year)
        .single();

      if (fetchError && fetchError.code !== 'PGRST116') {
        throw fetchError;
      }

      // 如果没有记录，创建新记录
      if (!usage) {
        const { error: insertError } = await supabase
          .from('user_usage')
          .insert({
            user_id: userId,
            year,
            ai_generation_count: 1,
            ai_generation_limit: limit,
          });

        if (insertError) throw insertError;

        return { allowed: true, remaining: limit - 1, limit };
      }

      // 检查是否超限
      if (usage.ai_generation_count >= limit) {
        return { allowed: false, remaining: 0, limit };
      }

      // 扣除使用次数
      const { error: updateError } = await supabase
        .from('user_usage')
        .update({
          ai_generation_count: usage.ai_generation_count + 1,
        })
        .eq('user_id', userId)
        .eq('year', year);

      if (updateError) throw updateError;

      return {
        allowed: true,
        remaining: limit - usage.ai_generation_count - 1,
        limit,
      };
    } catch (error) {
      console.error('检查使用量失败:', error);
      throw new Error('无法检查使用量');
    }
  }

  /**
   * 获取使用量
   */
  async getUsage(userId: string): Promise<UserUsage | null> {
    const year = new Date().getFullYear();

    const { data, error } = await supabase
      .from('user_usage')
      .select('*')
      .eq('user_id', userId)
      .eq('year', year)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return null;
      throw error;
    }

    return data;
  }

  /**
   * 退还使用次数（用于失败回滚）
   */
  async refundUsage(userId: string): Promise<void> {
    const year = new Date().getFullYear();

    const { error } = await supabase.rpc('decrement_usage', {
      p_user_id: userId,
      p_year: year,
    });

    if (error) {
      console.error('退还使用次数失败:', error);
    }
  }
}
```

---

### 优先级3：AI服务实现（核心功能）

我将继续在下一部分提供AI服务、控制器、路由和应用入口的完整实现代码...

## ⚡ 快速启动指南（不完整代码也能测试）

即使代码未完全实现，您也可以：

1. **先部署数据库**：执行SQL迁移文件
2. **测试认证服务**：auth.service.ts 已完成，可以单独测试
3. **逐步添加功能**：按照本文档的实现指南，逐个文件添加

## 📞 需要帮助？

如果您希望我继续创建剩余的文件（AI服务、控制器、路由等），请告诉我，我将继续为您生成完整的代码实现。

或者，您可以参考此实现指南自行完成剩余代码。每个文件的结构和逻辑都已清楚说明。
