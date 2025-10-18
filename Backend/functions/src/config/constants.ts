/**
 * Application Constants
 */

import dotenv from 'dotenv';

dotenv.config();

/**
 * 使用量限制
 */
export const USAGE_LIMITS = {
  free: parseInt(process.env.FREE_USER_LIMIT || '3', 10),
  vip: parseInt(process.env.VIP_USER_LIMIT || '1000', 10),
} as const;

/**
 * JWT配置
 */
export const JWT_CONFIG = {
  secret: (process.env.JWT_SECRET || 'change-this-in-production') as string,
  expiresIn: (process.env.JWT_EXPIRES_IN || '7d') as string,
};

/**
 * Bcrypt配置
 */
export const BCRYPT_ROUNDS = 10;

/**
 * 速率限制配置
 */
export const RATE_LIMIT_CONFIG = {
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10), // 15分钟
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10), // 最多100次请求
  message: '请求过于频繁，请稍后再试',
};

/**
 * CORS配置
 */
export const CORS_CONFIG = {
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
};

/**
 * 日志级别
 */
export const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

/**
 * 订阅类型
 */
export enum SubscriptionType {
  FREE = 'free',
  VIP = 'vip',
}

/**
 * 订阅状态
 */
export enum SubscriptionStatus {
  ACTIVE = 'active',
  EXPIRED = 'expired',
  CANCELLED = 'cancelled',
}

/**
 * 预算级别
 */
export enum BudgetLevel {
  HIGH = 'high',
  MEDIUM = 'medium',
  LOW = 'low',
}

/**
 * AI生成状态
 */
export enum GenerationStatus {
  SUCCESS = 'success',
  FAILED = 'failed',
}

/**
 * 错误代码
 */
export enum ErrorCode {
  // 认证错误
  UNAUTHORIZED = 'UNAUTHORIZED',
  INVALID_TOKEN = 'INVALID_TOKEN',
  TOKEN_EXPIRED = 'TOKEN_EXPIRED',

  // 用户错误
  USER_NOT_FOUND = 'USER_NOT_FOUND',
  USER_ALREADY_EXISTS = 'USER_ALREADY_EXISTS',
  INVALID_CREDENTIALS = 'INVALID_CREDENTIALS',

  // 配额错误
  QUOTA_EXCEEDED = 'QUOTA_EXCEEDED',

  // AI错误
  AI_GENERATION_FAILED = 'AI_GENERATION_FAILED',
  INVALID_INPUT = 'INVALID_INPUT',

  // 系统错误
  INTERNAL_ERROR = 'INTERNAL_ERROR',
  DATABASE_ERROR = 'DATABASE_ERROR',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
}

/**
 * HTTP状态码
 */
export enum HttpStatus {
  OK = 200,
  CREATED = 201,
  BAD_REQUEST = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  CONFLICT = 409,
  TOO_MANY_REQUESTS = 429,
  INTERNAL_SERVER_ERROR = 500,
}
