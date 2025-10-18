/// Local Destination Repository
///
/// 保存AI生成的完整目的地数据到本地SQLite数据库

import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../ai_planning/data/models/ai_plan_model_v2.dart';

class LocalDestinationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _uuid = const Uuid();

  /// 保存AI生成的完整计划到本地数据库
  /// 使用事务确保数据一致性
  Future<String> saveAIPlan({
    required AIPlanModelV2 plan,
    required String budgetLevel,
    required DateTime startDate,
    required DateTime endDate,
    required String destinationName, // 用户输入的目的地名称（必需）
  }) async {
    return await _dbHelper.transaction((txn) async {
      final destinationId = _uuid.v4();
      final now = DateTime.now().toIso8601String();

      // 1. 保存目的地基本信息
      await txn.insert('destinations', {
        'id': destinationId,
        'name': destinationName, // 直接使用用户输入
        'country': plan.country,
        'description': plan.tagline, // 一句话短描述
        'travel_notes': plan.detailedDescription, // 详细长描述
        'status': 'planned',
        'budget_level': budgetLevel,
        'estimated_cost': _calculateTotalCost(plan),
        'recommended_days': plan.itineraries.length,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'tags': plan.tags.join(','),
        'created_at': now,
        'updated_at': now,
      });

      // 2. 保存每日行程
      await _saveItineraries(txn, destinationId, plan.itineraries, now);

      // 3. 保存打包清单
      await _savePackingItems(txn, destinationId, plan.packingItems, now);

      // 4. 保存待办事项
      await _saveTodos(txn, destinationId, plan.todoChecklist, now);

      return destinationId;
    });
  }

  /// 保存每日行程和活动
  Future<void> _saveItineraries(
    dynamic txn,
    String destinationId,
    List<DailyItineraryModelV2> itineraries,
    String timestamp,
  ) async {
    print('🔵 开始保存 ${itineraries.length} 天的行程数据到目的地 $destinationId');

    for (var itinerary in itineraries) {
      final dayId = _uuid.v4();

      // 保存行程天数
      await txn.insert('itinerary_days', {
        'id': dayId,
        'destination_id': destinationId,
        'title': itinerary.title,
        'date': itinerary.date,
        'day_number': itinerary.dayNumber,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      print('  ✅ 已保存第${itinerary.dayNumber}天: ${itinerary.title}, 包含${itinerary.activities.length}个活动');

      // 保存每天的活动
      for (var activity in itinerary.activities) {
        await txn.insert('itinerary_activities', {
          'id': _uuid.v4(),
          'day_id': dayId,
          'time': activity.startTime,
          'title': activity.title,
          'location': activity.location,
          'cost': activity.estimatedCost,
          'notes': _buildActivityNotes(activity),
          'is_booked': 0,
          'created_at': timestamp,
          'updated_at': timestamp,
        });
        print('    📌 活动: ${activity.title} @ ${activity.location}');
      }
    }
    print('🟢 所有行程数据保存完成！');
  }

  /// 保存打包清单
  Future<void> _savePackingItems(
    dynamic txn,
    String destinationId,
    List<PackingItemModelV2> items,
    String timestamp,
  ) async {
    for (var item in items) {
      await txn.insert('packing_items', {
        'id': _uuid.v4(),
        'destination_id': destinationId,
        'name': item.name,
        'category': _mapPackingCategory(item.category),
        'quantity': item.quantity,
        'is_essential': item.isEssential ? 1 : 0,
        'is_packed': 0,
        'language': 'zh',
        'created_at': timestamp,
        'updated_at': timestamp,
      });
    }
  }

  /// 保存待办事项
  Future<void> _saveTodos(
    dynamic txn,
    String destinationId,
    List<TodoItemModelV2> todos,
    String timestamp,
  ) async {
    for (var todo in todos) {
      await txn.insert('todos', {
        'id': _uuid.v4(),
        'destination_id': destinationId,
        'title': todo.title,
        'description': todo.description,
        'priority': todo.priority ?? 'medium',
        'is_completed': 0,
        'created_at': timestamp,
        'updated_at': timestamp,
      });
    }
  }

  /// 计算总费用（估算）
  double? _calculateTotalCost(AIPlanModelV2 plan) {
    double total = 0;
    for (var itinerary in plan.itineraries) {
      for (var activity in itinerary.activities) {
        if (activity.estimatedCost != null) {
          total += activity.estimatedCost!;
        }
      }
    }
    return total > 0 ? total : null;
  }

  /// 构建活动备注（包含时间范围和描述）
  String _buildActivityNotes(ActivityModel activity) {
    final notes = StringBuffer();
    notes.write('${activity.startTime} - ${activity.endTime}\n');
    notes.write(activity.description);
    if (activity.estimatedCost != null) {
      notes.write('\n\n预计费用: ¥${activity.estimatedCost!.toStringAsFixed(0)}');
    }
    return notes.toString();
  }

  /// 映射打包物品分类
  String _mapPackingCategory(String category) {
    // AI返回的category可能是英文，映射到本地数据库的分类
    const categoryMap = {
      'clothing': 'clothing',
      'electronics': 'electronics',
      'cosmetics': 'cosmetics',
      'health': 'health',
      'accessories': 'accessories',
      'books': 'books',
      'entertainment': 'entertainment',
      'other': 'other',
    };
    return categoryMap[category.toLowerCase()] ?? 'other';
  }
}
