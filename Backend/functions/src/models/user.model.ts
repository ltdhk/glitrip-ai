/**
 * User Model
 */

export interface User {
  id: string;
  email: string;
  password_hash: string;
  display_name: string;
  subscription_type: 'free' | 'vip';
  subscription_start_date: string | null;
  subscription_end_date: string | null;
  created_at: string;
  updated_at: string;
}

/**
 * 安全的用户模型（不包含密码）
 */
export interface SafeUser {
  id: string;
  email: string;
  display_name: string;
  subscription_type: 'free' | 'vip';
  subscription_start_date: string | null;
  subscription_end_date: string | null;
  created_at: string;
  updated_at: string;
}

/**
 * 用户注册请求
 */
export interface RegisterRequest {
  email: string;
  password: string;
  display_name?: string;
}

/**
 * 用户登录请求
 */
export interface LoginRequest {
  email: string;
  password: string;
}

/**
 * 认证响应
 */
export interface AuthResponse {
  user: SafeUser;
  token: string;
}

/**
 * JWT Token Payload
 */
export interface TokenPayload {
  userId: string;
  email: string;
  iat?: number;
  exp?: number;
}

/**
 * 从User转换为SafeUser（移除密码）
 */
export function sanitizeUser(user: User): SafeUser {
  const { password_hash, ...safeUser } = user;
  return safeUser;
}
