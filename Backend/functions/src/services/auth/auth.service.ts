/**
 * Authentication Service
 *
 * 处理用户注册、登录和JWT Token生成/验证
 */

import bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';
import { supabase } from '../../config/supabase.config';
import { JWT_CONFIG, BCRYPT_ROUNDS, ErrorCode } from '../../config/constants';
import {
  User,
  SafeUser,
  sanitizeUser,
  TokenPayload,
  AuthResponse,
  RegisterRequest,
  LoginRequest,
} from '../../models';

export class AuthService {
  /**
   * 用户注册
   */
  async register(request: RegisterRequest): Promise<AuthResponse> {
    const { email, password, display_name } = request;

    // 验证输入
    this.validateEmail(email);
    this.validatePassword(password);

    // 检查用户是否已存在
    const { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .single();

    if (existingUser) {
      throw new Error(ErrorCode.USER_ALREADY_EXISTS);
    }

    // 哈希密码
    const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);

    // 创建用户
    const { data: user, error } = await supabase
      .from('users')
      .insert({
        email,
        password_hash: passwordHash,
        display_name: display_name || '旅行家',
        subscription_type: 'free',
      })
      .select()
      .single();

    if (error || !user) {
      console.error('User registration failed:', error);
      throw new Error(ErrorCode.DATABASE_ERROR);
    }

    // 生成JWT Token
    const token = this.generateToken(user.id, email);

    return {
      user: sanitizeUser(user as User),
      token,
    };
  }

  /**
   * 用户登录
   */
  async login(request: LoginRequest): Promise<AuthResponse> {
    const { email, password } = request;

    // 查询用户
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error || !user) {
      throw new Error(ErrorCode.INVALID_CREDENTIALS);
    }

    // 验证密码
    const isValidPassword = await bcrypt.compare(password, user.password_hash);

    if (!isValidPassword) {
      throw new Error(ErrorCode.INVALID_CREDENTIALS);
    }

    // 生成JWT Token
    const token = this.generateToken(user.id, email);

    return {
      user: sanitizeUser(user as User),
      token,
    };
  }

  /**
   * 生成JWT Token
   */
  generateToken(userId: string, email: string): string {
    const payload: TokenPayload = {
      userId,
      email,
    };

    // @ts-ignore - TypeScript type mismatch with jwt.sign expiresIn
    return jwt.sign(payload, JWT_CONFIG.secret, {
      expiresIn: JWT_CONFIG.expiresIn,
    });
  }

  /**
   * 验证JWT Token
   */
  verifyToken(token: string): TokenPayload {
    try {
      const decoded = jwt.verify(token, JWT_CONFIG.secret) as TokenPayload;
      return decoded;
    } catch (error: any) {
      if (error.name === 'TokenExpiredError') {
        throw new Error(ErrorCode.TOKEN_EXPIRED);
      }
      throw new Error(ErrorCode.INVALID_TOKEN);
    }
  }

  /**
   * 通过Token获取用户信息
   */
  async getUserByToken(token: string): Promise<SafeUser> {
    const decoded = this.verifyToken(token);

    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('id', decoded.userId)
      .single();

    if (error || !user) {
      throw new Error(ErrorCode.USER_NOT_FOUND);
    }

    return sanitizeUser(user as User);
  }

  /**
   * 验证邮箱格式
   */
  private validateEmail(email: string): void {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new Error(ErrorCode.VALIDATION_ERROR);
    }
  }

  /**
   * 验证密码强度
   */
  private validatePassword(password: string): void {
    if (password.length < 8) {
      throw new Error('密码至少需要8个字符');
    }
  }
}
