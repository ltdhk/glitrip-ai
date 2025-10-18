# GliTrip AI功能集成清单

## ✅ 已完成的工作

### 1. 后端开发
- ✅ 数据库Schema设计（4个表）
- ✅ Supabase迁移脚本
- ✅ Node.js + TypeScript API（13个端点）
- ✅ 自定义JWT认证系统
- ✅ Google Gemini API集成
- ✅ 使用配额管理（原子性事务）
- ✅ 完整的API文档

### 2. Flutter前端开发
- ✅ API配置文件 ([api_config.dart](lib/config/api_config.dart))
- ✅ 用户认证模型 ([user_model.dart](lib/features/auth/data/models/user_model.dart))
- ✅ 认证数据源 ([auth_datasource.dart](lib/features/auth/data/datasources/auth_datasource.dart))
- ✅ 认证Provider ([auth_provider.dart](lib/features/auth/presentation/providers/auth_provider.dart))
- ✅ 登录页面 ([login_page.dart](lib/features/auth/presentation/pages/login_page.dart))
- ✅ 注册页面 ([register_page.dart](lib/features/auth/presentation/pages/register_page.dart))
- ✅ AI规划模型 ([ai_plan_model.dart](lib/features/ai_planning/data/models/ai_plan_model.dart))
- ✅ AI规划数据源 ([ai_planning_datasource.dart](lib/features/ai_planning/data/datasources/ai_planning_datasource.dart))
- ✅ AI规划Provider ([ai_planning_provider.dart](lib/features/ai_planning/presentation/providers/ai_planning_provider.dart))
- ✅ AI规划按钮组件 ([ai_plan_button.dart](lib/features/ai_planning/presentation/widgets/ai_plan_button.dart))
- ✅ VIP升级页面 ([vip_upgrade_page.dart](lib/features/subscription/presentation/pages/vip_upgrade_page.dart))
- ✅ main.dart集成认证检查

### 3. 文档
- ✅ 后端README
- ✅ 部署指南
- ✅ 实现指南
- ✅ Flutter集成指南
- ✅ 实现总结文档

## 🔧 需要手动完成的步骤

### 步骤 1: 配置环境变量 (必需)

#### 后端环境变量
在 `Backend/functions/.env` 文件中配置：

```bash
# Supabase配置
SUPABASE_URL=your_supabase_project_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Gemini API配置
GEMINI_API_KEY=your_gemini_api_key

# JWT配置
JWT_SECRET=your_random_jwt_secret_at_least_32_characters_long

# 环境
NODE_ENV=development
```

#### 前端API配置
在 `App/lib/config/api_config.dart` 中更新：

```dart
// 开发环境
static const String baseUrl = 'http://localhost:3000';

// 生产环境（部署后）
// static const String baseUrl = 'https://your-cloud-function-url';
```

### 步骤 2: 数据库初始化 (必需)

1. 在Supabase控制台创建新项目
2. 运行迁移脚本：
   ```bash
   cd Backend/supabase/migrations
   # 复制 001_initial_schema.sql 内容到 Supabase SQL Editor 执行
   ```

### 步骤 3: 集成AI规划到添加目的地页面 (推荐)

修改 `App/lib/features/destinations/presentation/pages/add_destination_page.dart`：

**1. 添加导入（在文件顶部）：**
```dart
import '../../../ai_planning/presentation/widgets/ai_plan_button.dart';
import '../../../ai_planning/data/models/ai_plan_model.dart';
```

**2. 在 `_AddDestinationPageState` 类中添加字段：**
```dart
class _AddDestinationPageState extends ConsumerState<AddDestinationPage> {
  // ... 现有字段 ...

  AIPlanModel? _aiGeneratedPlan; // 添加这一行

  // ... 其余代码 ...
}
```

**3. 添加AI规划处理方法：**
```dart
void _handleAIPlanGenerated(AIPlanModel plan) {
  setState(() {
    _aiGeneratedPlan = plan;

    // 自动填充描述
    if (_descriptionController.text.isEmpty) {
      _descriptionController.text = '${plan.tagline}\n\n${plan.description}';
    }

    // 自动填充标签
    _tags = List.from(plan.tags);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('AI规划已应用！请检查并保存目的地。'),
      backgroundColor: Colors.green,
    ),
  );
}
```

**4. 在表单中添加AI规划按钮（在描述字段后面，约第147行）：**
```dart
const SizedBox(height: 16),
_buildTextField(
  controller: _descriptionController,
  label: l10n.description,
  icon: Icons.description,
  maxLines: 3,
),
// ========== 添加以下代码 ==========
const SizedBox(height: 24),
if (!_isEditing) ...[
  _buildSectionHeader('AI智能规划', Icons.auto_awesome),
  const SizedBox(height: 8),
  Text(
    '让AI帮你规划行程，自动生成描述、标签和行程安排',
    style: TextStyle(color: Colors.grey[600], fontSize: 14),
  ),
  const SizedBox(height: 16),
  AIPlanButton(
    destinationName: _nameController.text,
    budgetLevel: _selectedBudgetLevel.toString().split('.').last,
    startDate: _startDate,
    endDate: _endDate,
    onPlanGenerated: _handleAIPlanGenerated,
  ),
],
// ========== 添加结束 ==========
const SizedBox(height: 24),
_buildSectionHeader(l10n.travelDetails),
```

