// AI Planning DataSource V2
//
// 调用后端API生成AI计划（不需要传country参数）

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/api_config.dart';
import '../../../auth/data/datasources/auth_datasource.dart';
import '../models/ai_plan_model_v2.dart';

class AIPlanningDataSourceV2 {
  final AuthDataSource _authDataSource;

  AIPlanningDataSourceV2(this._authDataSource);

  /// 生成AI旅行计划（V2 - 不需要country参数）
  Future<AIPlanModelV2> generatePlanV2({
    required String destinationName,
    required String budgetLevel,
    required String startDate,
    required String endDate,
    required String language, // 新增：语言参数（zh或en）
  }) async {
    try {
      final token = await _authDataSource.getToken();
      if (token == null) {
        throw AIPlanningExceptionV2('UNAUTHORIZED', '请先登录');
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.aiGeneratePlan),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'destinationName': destinationName,
              // 不传country，让AI自动生成
              'budgetLevel': budgetLevel,
              'startDate': startDate,
              'endDate': endDate,
              'language': language, // 传递语言参数
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return AIPlanModelV2.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        final error = data['error'] as Map<String, dynamic>;
        throw AIPlanningExceptionV2(
          error['code'] as String,
          error['message'] as String,
        );
      }
    } catch (e) {
      if (e is AIPlanningExceptionV2) rethrow;
      throw AIPlanningExceptionV2('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }

  /// 获取AI使用情况
  Future<AIUsageModelV2> getUsage() async {
    try {
      final token = await _authDataSource.getToken();
      if (token == null) {
        throw AIPlanningExceptionV2('UNAUTHORIZED', '请先登录');
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.aiUsage),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return AIUsageModelV2.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        final error = data['error'] as Map<String, dynamic>;
        throw AIPlanningExceptionV2(
          error['code'] as String,
          error['message'] as String,
        );
      }
    } catch (e) {
      if (e is AIPlanningExceptionV2) rethrow;
      throw AIPlanningExceptionV2('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }
}

/// AI规划异常V2
class AIPlanningExceptionV2 implements Exception {
  final String code;
  final String message;

  AIPlanningExceptionV2(this.code, this.message);

  @override
  String toString() => message;

  /// 获取友好的错误消息
  String get friendlyMessage => ApiConfig.getErrorMessage(code);
}

/// AI使用情况V2
class AIUsageModelV2 {
  final int usedCount;
  final int totalQuota;
  final int remainingQuota;
  final String subscriptionType;

  AIUsageModelV2({
    required this.usedCount,
    required this.totalQuota,
    required this.remainingQuota,
    required this.subscriptionType,
  });

  factory AIUsageModelV2.fromJson(Map<String, dynamic> json) {
    return AIUsageModelV2(
      usedCount: json['usedCount'] as int? ?? json['used_count'] as int,
      totalQuota: json['totalQuota'] as int? ?? json['total_quota'] as int,
      remainingQuota:
          json['remainingQuota'] as int? ?? json['remaining_quota'] as int,
      subscriptionType:
          json['subscriptionType'] as String? ?? json['subscription_type'] as String,
    );
  }

  bool get hasQuota => remainingQuota > 0;
  bool get isVip => subscriptionType == 'vip';
}
