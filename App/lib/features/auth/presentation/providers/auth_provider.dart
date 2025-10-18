/// Authentication Provider
///
/// 使用Riverpod管理认证状态

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/models/user_model.dart';

/// 认证数据源Provider
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource();
});

/// 认证状态Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authDataSourceProvider));
});

/// 当前用户Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authDataSource = ref.watch(authDataSourceProvider);
  final isLoggedIn = await authDataSource.isLoggedIn();

  if (!isLoggedIn) return null;

  try {
    return await authDataSource.getCurrentUser();
  } catch (e) {
    // Token可能已过期，返回null
    return null;
  }
});

/// 认证状态
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

/// 认证状态管理
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthDataSource _authDataSource;

  AuthStateNotifier(this._authDataSource) : super(AuthState()) {
    _checkAuthStatus();
  }

  /// 检查登录状态
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authDataSource.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authDataSource.getCurrentUser();
        state = state.copyWith(user: user);
      }
    } catch (e) {
      // 登录状态检查失败，保持未登录状态
      state = AuthState();
    }
  }

  /// 用户注册
  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authResponse = await _authDataSource.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      state = AuthState(user: authResponse.user, isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.friendlyMessage,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '注册失败，请稍后重试',
      );
      rethrow;
    }
  }

  /// 用户登录
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authResponse = await _authDataSource.login(
        email: email,
        password: password,
      );

      state = AuthState(user: authResponse.user, isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.friendlyMessage,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '登录失败，请稍后重试',
      );
      rethrow;
    }
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    try {
      final user = await _authDataSource.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      // 刷新失败，可能Token已过期
      await logout();
    }
  }

  /// 登出
  Future<void> logout() async {
    await _authDataSource.logout();
    state = AuthState();
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}