### 步骤 4: 安装依赖 (必需)

```bash
cd App
flutter pub get
```

### 步骤 5: 部署后端 (生产环境)

详细步骤见 `Backend/DEPLOYMENT.md`

简要步骤：
```bash
cd Backend/functions
npm install
npm run build
gcloud functions deploy glitrip-api --runtime nodejs20 --trigger-http --allow-unauthenticated
```

### 步骤 6: 测试功能 (推荐)

#### 测试认证：
1. 运行应用 `flutter run`
2. 注册新用户
3. 登出
4. 使用新用户登录
5. 检查token是否持久化（重启应用后仍然登录）

#### 测试AI规划：
1. 登录应用
2. 点击"添加目的地"
3. 输入目的地名称和日期
4. 点击"使用AI规划行程"
5. 等待AI生成完成
6. 检查描述和标签是否自动填充

#### 测试配额：
1. 免费用户生成3次AI规划
2. 第4次应该显示配额用尽
3. 点击升级VIP查看升级页面

## 📋 可选增强功能

### 优先级 1 - 推荐实现
- ⏳ **Token自动刷新**: 在HTTP拦截器中检测401错误并自动刷新token
- ⏳ **保存AI生成的详细数据**: 将每日行程、打包清单、待办事项保存到本地数据库
- ⏳ **错误日志**: 集成Sentry或Firebase Crashlytics

### 优先级 2 - 增强用户体验
- ⏳ **AI生成历史页面**: 显示用户的所有AI生成记录
- ⏳ **生成结果预览**: 在应用AI规划前先预览内容
- ⏳ **编辑AI内容**: 允许用户修改AI生成的内容
- ⏳ **支付集成**: 集成支付宝/微信支付用于VIP升级

### 优先级 3 - 未来功能
- ⏳ **AI参数自定义**: 允许用户调整AI生成的风格和详细程度
- ⏳ **分享功能**: 分享AI生成的行程
- ⏳ **离线模式**: 缓存AI生成结果支持离线查看
- ⏳ **多语言AI生成**: 支持英文、日文等其他语言

## 🔍 故障排除

### 问题1: 登录失败，显示"网络连接失败"
**可能原因**:
- 后端服务未运行
- API URL配置错误
- 网络权限未配置

**解决方案**:
1. 检查 `api_config.dart` 中的 `baseUrl`
2. 确保后端服务正在运行
3. 检查Android `AndroidManifest.xml` 或 iOS `Info.plist` 中的网络权限

### 问题2: AI生成超时
**可能原因**:
- Gemini API响应慢
- 网络超时设置太短

**解决方案**:
1. 在 `api_config.dart` 中增加 `timeout` 值：
   ```dart
   static const timeout = Duration(seconds: 60); // 增加到60秒
   ```
2. 检查Gemini API配额

### 问题3: Token过期错误
**可能原因**:
- JWT过期时间太短
- 未实现自动刷新

**解决方案**:
1. 在后端增加token过期时间
2. 实现自动刷新机制

### 问题4: AI生成内容为空或格式错误
**可能原因**:
- Gemini API返回格式不符合预期
- JSON解析失败

**解决方案**:
1. 检查后端日志查看Gemini响应
2. 确保prompt-builder正确配置
3. 添加更多错误处理和重试逻辑

## 📊 性能优化建议

### 1. API性能
- 使用HTTP缓存头
- 实现请求去重
- 添加API响应缓存

### 2. 应用性能
- 使用图片懒加载
- 实现虚拟列表（长列表）
- 优化状态管理（避免不必要的重建）

### 3. 数据库性能
- 添加适当的索引
- 使用连接池
- 定期清理过期数据

## 🔐 安全检查清单

- ✅ 密码使用bcrypt加密
- ✅ JWT Token认证
- ✅ HTTPS强制（生产环境）
- ⏳ Token存储使用flutter_secure_storage（生产环境推荐）
- ⏳ API速率限制
- ⏳ 输入验证和清理
- ⏳ SQL注入防护（已使用参数化查询）
- ⏳ XSS防护

## 📞 获取帮助

### 文档链接
- [后端API文档](../Backend/functions/README.md)
- [部署指南](../Backend/DEPLOYMENT.md)
- [Flutter集成指南](FLUTTER_AI_INTEGRATION_GUIDE.md)
- [实现总结](../IMPLEMENTATION_SUMMARY.md)

### 常见资源
- [Supabase文档](https://supabase.com/docs)
- [Gemini API文档](https://ai.google.dev/docs)
- [Flutter文档](https://flutter.dev/docs)
- [Riverpod文档](https://riverpod.dev)

## ✨ 下一步

1. **立即行动**: 完成"需要手动完成的步骤"中的所有必需项
2. **测试**: 在开发环境中全面测试所有功能
3. **优化**: 根据测试结果进行性能和用户体验优化
4. **部署**: 部署到生产环境
5. **监控**: 设置日志和监控，追踪应用性能和错误

---

**注意**: 本清单会随着项目进展持续更新。完成每个步骤后请打勾标记。
