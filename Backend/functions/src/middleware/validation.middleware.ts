/**
 * Request Validation Middleware
 *
 * 使用Joi验证请求体
 */

import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import { HttpStatus } from '../config/constants';
import { createErrorResponse } from '../models';

/**
 * 通用验证中间件
 */
export const validateRequest = (schema: Joi.Schema): ((req: Request, res: Response, next: NextFunction) => void) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error } = schema.validate(req.body, {
      abortEarly: false, // 返回所有错误，而非第一个
      stripUnknown: true, // 移除未知字段
    });

    if (error) {
      const errorMessages = error.details.map((detail) => detail.message);
      res
        .status(HttpStatus.BAD_REQUEST)
        .json(
          createErrorResponse(
            'VALIDATION_ERROR',
            '请求验证失败',
            errorMessages
          )
        );
      return;
    }

    next();
  };
};

/**
 * 验证规则定义
 */

// 用户注册验证
export const registerSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': '请输入有效的邮箱地址',
    'any.required': '邮箱为必填项',
  }),
  password: Joi.string().min(8).max(128).required().messages({
    'string.min': '密码至少需要8个字符',
    'string.max': '密码不能超过128个字符',
    'any.required': '密码为必填项',
  }),
  displayName: Joi.string().max(50).optional().messages({
    'string.max': '显示名称不能超过50个字符',
  }),
});

// 用户登录验证
export const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': '请输入有效的邮箱地址',
    'any.required': '邮箱为必填项',
  }),
  password: Joi.string().required().messages({
    'any.required': '密码为必填项',
  }),
});

// AI生成规划验证
export const generatePlanSchema = Joi.object({
  destinationName: Joi.string().min(1).max(100).required().messages({
    'string.min': '目的地名称不能为空',
    'string.max': '目的地名称不能超过100个字符',
    'any.required': '目的地名称为必填项',
  }),
  country: Joi.string().min(1).max(100).optional().messages({
    'string.min': '国家名称不能为空',
    'string.max': '国家名称不能超过100个字符',
  }),
  budgetLevel: Joi.string()
    .valid('high', 'medium', 'low')
    .required()
    .messages({
      'any.only': '预算级别必须是 high、medium 或 low',
      'any.required': '预算级别为必填项',
    }),
  startDate: Joi.string()
    .pattern(/^\d{4}-\d{2}-\d{2}$/)
    .required()
    .messages({
      'string.pattern.base': '开始日期格式必须为 YYYY-MM-DD',
      'any.required': '开始日期为必填项',
    }),
  endDate: Joi.string()
    .pattern(/^\d{4}-\d{2}-\d{2}$/)
    .required()
    .messages({
      'string.pattern.base': '结束日期格式必须为 YYYY-MM-DD',
      'any.required': '结束日期为必填项',
    })
    .custom((value, helpers) => {
      const { startDate } = helpers.state.ancestors[0];
      if (new Date(value) <= new Date(startDate)) {
        return helpers.error('date.min');
      }
      return value;
    })
    .messages({
      'date.min': '结束日期必须晚于开始日期',
    }),
  language: Joi.string()
    .valid('zh', 'en')
    .default('zh')
    .messages({
      'any.only': '语言必须是 zh 或 en',
    }),
});

// 升级VIP验证
export const upgradeSchema = Joi.object({
  plan: Joi.string().valid('vip_yearly', 'vip_monthly').required().messages({
    'any.only': '订阅计划必须是 vip_yearly 或 vip_monthly',
    'any.required': '订阅计划为必填项',
  }),
  paymentMethod: Joi.string()
    .valid('alipay', 'wechat', 'stripe')
    .required()
    .messages({
      'any.only': '支付方式必须是 alipay、wechat 或 stripe',
      'any.required': '支付方式为必填项',
    }),
});
