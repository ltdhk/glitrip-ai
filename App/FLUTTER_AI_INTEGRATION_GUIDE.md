# Flutter AI Integration Guide

## 概述

已完成GliTrip Flutter应用的AI旅行规划功能前端开发，包括：
- 用户认证（登录/注册）
- AI规划功能
- VIP会员升级页面

## 已创建的文件

### 1. 认证功能 (Authentication)

#### 配置文件
- `lib/config/api_config.dart` - API端点配置和错误消息映射

#### 数据模型
- `lib/features/auth/data/models/user_model.dart` - 用户模型和认证响应模型
  - `UserModel` - 用户信息
  - `AuthResponse` - 登录/注册响应
  - 包含 `isVip` 和 `isSubscriptionActive` 辅助方法

#### 数据源
- `lib/features/auth/data/datasources/auth_datasource.dart` - 认证数据源
  - `register()` - 用户注册
  - `login()` - 用户登录
  - `getCurrentUser()` - 获取当前用户
  - `refreshToken()` - 刷新Token
  - `logout()` - 登出
  - Token管理（使用SharedPreferences）

#### 状态管理
- `lib/features/auth/presentation/providers/auth_provider.dart` - Riverpod状态管理
  - `authDataSourceProvider` - 数据源单例
  - `authStateProvider` - 认证状态管理器
  - `currentUserProvider` - 当前用户Provider
  - `AuthStateNotifier` - 状态管理类

#### UI页面
- `lib/features/auth/presentation/pages/login_page.dart` - 登录页面
  - 邮箱/密码表单
  - 错误显示
  - 导航到注册页面

- `lib/features/auth/presentation/pages/register_page.dart` - 注册页面
  - 邮箱/密码/昵称表单
  - 密码确认
  - 表单验证

### 2. AI规划功能 (AI Planning)

#### 数据模型
- `lib/features/ai_planning/data/models/ai_plan_model.dart`
  - `AIPlanModel` - AI生成的完整计划
  - `DailyItineraryModel` - 每日行程
  - `PackingItemModel` - 打包清单项
  - `TodoItemModel` - 待办事项
  - `AIPlanRequest` - AI生成请求
  - `AIUsageModel` - AI使用情况

#### 数据源
- `lib/features/ai_planning/data/datasources/ai_planning_datasource.dart`
  - `generatePlan()` - 生成AI旅行计划
  - `getUsage()` - 获取AI使用情况
  - `getHistory()` - 获取AI生成历史
  - `AIGenerationHistory` - 历史记录模型

#### 状态管理
- `lib/features/ai_planning/presentation/providers/ai_planning_provider.dart`
  - `aiPlanningDataSourceProvider` - 数据源
  - `aiUsageProvider` - AI使用情况
  - `aiHistoryProvider` - AI生成历史
  - `aiPlanningStateProvider` - AI规划状态管理器

#### UI组件
- `lib/features/ai_planning/presentation/widgets/ai_plan_button.dart`
  - `AIPlanButton` - AI规划按钮组件
  - 显示剩余配额
  - AI生成对话框
  - 错误处理和重试

### 3. 集成指南
- `lib/features/destinations/presentation/pages/add_destination_page_with_ai.dart`
  - 详细的集成步骤说明
  - 代码示例
  - 数据保存建议

### 4. VIP会员功能
- `lib/features/subscription/presentation/pages/vip_upgrade_page.dart`
  - VIP会员升级页面
  - 功能对比展示
  - 使用情况统计
  - 价格展示
  - 升级按钮（待集成支付）

## 集成步骤

### 步骤1: 更新依赖

`pubspec.yaml` 已更新，包含以下依赖：
```yaml
dependencies:
  http: ^1.2.0
  shared_preferences: ^2.3.3
  flutter_secure_storage: ^9.2.2
  flutter_riverpod: ^2.4.9
```

运行: `flutter pub get`

### 步骤2: 配置API端点

在 `lib/config/api_config.dart` 中配置后端URL：
```dart
static const String baseUrl = 'http://localhost:3000'; // 开发环境
// static const String baseUrl = 'https://your-api.com'; // 生产环境
```

### 步骤3: 集成认证到应用启动

修改 `lib/main.dart`：

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'GliTrip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BCD4)),
        useMaterial3: true,
      ),
      home: authState.isAuthenticated ? const HomePage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        // 其他路由...
      },
    );
  }
}
```

### 步骤4: 集成AI规划到添加目的地页面

在 `lib/features/destinations/presentation/pages/add_destination_page.dart` 中：

**1. 添加导入：**
```dart
import '../../../ai_planning/presentation/widgets/ai_plan_button.dart';
import '../../../ai_planning/data/models/ai_plan_model.dart';
```

**2. 在 `_AddDestinationPageState` 类中添加字段和方法：**
```dart
AIPlanModel? _aiGeneratedPlan;

