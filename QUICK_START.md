# GliTrip AI功能 - 快速开始指南

## 🚀 5分钟快速启动

本指南帮助您在最短时间内启动并测试GliTrip AI功能。

## 前置要求

- ✅ Node.js 20+
- ✅ Flutter 3.13+
- ✅ Supabase账号
- ✅ Google Cloud账号（用于Gemini API）

## 第一步: 后端配置 (2分钟)

### 1. 创建Supabase项目

1. 访问 [Supabase](https://supabase.com/)
2. 创建新项目
3. 获取项目URL和Service Role Key：
   - 项目设置 → API → Project URL
   - 项目设置 → API → Service Role Key (secret)

### 2. 初始化数据库

1. 在Supabase控制台，进入 SQL Editor
2. 打开 `Backend/supabase/migrations/001_initial_schema.sql`
3. 复制全部内容到SQL Editor
4. 点击"Run"执行

### 3. 获取Gemini API密钥

1. 访问 [Google AI Studio](https://makersuite.google.com/app/apikey)
2. 创建API密钥
3. 保存密钥

### 4. 配置环境变量

创建 `Backend/functions/.env` 文件：

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
GEMINI_API_KEY=your_gemini_api_key_here
JWT_SECRET=your_random_secret_minimum_32_characters_long_string
NODE_ENV=development
```

### 5. 启动后端服务

```bash
cd Backend/functions
npm install
npm run dev
```

后端现在运行在 `http://localhost:3000`

## 第二步: 前端配置 (2分钟)

### 1. 配置API端点

打开 `App/lib/config/api_config.dart`，确认：

```dart
static const String baseUrl = 'http://localhost:3000';
```

### 2. 安装依赖

```bash
cd App
flutter pub get
```

### 3. 启动应用

```bash
flutter run
```

## 第三步: 测试功能 (1分钟)

### 测试1: 用户注册
1. 应用启动后会显示登录页面
2. 点击"立即注册"
3. 输入邮箱、密码、昵称
4. 点击"注册"

✅ **成功标志**: 自动跳转到主页

### 测试2: AI规划生成
1. 点击底部导航栏的"目的地"
2. 点击"+"添加新目的地
3. 输入：
   - 目的地名称：东京
   - 国家：日本
   - 选择预算等级
   - 选择开始和结束日期
4. 滚动到"AI智能规划"部分
5. 点击"使用AI规划行程"

✅ **成功标志**:
- 显示AI生成对话框
- 几秒后自动填充描述和标签
- 显示"AI规划已应用！"提示

### 测试3: 查看配额
1. 在添加目的地页面，查看AI规划按钮下方
2. 应显示"剩余 2 次AI规划"（刚生成了1次）

### 测试4: VIP升级页面
1. 返回主页
2. 点击"个人资料"
3. 查找"升级VIP"入口（或直接导航）

## 🎯 完整测试流程

```
注册新用户 → 登录 → 添加目的地 → 使用AI规划 (1次)
→ 查看剩余配额 (2次) → 再次使用AI规划 (2次)
→ 查看剩余配额 (1次) → 再次使用AI规划 (3次)
→ 查看剩余配额 (0次) → 点击升级VIP
→ 查看VIP功能对比
```

## 📝 验证清单

在完成快速启动后，确认以下功能正常：

- [ ] 用户可以注册新账号
- [ ] 用户可以登录
- [ ] 登录状态在重启应用后保持
- [ ] 用户可以登出
- [ ] AI可以生成旅行计划
- [ ] 生成的内容自动填充到表单
- [ ] 配额正确显示和扣减
- [ ] 配额用尽后按钮禁用
- [ ] VIP升级页面正常显示

## ⚠️ 常见问题

### Q: 后端启动失败
**A**: 检查 `.env` 文件是否正确配置，所有密钥是否有效

### Q: 前端无法连接后端
**A**:
1. 确认后端正在运行 `http://localhost:3000`
2. 测试健康检查: `curl http://localhost:3000/health`
3. 检查防火墙设置

### Q: AI生成失败
**A**:
1. 检查Gemini API密钥是否正确
2. 确认Gemini API配额未用尽
3. 查看后端日志获取详细错误

### Q: Token过期错误
**A**:
1. JWT_SECRET必须保持一致
2. 检查系统时间是否正确

## 🔄 数据库状态检查

在Supabase控制台执行以下查询检查数据状态：

```sql
-- 查看所有用户
SELECT id, email, display_name, subscription_type FROM users;

-- 查看用户配额
SELECT u.email, uu.ai_generations_count, uu.ai_generations_limit, uu.year_period
FROM users u
JOIN user_usage uu ON u.id = uu.user_id;

-- 查看AI生成记录
SELECT ag.destination_name, ag.budget_level, ag.created_at, u.email
FROM ai_generations ag
JOIN users u ON ag.user_id = u.id
ORDER BY ag.created_at DESC
LIMIT 10;
```

## 📊 API端点测试

使用curl测试API端点：

### 1. 健康检查
```bash
curl http://localhost:3000/health
```

### 2. 注册用户
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "displayName": "Test User"
  }'
```

### 3. 登录
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 4. 生成AI规划（需要token）
```bash
curl -X POST http://localhost:3000/api/v1/ai/generate-plan \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "destinationName": "东京",
    "budgetLevel": "medium",
    "startDate": "2025-06-01",
    "endDate": "2025-06-07"
  }'
```

### 5. 查看使用情况
```bash
curl http://localhost:3000/api/v1/ai/usage \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 🎓 下一步学习

完成快速启动后，建议阅读：

1. **详细功能**: [Flutter集成指南](App/FLUTTER_AI_INTEGRATION_GUIDE.md)
2. **部署生产**: [部署指南](Backend/DEPLOYMENT.md)
3. **架构理解**: [实现总结](IMPLEMENTATION_SUMMARY.md)
4. **集成待办**: [集成清单](App/INTEGRATION_CHECKLIST.md)

## 🆘 需要帮助？

1. 查看完整文档
2. 检查后端日志: `Backend/functions/logs/`
3. 使用Flutter DevTools调试前端
4. 查看Supabase日志和监控

## 🎉 成功！

如果所有测试通过，恭喜您已成功启动GliTrip AI功能！

现在您可以：
- 探索所有功能
- 根据需求定制UI
- 集成到现有的目的地管理流程
- 准备生产部署

---

**估计完成时间**: 5-10分钟
**难度**: ⭐⭐☆☆☆ (简单)
**最后更新**: 2025-10-17
