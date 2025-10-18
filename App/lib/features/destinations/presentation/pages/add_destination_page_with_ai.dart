/// Add Destination Page with AI Integration
///
/// 集成AI规划功能的目的地添加页面
///
/// 使用说明：
/// 1. 在 add_destination_page.dart 中导入此文件
/// 2. 在 build() 方法的 Column children 中，在基础信息部分之后添加 AI 规划按钮
/// 3. 参考下面的示例代码

import 'package:flutter/material.dart';
import '../../../ai_planning/data/models/ai_plan_model.dart';

/// 集成步骤：
///
/// 1. 在 add_destination_page.dart 的顶部添加导入：
///    import '../../../ai_planning/presentation/widgets/ai_plan_button.dart';
///
/// 2. 在 _AddDestinationPageState 类中添加方法：
///    void _handleAIPlanGenerated(AIPlanModel plan) {
///      setState(() {
///        // 设置标语到描述（如果描述为空）
///        if (_descriptionController.text.isEmpty) {
///          _descriptionController.text = '${plan.tagline}\n\n${plan.description}';
///        }
///
///        // 设置标签
///        _tags = List.from(plan.tags);
///      });
///
///      // TODO: 保存每日行程、打包清单、待办事项到数据库
///      // 这些数据需要在保存目的地后，使用目的地ID插入到相关表中
///
///      ScaffoldMessenger.of(context).showSnackBar(
///        const SnackBar(
///          content: Text('AI规划已应用！请检查并保存目的地。'),
///          backgroundColor: Colors.green,
///        ),
///      );
///    }
///
/// 3. 在 build() 方法中，在基础信息部分（第147行，_buildTextField for description之后）添加：
///    const SizedBox(height: 24),
///    // AI规划部分
///    if (!_isEditing) ...[
///      _buildSectionHeader('AI智能规划', Icons.auto_awesome),
///      const SizedBox(height: 8),
///      Text(
///        '让AI帮你规划行程，自动生成描述、标签和行程安排',
///        style: TextStyle(color: Colors.grey[600], fontSize: 14),
///      ),
///      const SizedBox(height: 16),
///      AIPlanButton(
///        destinationName: _nameController.text,
///        budgetLevel: _selectedBudgetLevel.toString().split('.').last,
///        startDate: _startDate,
///        endDate: _endDate,
///        onPlanGenerated: _handleAIPlanGenerated,
///      ),
///      const SizedBox(height: 24),
///    ],

/// 保存AI生成的数据到数据库
///
/// 当前的 add_destination_page 只保存目的地基本信息。
/// AI生成的每日行程、打包清单、待办事项需要保存到对应的表中。
///
/// 建议的实现方式：
/// 1. 在 _AddDestinationPageState 中添加字段存储AI生成的数据：
///    AIPlanModel? _aiGeneratedPlan;
///
/// 2. 在 _handleAIPlanGenerated 方法中保存计划：
///    _aiGeneratedPlan = plan;
///
/// 3. 在 _saveDestination 方法中，保存目的地后，如果有AI生成的数据则保存：
///    if (_aiGeneratedPlan != null) {
///      // 保存每日行程
///      for (var itinerary in _aiGeneratedPlan!.dailyItineraries) {
///        await ref.read(dailyItinerariesProvider.notifier).addItinerary(
///          destinationId: destination.id!,
///          dayNumber: itinerary.dayNumber,
///          activities: itinerary.activities,
///          meals: itinerary.meals,
///          notes: itinerary.notes,
///        );
///      }
///
///      // 保存打包清单
///      for (var item in _aiGeneratedPlan!.packingItems) {
///        await ref.read(packingItemsProvider.notifier).addItem(
///          destinationId: destination.id!,
///          name: item.name,
///          category: item.category,
///          quantity: item.quantity,
///        );
///      }
///
///      // 保存待办事项
///      for (var todo in _aiGeneratedPlan!.todoItems) {
///        await ref.read(todoItemsProvider.notifier).addTodo(
///          destinationId: destination.id!,
///          title: todo.title,
///          deadline: todo.deadline,
///        );
///      }
///    }

class AIIntegrationHelper {
  /// 将AI生成的数据应用到表单
  static void applyAIPlanToForm({
    required AIPlanModel plan,
    required TextEditingController descriptionController,
    required Function(List<String>) setTags,
  }) {
    // 设置描述
    if (descriptionController.text.isEmpty) {
      descriptionController.text = '${plan.tagline}\n\n${plan.description}';
    }

    // 设置标签
    setTags(List.from(plan.tags));
  }

  /// 格式化预算等级为API所需格式
  static String formatBudgetLevel(String budgetLevel) {
    // 将 BudgetLevel.low 转换为 'low'
    return budgetLevel.split('.').last;
  }
}
