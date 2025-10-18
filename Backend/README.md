# GliTrip Backend - AI行程规划服务

## 🎯 项目概述

GliTrip Backend是一个基于Node.js + TypeScript的RESTful API服务，为GliTrip Flutter应用提供AI智能行程规划功能。

### 核心功能
- ✅ 自定义JWT认证（不使用Firebase/Supabase Auth）
- ✅ Google Gemini API集成（AI生成行程）
- ✅ Supabase PostgreSQL数据库
- ✅ 使用量配额管理（免费用户3次/年，VIP用户1000次/年）
- ✅ VIP订阅系统
- ✅ 部署到Google Cloud Functions

## 📁 项目结构

```
Backend/
├── supabase/
│   ├── migrations/
│   │   └── 001_initial_schema.sql          # 数据库迁移文件
│   └── README.md                           # 数据库文档
│
├── functions/                              # Cloud Functions代码
│   ├── src/
│   │   ├── config/                         # 配置文件
│   │   │   ├── supabase.config.ts          # Supabase客户端
│   │   │   ├── gemini.config.ts            # Gemini AI配置
│   │   │   └── constants.ts                # 常量定义
│   │   │
│   │   ├── models/                         # 数据模型
│   │   │   ├── user.model.ts
│   │   │   ├── ai-plan.model.ts
│   │   │   ├── subscription.model.ts
│   │   │   ├── api-response.model.ts
│   │   │   └── index.ts
│   │   │
│   │   ├── services/                       # 业务逻辑层
│   │   │   ├── auth/
│   │   │   │   └── auth.service.ts         # 认证服务（已创建）
│   │   │   ├── user/
│   │   │   │   ├── user.service.ts         # 用户服务
│   │   │   │   ├── usage.service.ts        # 使用量服务
│   │   │   │   └── subscription.service.ts # 订阅服务
│   │   │   └── ai/
│   │   │       ├── gemini.service.ts       # Gemini API服务
│   │   │       ├── prompt-builder.service.ts # Prompt构建
│   │   │       └── plan-parser.service.ts  # 结果解析
│   │   │
│   │   ├── middleware/                     # 中间件
│   │   │   ├── auth.middleware.ts          # JWT验证
│   │   │   ├── error-handler.middleware.ts # 错误处理
│   │   │   └── validation.middleware.ts    # 请求验证
│   │   │
│   │   ├── controllers/                    # 控制器
│   │   │   ├── auth.controller.ts          # 认证控制器
│   │   │   ├── ai.controller.ts            # AI控制器
│   │   │   └── subscription.controller.ts  # 订阅控制器
│   │   │
│   │   ├── routes/                         # 路由
│   │   │   ├── auth.routes.ts
│   │   │   ├── ai.routes.ts
│   │   │   └── subscription.routes.ts
│   │   │
│   │   └── index.ts                        # 应用入口
│   │
│   ├── package.json                        # 依赖配置（已创建）
│   ├── tsconfig.json                       # TS配置（已创建）
│   ├── .env.example                        # 环境变量模板（已创建）
│   └── .gitignore                          # Git忽略（已创建）
│
└── README.md                               # 本文件
```

## 🚀 快速开始

### 前置要求

- Node.js >= 20.0.0
- npm >= 10.0.0
- Supabase账号
- Google Gemini API密钥
- Google Cloud账号（用于部署）

### 1. 安装依赖

```bash
cd Backend/functions
npm install
```

### 2. 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env` 文件，填入你的配置：

```env
# Supabase配置
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# JWT配置（生成强随机字符串）
JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
JWT_EXPIRES_IN=7d

# Google Gemini AI
GEMINI_API_KEY=your-gemini-api-key

# 其他配置
NODE_ENV=development
PORT=3000
```

### 3. 初始化数据库

访问Supabase Dashboard，在SQL Editor中执行：

```bash
# 打开文件
cat ../supabase/migrations/001_initial_schema.sql
```

复制内容并在Supabase执行。

### 4. 本地开发

```bash
npm run dev
```

服务器将在 `http://localhost:3000` 启动。

### 5. 测试API

```bash
# 注册用户
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "displayName": "测试用户"
  }'

# 登录
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

## 📡 API文档

### 认证相关

#### POST /api/v1/auth/register
注册新用户

**请求体：**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "displayName": "旅行家"
}
```