void _handleAIPlanGenerated(AIPlanModel plan) {
  setState(() {
    // 保存AI生成的计划
    _aiGeneratedPlan = plan;

    // 设置标语和描述
    if (_descriptionController.text.isEmpty) {
      _descriptionController.text = '${plan.tagline}\n\n${plan.description}';
    }

    // 设置标签
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

**3. 在 `build()` 方法的表单中添加AI规划部分：**

在第147行（`_buildTextField` for description之后）添加：

```dart
const SizedBox(height: 24),
// AI规划部分
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
  const SizedBox(height: 24),
],
```

### 步骤5: 添加VIP升级入口

在适当的位置（如设置页面、AI配额用尽提示等）添加VIP升级入口：

```dart
import '../subscription/presentation/pages/vip_upgrade_page.dart';

// 导航到VIP升级页面
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const VIPUpgradePage()),
);
```

## API端点说明

后端API端点已在 `api_config.dart` 中配置：

### 认证端点
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `GET /api/v1/auth/me` - 获取当前用户
- `POST /api/v1/auth/refresh` - 刷新Token

### AI规划端点
- `POST /api/v1/ai/generate-plan` - 生成AI旅行计划
- `GET /api/v1/ai/usage` - 获取AI使用情况
- `GET /api/v1/ai/history` - 获取AI生成历史

### 订阅端点
- `GET /api/v1/subscriptions/current` - 获取当前订阅
- `POST /api/v1/subscriptions/upgrade` - 升级订阅
- `POST /api/v1/subscriptions/cancel` - 取消订阅

## 数据流程

### 用户注册/登录流程
1. 用户在 `LoginPage` 或 `RegisterPage` 输入信息
2. 调用 `AuthStateNotifier.login()` 或 `register()`
3. `AuthDataSource` 发送HTTP请求到后端
4. 后端返回 `AuthResponse`（包含user和token）
5. Token保存到 `SharedPreferences`
6. 更新 `authStateProvider` 状态
7. 导航到主页

### AI规划生成流程
1. 用户在添加目的地页面点击"使用AI规划行程"
2. 验证必填字段（目的地名称、出行日期）
3. 显示生成对话框，调用 `AIPlanningStateNotifier.generatePlan()`
4. `AIPlanningDataSource` 发送请求到后端（包含JWT token）
5. 后端调用Gemini API生成规划
6. 后端扣减用户配额，保存生成记录
7. 返回 `AIPlanModel` 给前端
8. 前端自动填充表单（描述、标签等）
9. 用户检查并保存目的地

### 配额检查流程
1. `AIPlanButton` 组件加载时调用 `aiUsageProvider`
2. 获取当前用户的AI使用情况
3. 显示剩余配额
4. 如果配额用尽，禁用按钮并显示升级链接

## 待办事项 (TODO)

### 高优先级
1. ✅ 完成认证UI
2. ✅ 完成AI规划UI
3. ✅ 完成VIP升级页面
4. ⏳ 集成AI规划到add_destination_page（需手动修改现有文件）
5. ⏳ 保存AI生成的每日行程、打包清单、待办事项到本地数据库

### 中优先级
6. ⏳ 添加AI生成历史页面
7. ⏳ 添加加载状态和更好的错误提示
8. ⏳ 集成支付功能（VIP升级）
9. ⏳ 添加Token自动刷新机制

### 低优先级
10. ⏳ 添加AI生成结果预览页面
11. ⏳ 支持编辑AI生成的内容
12. ⏳ 添加AI生成参数自定义

## 注意事项

1. **Token管理**: Token存储在SharedPreferences中，生产环境建议使用flutter_secure_storage
2. **错误处理**: 所有API调用都包含错误处理和友好的错误消息
3. **配额限制**: 免费用户3次/年，VIP用户1000次/年
4. **日期格式**: 后端API期望ISO 8601格式（YYYY-MM-DD）
5. **预算等级**: 'low', 'medium', 'high' 字符串格式

## 测试建议

### 单元测试
- 测试 `UserModel.fromJson()` 和 `toJson()`
- 测试 `AIPlanModel` 的JSON序列化
- 测试 `AuthDataSource` 的所有方法（使用mock）

### 集成测试
- 测试完整的注册-登录流程
- 测试AI规划生成流程
- 测试配额检查和用尽场景

### UI测试
- 测试表单验证
- 测试加载状态显示
- 测试错误消息显示

## 故障排除

### 问题: 登录失败，显示"网络连接失败"
**解决方案**:
- 检查 `api_config.dart` 中的 `baseUrl` 是否正确
- 确保后端服务正在运行
- 检查网络权限配置（Android: `AndroidManifest.xml`, iOS: `Info.plist`）

### 问题: Token过期
**解决方案**:
- 实现自动刷新Token机制
- 在HTTP拦截器中检测401错误并自动刷新

### 问题: AI生成超时
**解决方案**:
- 增加 `ApiConfig.timeout` 值
- 后端优化Gemini API调用

## 相关文档

- Backend API文档: `Backend/functions/README.md`
- 部署指南: `Backend/DEPLOYMENT.md`
- 实现指南: `Backend/IMPLEMENTATION_GUIDE.md`

## 联系支持

如有问题或需要帮助，请参考项目README或联系开发团队。
