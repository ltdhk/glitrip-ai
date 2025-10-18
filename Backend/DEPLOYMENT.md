# 🚀 GliTrip Backend - 部署指南

本文档详细说明如何将Backend部署到生产环境。

## 📋 准备清单

在部署之前，请确保你已经：

- ✅ 拥有Supabase账号并创建了项目
- ✅ 拥有Google Gemini API密钥
- ✅ 拥有Google Cloud账号
- ✅ 安装了Node.js >= 20.0.0
- ✅ 安装了gcloud CLI工具

---

## 🗄️ 第一步：部署Supabase数据库

### 1.1 创建Supabase项目

1. 访问 [Supabase Dashboard](https://app.supabase.com)
2. 点击 "New Project"
3. 填写项目信息：
   - Name: `glitrip-production`
   - Database Password: 强密码（保存好）
   - Region: 选择离用户最近的区域（如 Singapore）

### 1.2 执行数据库迁移

1. 进入项目后，点击左侧 "SQL Editor"
2. 打开文件 `Backend/supabase/migrations/001_initial_schema.sql`
3. 复制所有内容到SQL Editor
4. 点击 "Run" 执行

### 1.3 验证表创建

执行以下SQL验证表是否创建成功：

```sql
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('users', 'subscriptions', 'user_usage', 'ai_generations');
```

应该返回4个表名。

### 1.4 获取连接信息

1. 进入 "Settings" > "API"
2. 记录以下信息：
   - **Project URL** (SUPABASE_URL)
   - **service_role key** (SUPABASE_SERVICE_ROLE_KEY)

⚠️ **重要**：使用 `service_role` key，而非 `anon` key！

---

## 🤖 第二步：获取Gemini API密钥

1. 访问 [Google AI Studio](https://makersuite.google.com/app/apikey)
2. 使用Google账号登录
3. 点击 "Create API Key"
4. 选择项目或创建新项目
5. 复制生成的API密钥（GEMINI_API_KEY）

---

## ☁️ 第三步：部署到Google Cloud Functions

### 3.1 安装gcloud CLI

**macOS:**
```bash
brew install --cask google-cloud-sdk
```

**Windows:**
下载安装器：https://cloud.google.com/sdk/docs/install

**Linux:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

### 3.2 初始化gcloud

```bash
# 登录Google账号
gcloud auth login

# 设置项目ID（如果没有项目，先在Google Cloud Console创建）
gcloud config set project YOUR_PROJECT_ID

# 启用必要的API
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### 3.3 准备部署

进入functions目录：

```bash
cd Backend/functions
npm install
npm run build
```

### 3.4 部署到Cloud Functions

生成JWT密钥：

```bash
JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
echo "Generated JWT_SECRET: $JWT_SECRET"
```

执行部署命令：

```bash
gcloud functions deploy glitrip-api \
  --gen2 \
  --runtime=nodejs20 \
  --region=asia-east1 \
  --source=. \
  --entry-point=api \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars="NODE_ENV=production,SUPABASE_URL=YOUR_SUPABASE_URL,SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_KEY,GEMINI_API_KEY=YOUR_GEMINI_KEY,JWT_SECRET=$JWT_SECRET,FREE_USER_LIMIT=3,VIP_USER_LIMIT=1000"
```

**重要参数说明：**
- `--gen2`: 使用Cloud Functions第二代（推荐）
- `--runtime=nodejs20`: 使用Node.js 20
- `--region=asia-east1`: 香港区域（离中国大陆最近）
- `--allow-unauthenticated`: 允许公开访问（API内部有JWT验证）
- `--set-env-vars`: 设置环境变量

### 3.5 获取部署URL

```bash
gcloud functions describe glitrip-api --gen2 --region=asia-east1 --format="value(serviceConfig.uri)"
```

复制输出的URL，这就是你的后端API地址。

示例：`https://glitrip-api-xxxx-ue.a.run.app`

---

## 🧪 第四步：测试部署

### 4.1 健康检查

```bash
curl https://YOUR_FUNCTION_URL/health
```

应该返回：
```json
{
  "status": "ok",
  "timestamp": "2025-01-17T...",
  "service": "glitrip-backend",
  "version": "1.0.0"
}
```

### 4.2 测试注册

```bash
curl -X POST https://YOUR_FUNCTION_URL/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "displayName": "测试用户"
  }'
```

### 4.3 测试登录

```bash
curl -X POST https://YOUR_FUNCTION_URL/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

保存返回的`token`。

### 4.4 测试AI生成（需要Token）

```bash
curl -X POST https://YOUR_FUNCTION_URL/api/v1/ai/generate-plan \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "destinationName": "东京",
    "country": "日本",
    "budgetLevel": "medium",
    "startDate": "2025-07-01",
    "endDate": "2025-07-05"
  }'
```

---

## 📊 第五步：监控和日志

### 5.1 查看日志

```bash
gcloud functions logs read glitrip-api --region=asia-east1 --limit=50
```

### 5.2 实时日志流

```bash
gcloud functions logs tail glitrip-api --region=asia-east1
```

### 5.3 Cloud Console监控

访问：https://console.cloud.google.com/functions/list

可以查看：
- 请求量
- 错误率
- 延迟
- 资源使用

---

## 🔧 第六步：配置Flutter应用

在Flutter应用中配置后端URL：

### 6.1 创建配置文件

**文件**: `App/lib/config/api_config.dart`

```dart
class ApiConfig {
  static const String baseUrl = 'https://YOUR_FUNCTION_URL';

  // API端点
  static const String authRegister = '$baseUrl/api/v1/auth/register';
  static const String authLogin = '$baseUrl/api/v1/auth/login';
  static const String authMe = '$baseUrl/api/v1/auth/me';
  static const String aiGeneratePlan = '$baseUrl/api/v1/ai/generate-plan';
  static const String aiUsage = '$baseUrl/api/v1/ai/usage';
  static const String subscriptionCurrent = '$baseUrl/api/v1/subscriptions/current';
  static const String subscriptionUpgrade = '$baseUrl/api/v1/subscriptions/upgrade';
}
```

### 6.2 使用配置

```dart
import 'package:http/http.dart' as http;
import 'api_config.dart';

// 示例：调用登录API
final response = await http.post(
  Uri.parse(ApiConfig.authLogin),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'password': password}),
);
```

---

## 🔐 安全建议

### 1. 保护环境变量

❌ **永远不要**将以下信息提交到Git：
- `SUPABASE_SERVICE_ROLE_KEY`
- `GEMINI_API_KEY`
- `JWT_SECRET`

✅ **应该**：
- 使用Google Secret Manager存储敏感信息
- 在CI/CD中注入环境变量

### 2. 启用HTTPS

Cloud Functions默认使用HTTPS，确保Flutter应用只通过HTTPS访问API。

### 3. 配置CORS

如果需要限制CORS，在部署时修改 `CORS_ORIGIN` 环境变量：

```bash
--set-env-vars="CORS_ORIGIN=https://yourdomain.com"
```

### 4. API速率限制

当前配置：15分钟内最多100次请求。可以根据需要调整：

```bash
--set-env-vars="RATE_LIMIT_WINDOW_MS=900000,RATE_LIMIT_MAX_REQUESTS=100"
```

---

## 💰 成本优化

### Cloud Functions定价（Gen2）

**免费额度：**
- 200万次调用/月
- 400,000 GB-秒/月
- 5GB出站流量/月

**付费价格：**
- $0.40/百万次调用
- $0.0000025/GB-秒（512MB内存）
- $0.12/GB出站流量

### 优化建议

1. **使用最小内存配置**：
   ```bash
   --memory=512MB
   ```

2. **设置合理的超时**：
   ```bash
   --timeout=60s
   ```

3. **启用并发**（Gen2默认启用）：
   ```bash
   --max-instances=10
   ```

4. **监控使用量**：
   定期检查Google Cloud Console中的Billing报告

---

## 🔄 更新部署

当代码有更新时：

```bash
cd Backend/functions
npm run build
gcloud functions deploy glitrip-api --gen2 --region=asia-east1
```

注意：环境变量会保留，不需要重新设置。

---

## 🐛 故障排查

### 问题1：部署失败

**错误**: `Permission denied`

**解决**:
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### 问题2：Function超时

**错误**: `Function execution took 60001 ms, finished with status: 'timeout'`

**解决**: 增加超时时间
```bash
gcloud functions deploy glitrip-api --timeout=120s
```

### 问题3：数据库连接失败

**错误**: `Database connection failed`

**检查**:
1. SUPABASE_URL是否正确
2. SUPABASE_SERVICE_ROLE_KEY是否正确
3. Supabase项目是否暂停（免费版7天无活动会暂停）

### 问题4：Gemini API失败

**错误**: `API key not valid`

**解决**:
1. 检查API密钥是否正确
2. 确认API密钥对应的项目已启用Gemini API
3. 检查配额是否用尽

---

## 📞 支持

如有问题：

1. 查看Cloud Functions日志：
   ```bash
   gcloud functions logs read glitrip-api --region=asia-east1 --limit=100
   ```

2. 检查Supabase日志：
   Supabase Dashboard > Logs

3. 查看本项目的 [Issues](https://github.com/your-repo/issues)

---

## ✅ 部署检查清单

- [ ] Supabase项目已创建
- [ ] 数据库迁移已执行
- [ ] Gemini API密钥已获取
- [ ] gcloud CLI已安装和配置
- [ ] Cloud Functions已部署成功
- [ ] 健康检查通过
- [ ] 注册/登录测试通过
- [ ] AI生成测试通过
- [ ] Flutter应用已配置后端URL
- [ ] 环境变量已安全存储

恭喜！你的GliTrip Backend已成功部署到生产环境！🎉
