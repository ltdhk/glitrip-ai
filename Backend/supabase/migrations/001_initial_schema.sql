-- ================================================
-- GliTrip AI Planning - Initial Database Schema
-- ================================================
-- 创建时间: 2025-01-17
-- 说明: 用户、订阅、使用量和AI生成历史表

-- ================================================
-- 1. 用户表 (users)
-- ================================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  display_name TEXT DEFAULT '旅行家',
  subscription_type TEXT NOT NULL DEFAULT 'free' CHECK (subscription_type IN ('free', 'vip')),
  subscription_start_date TIMESTAMPTZ,
  subscription_end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_subscription_type ON public.users(subscription_type);
CREATE INDEX IF NOT EXISTS idx_users_subscription_end ON public.users(subscription_end_date);

-- ================================================
-- 2. 订阅记录表 (subscriptions)
-- ================================================
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL DEFAULT 'vip' CHECK (type IN ('vip')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
  price DECIMAL(10, 2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'CNY',
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  payment_method TEXT,
  transaction_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_end_date ON public.subscriptions(end_date);

-- ================================================
-- 3. 使用量统计表 (user_usage)
-- ================================================
CREATE TABLE IF NOT EXISTS public.user_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  year INTEGER NOT NULL,
  ai_generation_count INTEGER NOT NULL DEFAULT 0,
  ai_generation_limit INTEGER NOT NULL DEFAULT 3,
  last_reset_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, year)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_user_usage_user_year ON public.user_usage(user_id, year);

-- ================================================
-- 4. AI生成历史表 (ai_generations)
-- ================================================
CREATE TABLE IF NOT EXISTS public.ai_generations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  destination_name TEXT NOT NULL,
  country TEXT NOT NULL,
  budget_level TEXT NOT NULL CHECK (budget_level IN ('high', 'medium', 'low')),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('success', 'failed')),
  tokens_used INTEGER,
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_ai_generations_user_id ON public.ai_generations(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_generations_created_at ON public.ai_generations(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_generations_status ON public.ai_generations(status);

-- ================================================
-- 5. 触发器和函数
-- ================================================

-- 自动更新 updated_at 字段的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为 users 表创建触发器
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 为 user_usage 表创建触发器
DROP TRIGGER IF EXISTS update_user_usage_updated_at ON public.user_usage;
CREATE TRIGGER update_user_usage_updated_at
  BEFORE UPDATE ON public.user_usage
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ================================================
-- 6. 辅助函数 - 减少使用次数（用于退款）
-- ================================================
CREATE OR REPLACE FUNCTION decrement_usage(p_user_id UUID, p_year INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE public.user_usage
  SET ai_generation_count = GREATEST(ai_generation_count - 1, 0),
      updated_at = NOW()
  WHERE user_id = p_user_id AND year = p_year;
END;
$$ LANGUAGE plpgsql;

-- ================================================
-- 7. 初始化测试数据（可选，生产环境请删除）
-- ================================================
-- 插入测试用户（密码: password123，已使用bcrypt哈希）
-- INSERT INTO public.users (email, password_hash, display_name, subscription_type)
-- VALUES ('test@example.com', '$2a$10$examplehash', '测试用户', 'free');

-- ================================================
-- 完成
-- ================================================
-- 所有表、索引、触发器和函数已创建完成
