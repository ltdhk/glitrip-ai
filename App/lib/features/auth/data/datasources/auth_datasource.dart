/// Authentication Data Source
///
/// 处理所有与后端认证API的通信

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/api_config.dart';
import '../models/user_model.dart';

class AuthDataSource {
  /// 用户注册
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.authRegister),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              if (displayName != null) 'displayName': displayName,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        final authResponse = AuthResponse.fromJson(data['data'] as Map<String, dynamic>);
        await _saveToken(authResponse.token);
        return authResponse;
      } else {
        final error = data['error'] as Map<String, dynamic>;
        throw AuthException(
          error['code'] as String,
          error['message'] as String,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }

  /// 用户登录
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.authLogin),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final authResponse = AuthResponse.fromJson(data['data'] as Map<String, dynamic>);
        await _saveToken(authResponse.token);
        return authResponse;
      } else {
        final error = data['error'] as Map<String, dynamic>;
        throw AuthException(
          error['code'] as String,
          error['message'] as String,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }

  /// 获取当前用户信息
  Future<UserModel> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw AuthException('UNAUTHORIZED', '请先登录');
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.authMe),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        final error = data['error'] as Map<String, dynamic>;
        throw AuthException(
          error['code'] as String,
          error['message'] as String,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }

  /// 刷新Token
  Future<String> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw AuthException('UNAUTHORIZED', '请先登录');
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.authRefresh),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final newToken = data['data']['token'] as String;
        await _saveToken(newToken);
        return newToken;
      } else {
        final error = data['error'] as Map<String, dynamic>;
        throw AuthException(
          error['code'] as String,
          error['message'] as String,
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }

  /// 删除账户
  Future<void> deleteAccount() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw AuthException('UNAUTHORIZED', '请先登录');
      }

      final response = await http
          .delete(
            Uri.parse(ApiConfig.authDelete),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        await logout();
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['error'] is Map<String, dynamic>) {
        final error = data['error'] as Map<String, dynamic>;
        throw AuthException(
          (error['code'] ?? 'INTERNAL_ERROR') as String,
          (error['message'] ?? '操作失败，请稍后重试') as String,
        );
      }

      throw AuthException('INTERNAL_ERROR', '操作失败，请稍后重试');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('NETWORK_ERROR', '网络连接失败，请检查网络设置');
    }
  }

  /// 登出
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConfig.tokenKey);
    await prefs.remove(ApiConfig.userKey);
  }

  /// 获取保存的Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.tokenKey);
  }

  /// 保存Token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.tokenKey, token);
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

/// 认证异常
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  @override
  String toString() => message;

  /// 获取友好的错误消息
  String get friendlyMessage => ApiConfig.getErrorMessage(code);
}
