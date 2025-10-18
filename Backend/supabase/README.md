# Supabase 数据库配置指南

## 概述

本目录包含GliTrip AI Planning功能的数据库迁移文件。我们使用Supabase作为PostgreSQL数据库，但不使用其Auth服务，而是实现自定义JWT认证。

## 数据库表结构

### 1. users（用户表）
- **用途**：存储用户账号信息和订阅状态
- **主要字段**：
  - `id`: UUID主键
  - `email`: 邮箱（唯一）
  - `password_hash`: bcrypt哈希后的密码
  - `display_name`: 显示名称
  - `subscription_type`: 订阅类型（free/vip）
  - `subscription_start_date`: 订阅开始日期
  - `subscription_end_date`: 订阅结束日期

### 2. subscriptions（订阅记录表）
- **用途**：记录用户的VIP订阅历史
- **主要字段**：
  - `user_id`: 关联用户ID
  - `type`: 订阅类型（vip）
  - `status`: 状态（active/expired/cancelled）
  - `price`: 价格
  - `start_date`/`end_date`: 订阅时间范围

### 3. user_usage（使用量统计表）
- **用途**：跟踪每个用户每年的AI规划使用次数
- **主要字段**：
  - `user_id`: 关联用户ID
  - `year`: 年份（如2025）
  - `ai_generation_count`: 已使用次数
  - `ai_generation_limit`: 限制次数（free=3, vip=1000）

### 4. ai_generations（AI生成历史表）
- **用途**：记录所有AI生成请求的详细信息
- **主要字段**：
  - `user_id`: 关联用户ID
  - `destination_name`/`country`: 目的地信息
  - `budget_level`: 预算级别
  - `status`: 生成状态（success/failed）
  - `tokens_used`: 使用的Token数量

## 部署步骤

### 方式1：使用Supabase Web界面

1. 登录到 [Supabase Dashboard](https://app.supabase.com)
2. 选择你的项目
3. 进入 "SQL Editor"
4. 复制 `migrations/001_initial_schema.sql` 的内容
5. 粘贴并执行

### 方式2：使用Supabase CLI

```bash
# 安装Supabase CLI
npm install -g supabase

# 登录
supabase login

# 链接到你的项目
supabase link --project-ref your-project-ref

# 执行迁移
supabase db push
```

### 方式3：使用psql命令行

```bash
# 从Supabase获取连接字符串
# 格式: postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres

psql "postgresql://postgres:your-password@db.your-project.supabase.co:5432/postgres" \
  -f migrations/001_initial_schema.sql
```

## 验证部署

执行以下SQL查询验证表是否创建成功：

```sql
-- 检查所有表
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('users', 'subscriptions', 'user_usage', 'ai_generations');

-- 检查索引
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('users', 'subscriptions', 'user_usage', 'ai_generations');

-- 检查函数
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('update_updated_at_column', 'decrement_usage');
```

## 环境变量配置

在后端项目中需要配置以下环境变量：

```env
# Supabase配置
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# 说明：
# - SUPABASE_URL: 项目URL（在Project Settings > API中找到）
# - SUPABASE_SERVICE_ROLE_KEY: 服务角色密钥（在Project Settings > API中找到）
#   注意：使用service_role key而非anon key，因为我们不使用RLS
```

## 安全注意事项

1. **不要使用RLS**：本项目不启用Row Level Security，所有权限控制在后端API层实现
2. **保护service_role key**：该密钥具有完全数据库访问权限，绝不能暴露在前端
3. **使用强密码**：确保用户密码经过bcrypt哈希，成本因子至少为10
4. **JWT密钥安全**：后端的JWT_SECRET必须是强随机字符串

## 测试数据

### 创建测试用户

```sql
-- 密码: password123
INSERT INTO public.users (email, password_hash, display_name, subscription_type)
VALUES (
  'test@example.com',
  '$2a$10$N9qo8uL/rYp7h3p8/tJ5P.O9R6p3p8/tJ5P.O9R6p3p8/tJ5P.O9R6',
  '测试用户',
  'free'
);

-- 密码: vipuser123
INSERT INTO public.users (email, password_hash, display_name, subscription_type, subscription_end_date)
VALUES (
  'vip@example.com',
  '$2a$10$M8po9tK/rYp7h3p8/tJ5P.O9R6p3p8/tJ5P.O9R6p3p8/tJ5P.O9R6',
  'VIP用户',
  'vip',
  '2026-12-31 23:59:59+00'
);
```

### 查询统计数据

```sql
-- 查看所有用户及其订阅状态
SELECT
  id,
  email,
  display_name,
  subscription_type,
  subscription_end_date,
  created_at
FROM public.users
ORDER BY created_at DESC;

-- 查看使用量统计
SELECT
  u.email,
  uu.year,
  uu.ai_generation_count,
  uu.ai_generation_limit,
  (uu.ai_generation_limit - uu.ai_generation_count) as remaining
FROM public.user_usage uu
JOIN public.users u ON u.id = uu.user_id
ORDER BY uu.year DESC, u.email;

-- 查看AI生成历史
SELECT
  u.email,
  ag.destination_name,
  ag.country,
  ag.status,
  ag.tokens_used,
  ag.created_at
FROM public.ai_generations ag
JOIN public.users u ON u.id = ag.user_id
ORDER BY ag.created_at DESC
LIMIT 10;
```

## 维护操作

### 重置用户使用量（新年度）

```sql
-- 对所有用户重置到下一年的使用量
INSERT INTO public.user_usage (user_id, year, ai_generation_count, ai_generation_limit)
SELECT
  id,
  EXTRACT(YEAR FROM NOW())::INTEGER,
  0,
  CASE subscription_type
    WHEN 'vip' THEN 1000
    ELSE 3
  END
FROM public.users
ON CONFLICT (user_id, year) DO NOTHING;
```

### 清理过期订阅

```sql
-- 更新过期订阅状态
UPDATE public.subscriptions
SET status = 'expired'
WHERE status = 'active' AND end_date < NOW();

-- 将过期VIP用户降级为免费用户
UPDATE public.users
SET
  subscription_type = 'free',
  subscription_start_date = NULL,
  subscription_end_date = NULL
WHERE subscription_type = 'vip' AND subscription_end_date < NOW();
```

## 备份建议

1. 使用Supabase的自动备份功能（Pro计划及以上）
2. 定期导出关键数据：
   ```bash
   pg_dump -h db.your-project.supabase.co -U postgres -d postgres \
     -t public.users -t public.subscriptions -t public.user_usage \
     -f backup_$(date +%Y%m%d).sql
   ```

## 支持

如有问题，请参考：
- [Supabase文档](https://supabase.com/docs)
- [PostgreSQL文档](https://www.postgresql.org/docs/)
