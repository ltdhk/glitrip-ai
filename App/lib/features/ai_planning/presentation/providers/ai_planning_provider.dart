/// AI Planning Provider
///
/// 使用Riverpod管理AI规划状态

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/ai_planning_datasource.dart';
import '../../data/models/ai_plan_model.dart';

/// AI规划数据源Provider
final aiPlanningDataSourceProvider = Provider<AIPlanningDataSource>((ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  return AIPlanningDataSource(authDataSource);
});

/// AI使用情况Provider
final aiUsageProvider = FutureProvider<AIUsageModel?>((ref) async {
  final dataSource = ref.watch(aiPlanningDataSourceProvider);

  try {
    return await dataSource.getUsage();
  } catch (e) {
    // 获取失败返回null
    return null;
  }
});

/// AI生成历史Provider
final aiHistoryProvider = FutureProvider<List<AIGenerationHistory>>((ref) async {
  final dataSource = ref.watch(aiPlanningDataSourceProvider);

  try {
    return await dataSource.getHistory();
  } catch (e) {
    return [];
  }
});

/// AI规划状态Provider
final aiPlanningStateProvider = StateNotifierProvider<AIPlanningStateNotifier, AIPlanningState>((ref) {
  return AIPlanningStateNotifier(ref.watch(aiPlanningDataSourceProvider));
});

/// AI规划状态
class AIPlanningState {
  final AIPlanModel? plan;
  final bool isLoading;
  final String? error;

  AIPlanningState({
    this.plan,
    this.isLoading = false,
    this.error,
  });

  AIPlanningState copyWith({
    AIPlanModel? plan,
    bool? isLoading,
    String? error,
  }) {
    return AIPlanningState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasGenerated => plan != null;
}

/// AI规划状态管理
class AIPlanningStateNotifier extends StateNotifier<AIPlanningState> {
  final AIPlanningDataSource _dataSource;

  AIPlanningStateNotifier(this._dataSource) : super(AIPlanningState());

  /// 生成AI旅行计划
  Future<AIPlanModel?> generatePlan({
    required String destinationName,
    required String budgetLevel,
    required String startDate,
    required String endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final plan = await _dataSource.generatePlan(
        destinationName: destinationName,
        budgetLevel: budgetLevel,
        startDate: startDate,
        endDate: endDate,
      );

      state = AIPlanningState(plan: plan, isLoading: false);
      return plan;
    } on AIPlanningException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.friendlyMessage,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'AI生成失败，请稍后重试',
      );
      return null;
    }
  }

  /// 清除当前计划
  void clearPlan() {
    state = AIPlanningState();
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}
