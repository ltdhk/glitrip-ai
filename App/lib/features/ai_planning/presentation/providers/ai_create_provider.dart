// AI Create Provider
//
// 使用Riverpod管理AI智能创建目的地的状态

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../destinations/data/repositories/local_destination_repository.dart';
import '../../../itinerary/presentation/providers/itinerary_provider.dart';
import '../../data/datasources/ai_planning_datasource_v2.dart';
import '../../data/models/ai_plan_model_v2.dart';

/// AI规划数据源Provider V2
final aiPlanningDataSourceV2Provider = Provider<AIPlanningDataSourceV2>((ref) {
  final authDataSource = ref.watch(authDataSourceProvider);
  return AIPlanningDataSourceV2(authDataSource);
});

/// 本地目的地Repository Provider
final localDestinationRepositoryProvider = Provider<LocalDestinationRepository>((ref) {
  return LocalDestinationRepository();
});

/// AI使用情况Provider V2
final aiUsageV2Provider = FutureProvider<AIUsageModelV2?>((ref) async {
  final dataSource = ref.watch(aiPlanningDataSourceV2Provider);

  try {
    return await dataSource.getUsage();
  } catch (e) {
    return null;
  }
});

/// AI创建状态Provider
final aiCreateStateProvider =
    StateNotifierProvider<AICreateStateNotifier, AICreateState>((ref) {
  return AICreateStateNotifier(
    ref.watch(aiPlanningDataSourceV2Provider),
    ref.watch(localDestinationRepositoryProvider),
    ref,
  );
});

/// AI创建状态
class AICreateState {
  final AIPlanModelV2? plan;
  final bool isGenerating;
  final bool isSaving;
  final String? error;
  final String? savedDestinationId;

  AICreateState({
    this.plan,
    this.isGenerating = false,
    this.isSaving = false,
    this.error,
    this.savedDestinationId,
  });

  AICreateState copyWith({
    AIPlanModelV2? plan,
    bool? isGenerating,
    bool? isSaving,
    String? error,
    String? savedDestinationId,
  }) {
    return AICreateState(
      plan: plan ?? this.plan,
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      savedDestinationId: savedDestinationId ?? this.savedDestinationId,
    );
  }

  bool get hasGenerated => plan != null;
  bool get isLoading => isGenerating || isSaving;
}

/// AI创建状态管理
class AICreateStateNotifier extends StateNotifier<AICreateState> {
  final AIPlanningDataSourceV2 _dataSource;
  final LocalDestinationRepository _repository;
  final Ref _ref;

  AICreateStateNotifier(this._dataSource, this._repository, this._ref)
      : super(AICreateState());

  /// 生成AI计划（不需要country参数）
  Future<AIPlanModelV2?> generatePlan({
    required String destinationName,
    required String budgetLevel,
    required String startDate,
    required String endDate,
  }) async {
    state = state.copyWith(isGenerating: true, error: null);

    try {
      // 获取当前语言设置
      final currentLocale = _ref.read(localeProvider);
      final language = currentLocale.languageCode; // 'zh' 或 'en'

      final plan = await _dataSource.generatePlanV2(
        destinationName: destinationName,
        budgetLevel: budgetLevel,
        startDate: startDate,
        endDate: endDate,
        language: language, // 传递语言参数
      );

      state = AICreateState(plan: plan, isGenerating: false);
      return plan;
    } on AIPlanningExceptionV2 catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.friendlyMessage,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'AI生成失败，请稍后重试',
      );
      return null;
    }
  }

  /// 保存AI计划到本地数据库
  Future<String?> savePlan({
    required AIPlanModelV2 plan,
    required String budgetLevel,
    required DateTime startDate,
    required DateTime endDate,
    required String destinationName,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final destinationId = await _repository.saveAIPlan(
        plan: plan,
        budgetLevel: budgetLevel,
        startDate: startDate,
        endDate: endDate,
        destinationName: destinationName,
      );

      // 刷新行程provider以更新UI
      print('🔄 保存成功，刷新itineraryProvider以加载新的行程数据');
      _ref.invalidate(itineraryProvider);

      state = AICreateState(
        plan: plan,
        isSaving: false,
        savedDestinationId: destinationId,
      );
      return destinationId;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: '保存失败: ${e.toString()}',
      );
      return null;
    }
  }

  /// 清除当前计划
  void clearPlan() {
    state = AICreateState();
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}
