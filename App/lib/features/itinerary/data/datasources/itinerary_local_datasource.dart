import 'package:flutter/foundation.dart';
import '../../../../core/database/database_helper.dart';
import '../models/itinerary_day_model.dart';
import '../../domain/entities/itinerary_day.dart';

class ItineraryLocalDataSource {
  final DatabaseHelper _dbHelper;

  ItineraryLocalDataSource(this._dbHelper);

  // 获取所有行程天数（包含活动）
  Future<List<ItineraryDayModel>> getAllDays() async {
    try {
      final daysData = await _dbHelper.query(
        'itinerary_days',
        orderBy: 'day_number ASC',
      );

      final List<ItineraryDayModel> days = [];
      for (var dayData in daysData) {
        final activities = await getActivitiesForDay(dayData['id'] as String);
        days.add(ItineraryDayModel.fromMap(dayData, activities: activities));
      }

      return days;
    } catch (e) {
      if (kDebugMode) {
        print('获取所有行程天数时出错: $e');
      }
      return [];
    }
  }

  // 获取特定目的地的行程
  Future<List<ItineraryDayModel>> getDaysByDestination(
      String destinationId) async {
    try {
      print('🔍 [ItineraryDataSource] 开始查询目的地行程，destinationId: $destinationId');

      final daysData = await _dbHelper.query(
        'itinerary_days',
        where: 'destination_id = ?',
        whereArgs: [destinationId],
        orderBy: 'day_number ASC',
      );

      print('🔍 [ItineraryDataSource] 查询到 ${daysData.length} 天的行程数据');

      final List<ItineraryDayModel> days = [];
      for (var dayData in daysData) {
        final dayId = dayData['id'] as String;
        final dayTitle = dayData['title'] as String?;
        final dayNumber = dayData['day_number'];

        print('  📅 处理第${dayNumber}天: $dayTitle (id: $dayId)');

        final activities = await getActivitiesForDay(dayId);
        print('    🎯 该天包含 ${activities.length} 个活动');

        days.add(ItineraryDayModel.fromMap(dayData, activities: activities));
      }

      print('🟢 [ItineraryDataSource] 返回 ${days.length} 天的行程数据（包含所有活动）');
      return days;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ItineraryDataSource] 获取目的地行程时出错: $e');
      }
      return [];
    }
  }

  // 获取某天的所有活动
  Future<List<ItineraryActivity>> getActivitiesForDay(String dayId) async {
    try {
      final activitiesData = await _dbHelper.query(
        'itinerary_activities',
        where: 'day_id = ?',
        whereArgs: [dayId],
        orderBy: 'time ASC',
      );

      return activitiesData
          .map((data) => ItineraryActivityModel.fromMap(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('获取活动列表时出错: $e');
      }
      return [];
    }
  }

  // 插入行程天数
  Future<void> insertDay(ItineraryDayModel day) async {
    try {
      await _dbHelper.insert('itinerary_days', day.toMap());

      // 插入该天的所有活动
      for (var activity in day.activities) {
        await insertActivity(ItineraryActivityModel.fromEntity(activity));
      }

      if (kDebugMode) {
        print('行程天数已插入: ${day.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('插入行程天数时出错: $e');
      }
      rethrow;
    }
  }

  // 更新行程天数
  Future<void> updateDay(ItineraryDayModel day) async {
    try {
      await _dbHelper.update(
        'itinerary_days',
        day.toMap(),
        where: 'id = ?',
        whereArgs: [day.id],
      );

      // 删除旧的活动并重新插入
      await _dbHelper.delete(
        'itinerary_activities',
        where: 'day_id = ?',
        whereArgs: [day.id],
      );

      for (var activity in day.activities) {
        await insertActivity(ItineraryActivityModel.fromEntity(activity));
      }

      if (kDebugMode) {
        print('行程天数已更新: ${day.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('更新行程天数时出错: $e');
      }
      rethrow;
    }
  }

  // 删除行程天数（会级联删除活动）
  Future<void> deleteDay(String dayId) async {
    try {
      await _dbHelper.delete(
        'itinerary_days',
        where: 'id = ?',
        whereArgs: [dayId],
      );

      if (kDebugMode) {
        print('行程天数已删除: $dayId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('删除行程天数时出错: $e');
      }
      rethrow;
    }
  }

  // 插入活动
  Future<void> insertActivity(ItineraryActivityModel activity) async {
    try {
      await _dbHelper.insert('itinerary_activities', activity.toMap());

      if (kDebugMode) {
        print('活动已插入: ${activity.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('插入活动时出错: $e');
      }
      rethrow;
    }
  }

  // 更新活动
  Future<void> updateActivity(ItineraryActivityModel activity) async {
    try {
      await _dbHelper.update(
        'itinerary_activities',
        activity.toMap(),
        where: 'id = ?',
        whereArgs: [activity.id],
      );

      if (kDebugMode) {
        print('活动已更新: ${activity.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('更新活动时出错: $e');
      }
      rethrow;
    }
  }

  // 删除活动
  Future<void> deleteActivity(String activityId) async {
    try {
      await _dbHelper.delete(
        'itinerary_activities',
        where: 'id = ?',
        whereArgs: [activityId],
      );

      if (kDebugMode) {
        print('活动已删除: $activityId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('删除活动时出错: $e');
      }
      rethrow;
    }
  }

  // 删除目的地的所有行程
  Future<void> deleteDaysByDestination(String destinationId) async {
    try {
      await _dbHelper.delete(
        'itinerary_days',
        where: 'destination_id = ?',
        whereArgs: [destinationId],
      );

      if (kDebugMode) {
        print('目的地的所有行程已删除: $destinationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('删除目的地行程时出错: $e');
      }
      rethrow;
    }
  }
}