**响应：**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "displayName": "旅行家",
      "subscription_type": "free"
    },
    "token": "eyJhbGci..."
  }
}
```

#### POST /api/v1/auth/login
用户登录

#### GET /api/v1/auth/me
获取当前用户信息（需要JWT Token）

**请求头：**
```
Authorization: Bearer <JWT_TOKEN>
```

### AI规划相关

#### POST /api/v1/ai/generate-plan
生成AI行程规划（需要JWT）

**请求头：**
```
Authorization: Bearer <JWT_TOKEN>
```

**请求体：**
```json
{
  "destinationName": "巴黎",
  "country": "法国",
  "budgetLevel": "medium",
  "startDate": "2025-07-01",
  "endDate": "2025-07-07"
}
```

**响应（成功）：**
```json
{
  "success": true,
  "data": {
    "tagline": "巴黎，浪漫之都",
    "tags": ["浪漫", "艺术", "美食"],
    "detailedDescription": "...",
    "itineraries": [...],
    "packingItems": [...],
    "todoChecklist": [...]
  },
  "usage": {
    "remaining": 2,
    "limit": 3
  }
}
```

**响应（配额用尽）：**
```json
{
  "success": false,
  "error": {
    "code": "QUOTA_EXCEEDED",
    "message": "您今年的免费AI规划次数已用尽",
    "details": {
      "used": 3,
      "limit": 3,
      "subscriptionType": "free"
    }
  },
  "upgradeUrl": "/api/v1/subscriptions/upgrade"
}
```

#### GET /api/v1/ai/usage
查询使用量（需要JWT）

### 订阅相关

#### GET /api/v1/subscriptions/current
获取当前订阅状态（需要JWT）

#### POST /api/v1/subscriptions/upgrade
升级到VIP（需要JWT）

## 🏗️ 实现剩余代码

由于当前已创建了核心配置和模型，以下是剩余需要创建的关键文件清单：

### 需要创建的文件（按优先级）：

1. **中间件层**
   - `src/middleware/auth.middleware.ts` - JWT验证中间件
   - `src/middleware/error-handler.middleware.ts` - 统一错误处理
   - `src/middleware/validation.middleware.ts` - 请求验证

2. **服务层**
   - `src/services/user/user.service.ts` - 用户管理服务
   - `src/services/user/usage.service.ts` - 使用量管理服务
   - `src/services/ai/gemini.service.ts` - Gemini API调用
   - `src/services/ai/prompt-builder.service.ts` - Prompt构建
   - `src/services/ai/plan-parser.service.ts` - 结果解析

3. **控制器层**
   - `src/controllers/auth.controller.ts` - 认证API
   - `src/controllers/ai.controller.ts` - AI生成API
   - `src/controllers/subscription.controller.ts` - 订阅API

4. **路由层**
   - `src/routes/auth.routes.ts`
   - `src/routes/ai.routes.ts`
   - `src/routes/subscription.routes.ts`

5. **应用入口**
   - `src/index.ts` - Express应用和Cloud Function导出

您希望我继续创建这些文件吗？或者您希望我提供详细的实现指南，让您根据需要选择性实现？

## 📦 部署到Google Cloud Functions

### 1. 安装Google Cloud SDK

```bash
# 安装gcloud CLI
# macOS
brew install --cask google-cloud-sdk

# Windows
# 下载安装器: https://cloud.google.com/sdk/docs/install
```

### 2. 配置gcloud

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 3. 部署

```bash
npm run deploy
```

或手动部署：

```bash
npm run build

gcloud functions deploy glitrip-api \
  --runtime nodejs20 \
  --trigger-http \
  --allow-unauthenticated \
  --region asia-east1 \
  --entry-point api \
  --set-env-vars SUPABASE_URL=$SUPABASE_URL,SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY,GEMINI_API_KEY=$GEMINI_API_KEY,JWT_SECRET=$JWT_SECRET
```

### 4. 获取部署URL

```bash
gcloud functions describe glitrip-api --region asia-east1
```

复制 `url` 字段，这将是你的后端API地址。

## 🔧 故障排查

### 数据库连接失败
- 检查 `SUPABASE_URL` 和 `SUPABASE_SERVICE_ROLE_KEY` 是否正确
- 确保使用的是 `service_role` key，而非 `anon` key

### JWT验证失败
- 确保 `JWT_SECRET` 在生产环境中是强随机字符串
- 检查Token是否过期

### Gemini API调用失败
- 验证 `GEMINI_API_KEY` 是否有效
- 检查API配额是否用尽
- 查看Cloud Functions日志：`gcloud functions logs read glitrip-api`

## 💰 成本估算

### 免费额度（足够小型应用）
- Supabase: 500MB数据库，50K MAU
- Gemini API: 15次/分钟，1500次/天
- Cloud Functions: 200万次调用/月

### 付费成本（按实际使用）
- Supabase: $25/月起（8GB数据库）
- Gemini 1.5 Flash: $0.075/1M tokens（输入）+ $0.30/1M tokens（输出）
- Cloud Functions: $0.40/百万次调用

**估算**：对于1000用户，每年约$50-200成本。

## 📚 相关文档

- [Supabase文档](https://supabase.com/docs)
- [Google Gemini API文档](https://ai.google.dev/docs)
- [Google Cloud Functions文档](https://cloud.google.com/functions/docs)

## 🐛 问题反馈

如有问题，请提交Issue或联系开发团队。

## 📄 许可证

MIT License
