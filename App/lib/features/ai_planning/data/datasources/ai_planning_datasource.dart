/// AI Planning Data Source
///
/// 处理所有与后端AI API的通信

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/api_config.dart';
import '../../../auth/data/datasources/auth_datasource.dart';
import '../models/ai_plan_model.dart';

class AIPlanningDataSource {
  final AuthDataSource _authDataSource;

  AIPlanningDataSource(this._authDataSource);

  /// 生成AI旅行计划
  Future<AIPlanModel> generatePlan({
    required String destinationName,
    required String budgetLevel,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final token = await _authDataSource.getToken();
      if (token == null) {
        throw AIPlanningException('UNAUTHORIZED', '请先登录');
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
              'budgetLevel': budgetLevel,
              'startDate': startDate,
              'endDate': endDate,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return AIPlanModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        final error = data['error'] as Map<String, dynamic>;
        throw AIPlanningException(
          error['code'] as String,
          error['message'] as String,
        );
      }
    } catch (e) {
      if (e is AIPlanningException) rethrow;
      throw AIPlanningException('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }

  /// 获取AI使用情况
  Future<AIUsageModel> getUsage() async {
    try {
      final token = await _authDataSource.getToken();
      if (token == null) {
        throw AIPlanningException('UNAUTHORIZED', '请先登录');
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
        return AIUsageModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        final error = data['error'] as Map<String, dynamic>;
        throw AIPlanningException(
          error['code'] as String,
          error['message'] as String,
        );
      }
    } catch (e) {
      if (e is AIPlanningException) rethrow;
      throw AIPlanningException('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }

  /// 获取AI生成历史
  Future<List<AIGenerationHistory>> getHistory({int limit = 10}) async {
    try {
      final token = await _authDataSource.getToken();
      if (token == null) {
        throw AIPlanningException('UNAUTHORIZED', '请先登录');
      }

      final response = await http
          .get(
            Uri.parse('${ApiConfig.aiHistory}?limit=$limit'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final historyList = data['data'] as List<dynamic>;
        return historyList
            .map((e) => AIGenerationHistory.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        final error = data['error'] as Map<String, dynamic>;
        throw AIPlanningException(
          error['code'] as String,
          error['message'] as String,
        );
      }
    } catch (e) {
      if (e is AIPlanningException) rethrow;
      throw AIPlanningException('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }
}

/// AI规划异常
class AIPlanningException implements Exception {
  final String code;
  final String message;

  AIPlanningException(this.code, this.message);

  @override
  String toString() => message;

  /// 获取友好的错误消息
  String get friendlyMessage => ApiConfig.getErrorMessage(code);
}

/// AI生成历史记录
class AIGenerationHistory {
  final String id;
  final String destinationName;
  final String budgetLevel;
  final String startDate;
  final String endDate;
  final String createdAt;

  AIGenerationHistory({
    required this.id,
    required this.destinationName,
    required this.budgetLevel,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory AIGenerationHistory.fromJson(Map<String, dynamic> json) {
    return AIGenerationHistory(
      id: json['id'] as String,
      destinationName: json['destination_name'] as String? ?? json['destinationName'] as String,
      budgetLevel: json['budget_level'] as String? ?? json['budgetLevel'] as String,
      startDate: json['start_date'] as String? ?? json['startDate'] as String,
      endDate: json['end_date'] as String? ?? json['endDate'] as String,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String,
    );
  }
}
