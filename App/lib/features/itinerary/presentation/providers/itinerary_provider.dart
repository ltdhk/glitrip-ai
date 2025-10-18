import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/itinerary_day.dart';
import '../../data/datasources/itinerary_local_datasource.dart';
import '../../data/models/itinerary_day_model.dart';
import '../../../destinations/presentation/providers/destinations_provider.dart';

class ItineraryNotifier extends StateNotifier<AsyncValue<List<ItineraryDay>>> {
  final ItineraryLocalDataSource _dataSource;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Ref _ref;

  ItineraryNotifier(this._dataSource, this._ref) : super(const AsyncValue.loading()) {
    _loadDays();
  }

  Future<void> _loadDays() async {
    try {
      print('🔄 [ItineraryProvider] 开始加载所有行程数据...');
      final days = await _dataSource.getAllDays();
      print('🔄 [ItineraryProvider] 成功加载 ${days.length} 天的行程数据');

      // 按目的地分组统计
      final groupedByDestination = <String, int>{};
      for (var day in days) {
        groupedByDestination[day.destinationId] =
            (groupedByDestination[day.destinationId] ?? 0) + 1;
      }
      print('🔄 [ItineraryProvider] 行程分布: ${groupedByDestination.entries.map((e) => '${e.key.substring(0, 8)}...: ${e.value}天').join(', ')}');

      state = AsyncValue.data(days);
    } catch (e, stack) {
      print('❌ [ItineraryProvider] 加载行程数据失败: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addDay(ItineraryDay day) async {
    try {
      final dayModel = ItineraryDayModel.fromEntity(day);
      await _dataSource.insertDay(dayModel);
      await _loadDays();
      // 更新目的地预算
      await _updateDestinationBudget(day.destinationId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateDay(ItineraryDay updatedDay) async {
    try {
      final dayModel = ItineraryDayModel.fromEntity(updatedDay);
      await _dataSource.updateDay(dayModel);
      await _loadDays();
      // 更新目的地预算
      await _updateDestinationBudget(updatedDay.destinationId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteDay(String dayId) async {
    try {
      // 在删除前获取目的地ID
      final currentDays = state.value ?? [];
      final day = currentDays.firstWhere((d) => d.id == dayId);
      final destinationId = day.destinationId;

      await _dataSource.deleteDay(dayId);
      await _loadDays();
      // 更新目的地预算
      await _updateDestinationBudget(destinationId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addActivity(String dayId, ItineraryActivity activity) async {
    try {
      // 找到对应的天，添加活动后更新
      final currentDays = state.value ?? [];
      final dayIndex = currentDays.indexWhere((d) => d.id == dayId);
      if (dayIndex != -1) {
        final day = currentDays[dayIndex];
        final updatedDay = day.copyWith(
          activities: [...day.activities, activity],
          updatedAt: DateTime.now(),
        );
        await updateDay(updatedDay);
        // 更新目的地预算
        await _updateDestinationBudget(day.destinationId);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateActivity(
      String dayId, ItineraryActivity updatedActivity) async {
    try {
      final currentDays = state.value ?? [];
      final dayIndex = currentDays.indexWhere((d) => d.id == dayId);
      if (dayIndex != -1) {
        final day = currentDays[dayIndex];
        final updatedDay = day.copyWith(
          activities: [
            for (final activity in day.activities)
              if (activity.id == updatedActivity.id)
                updatedActivity
              else
                activity,
          ],
          updatedAt: DateTime.now(),
        );
        await updateDay(updatedDay);
        // 更新目的地预算
        await _updateDestinationBudget(day.destinationId);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteActivity(String dayId, String activityId) async {
    try {
      final currentDays = state.value ?? [];
      final dayIndex = currentDays.indexWhere((d) => d.id == dayId);
      if (dayIndex != -1) {
        final day = currentDays[dayIndex];
        final updatedDay = day.copyWith(
          activities: day.activities
              .where((activity) => activity.id != activityId)
              .toList(),
          updatedAt: DateTime.now(),
        );
        await updateDay(updatedDay);
        // 更新目的地预算
        await _updateDestinationBudget(day.destinationId);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 重新计算并更新目的地的预算
  Future<void> _updateDestinationBudget(String destinationId) async {
    try {
      // 获取该目的地的所有行程
      final currentDays = state.value ?? [];
      final destinationDays = currentDays
          .where((day) => day.destinationId == destinationId)
          .toList();

      // 计算所有活动的总费用
      double totalCost = 0;
      for (final day in destinationDays) {
        for (final activity in day.activities) {
          if (activity.cost != null) {
            totalCost += activity.cost!;
          }
        }
      }

      // 更新目的地的estimated_cost
      final db = await _dbHelper.database;
      await db.update(
        'destinations',
        {'estimated_cost': totalCost, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [destinationId],
      );

      // 刷新destinations provider以更新UI
      _ref.invalidate(destinationsProvider);
    } catch (e) {
      // 静默失败，不影响主要操作
      // 使用开发日志而不是print
      if (e.toString().isNotEmpty) {
        // 记录错误但不中断流程
      }
    }
  }

  List<ItineraryDay> getDaysForDestination(String destinationId) {
    return state.when(
      data: (days) =>
          days.where((day) => day.destinationId == destinationId).toList()
            ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber)),
      loading: () => [],
      error: (_, __) => [],
    );
  }
}

// 创建数据源的Provider
final itineraryLocalDataSourceProvider =
    Provider<ItineraryLocalDataSource>((ref) {
  return ItineraryLocalDataSource(DatabaseHelper.instance);
});

// 行程管理的Provider
final itineraryProvider =
    StateNotifierProvider<ItineraryNotifier, AsyncValue<List<ItineraryDay>>>(
  (ref) {
    final dataSource = ref.watch(itineraryLocalDataSourceProvider);
    return ItineraryNotifier(dataSource, ref);
  },
);

// 为特定目的地提供行程的Provider
final destinationItineraryProvider =
    Provider.family<List<ItineraryDay>, String>(
  (ref, destinationId) {
    print('📍 [destinationItineraryProvider] 请求目的地行程，destinationId: $destinationId');
    final itineraryAsync = ref.watch(itineraryProvider);
    return itineraryAsync.when(
      data: (days) {
        print('📍 [destinationItineraryProvider] itineraryProvider有 ${days.length} 天数据');
        final filtered = days.where((day) => day.destinationId == destinationId).toList()
          ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
        print('📍 [destinationItineraryProvider] 筛选后得到 ${filtered.length} 天的行程');
        return filtered;
      },
      loading: () {
        print('📍 [destinationItineraryProvider] itineraryProvider正在加载中...');
        return [];
      },
      error: (e, _) {
        print('📍 [destinationItineraryProvider] itineraryProvider出错: $e');
        return [];
      },
    );
  },
);
