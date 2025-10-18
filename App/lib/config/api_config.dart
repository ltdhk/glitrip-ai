/**
 * API Configuration
 *
 * 配置后端API的基础URL和端点
 */

class ApiConfig {
  // 后端API基础URL
  // TODO: 部署后替换为实际的Cloud Function URL
  static const String baseUrl = 'http://10.0.2.2:3000'; // 本地开发
  // static const String baseUrl = 'https://glitrip-api-xxx.a.run.app'; // 生产环境

  // ==========================================
  // 认证相关端点
  // ==========================================
  static const String authRegister = '$baseUrl/api/v1/auth/register';
  static const String authLogin = '$baseUrl/api/v1/auth/login';
  static const String authMe = '$baseUrl/api/v1/auth/me';
  static const String authRefresh = '$baseUrl/api/v1/auth/refresh';

  // ==========================================
  // AI规划相关端点
  // ==========================================
  static const String aiGeneratePlan = '$baseUrl/api/v1/ai/generate-plan';
  static const String aiUsage = '$baseUrl/api/v1/ai/usage';
  static const String aiHistory = '$baseUrl/api/v1/ai/history';

  // ==========================================
  // 订阅相关端点
  // ==========================================
  static const String subscriptionCurrent = '$baseUrl/api/v1/subscriptions/current';
  static const String subscriptionUpgrade = '$baseUrl/api/v1/subscriptions/upgrade';
  static const String subscriptionCancel = '$baseUrl/api/v1/subscriptions/cancel';

  // ==========================================
  // 工具端点
  // ==========================================
  static const String health = '$baseUrl/health';

  // ==========================================
  // HTTP配置
  // ==========================================
  static const Duration timeout = Duration(seconds: 60); // 请求超时时间
  static const int maxRetries = 3; // 最大重试次数

  // ==========================================
  // 存储键
  // ==========================================
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // ==========================================
  // 错误消息
  // ==========================================
  static const Map<String, String> errorMessages = {
    'UNAUTHORIZED': '未授权，请重新登录',
    'INVALID_TOKEN': '登录令牌无效，请重新登录',
    'TOKEN_EXPIRED': '登录已过期，请重新登录',
    'USER_NOT_FOUND': '用户不存在',
    'USER_ALREADY_EXISTS': '邮箱已被注册',
    'INVALID_CREDENTIALS': '邮箱或密码错误',
    'QUOTA_EXCEEDED': 'AI规划次数已用尽',
    'AI_GENERATION_FAILED': 'AI生成失败，请稍后重试',
    'INVALID_INPUT': '输入数据无效',
    'VALIDATION_ERROR': '数据验证失败',
    'INTERNAL_ERROR': '服务器错误，请稍后重试',
    'DATABASE_ERROR': '数据库错误，请稍后重试',
  };

  /// 获取友好的错误消息
  static String getErrorMessage(String errorCode) {
    return errorMessages[errorCode] ?? '未知错误，请稍后重试';
  }
}
