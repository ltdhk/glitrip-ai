// AI Plan Preview Page
//
// 显示AI生成的完整旅行计划预览，用户确认后保存

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../ai_planning/data/models/ai_plan_model_v2.dart';
import '../../../ai_planning/presentation/providers/ai_create_provider.dart';
import '../providers/destinations_provider.dart';

class AIPlanPreviewPage extends ConsumerWidget {
  final AIPlanModelV2 plan;
  final String budgetLevel;
  final DateTime startDate;
  final DateTime endDate;
  final String destinationName;

  const AIPlanPreviewPage({
    super.key,
    required this.plan,
    required this.budgetLevel,
    required this.startDate,
    required this.endDate,
    required this.destinationName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final aiState = ref.watch(aiCreateStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiPlanPreview),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 目的地标题
                  _buildHeader(context),
                  const SizedBox(height: 24),

                  // Tagline和Tags
                  _buildTaglineAndTags(),
                  const SizedBox(height: 24),

                  // 详细描述
                  _buildDescription(l10n),
                  const SizedBox(height: 24),

                  // 每日行程
                  _buildItineraries(l10n),
                  const SizedBox(height: 24),

                  // 打包清单
                  _buildPackingList(l10n),
                  const SizedBox(height: 24),

                  // 待办事项
                  _buildTodoList(l10n),
                  const SizedBox(height: 80), // 为底部按钮留空间
                ],
              ),
            ),
          ),

          // 底部按钮
          _buildBottomActions(context, ref, aiState, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.planGeneratedSuccessfully,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          destinationName, // 直接使用用户输入的目的地名称
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          plan.country,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getDateRangeText(l10n),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTaglineAndTags() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00BCD4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.tagline,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: plan.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: const Color(0xFF00BCD4).withOpacity(0.2),
                labelStyle: const TextStyle(
                  color: Color(0xFF00BCD4),
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.description, Icons.description),
        const SizedBox(height: 12),
        Text(
          plan.detailedDescription,
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildItineraries(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.detailedItinerary, Icons.calendar_today),
        const SizedBox(height: 12),
        ...plan.itineraries.map((itinerary) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCD4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.dayNumberLabel(itinerary.dayNumber),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      itinerary.date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  itinerary.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...itinerary.activities.map((activity) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${activity.startTime}-${activity.endTime}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      activity.location,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              if (activity.estimatedCost != null) ...[
                                const SizedBox(height: 4),
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context);
                                    return Text(
                                      '${l10n.estimatedCost}: ${l10n.currencySymbol}${activity.estimatedCost!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPackingList(AppLocalizations l10n) {
    // 按分类分组
    final Map<String, List<PackingItemModelV2>> grouped = {};
    for (var item in plan.packingItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.packagedItems, Icons.luggage),
        const SizedBox(height: 12),
        ...grouped.entries.map((entry) {
          return ExpansionTile(
            title: Text(
              _getCategoryName(entry.key, l10n),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(l10n.itemsCount(entry.value.length)),
            children: entry.value.map((item) {
              return ListTile(
                dense: true,
                leading: Icon(
                  item.isEssential ? Icons.star : Icons.circle_outlined,
                  size: 16,
                  color: item.isEssential
                      ? Colors.orange
                      : Colors.grey[400],
                ),
                title: Text(item.name),
                trailing: Text('x${item.quantity}'),
              );
            }).toList(),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTodoList(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.todoItems, Icons.checklist),
        const SizedBox(height: 12),
        ...plan.todoChecklist.map((todo) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _getPriorityIcon(todo.priority),
                  color: _getPriorityColor(todo.priority),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (todo.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00BCD4)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    AICreateState state,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: state.isSaving ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: state.isSaving ? null : () => _handleSave(context, ref, l10n),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.savePlan,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final destinationId = await ref.read(aiCreateStateProvider.notifier).savePlan(
          plan: plan,
          budgetLevel: budgetLevel,
          startDate: startDate,
          endDate: endDate,
          destinationName: destinationName,
        );

    if (context.mounted) {
      if (destinationId != null) {
        // 保存成功，刷新目的地列表和统计
        ref.invalidate(destinationsProvider);
        ref.invalidate(destinationStatsProvider);

        // 返回到目的地列表
        Navigator.of(context).popUntil((route) => route.isFirst);

        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.planSavedSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // 保存失败
        final error = ref.read(aiCreateStateProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? l10n.aiFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDateRangeText(AppLocalizations l10n) {
    final locale = l10n.localeName;

    if (locale == 'zh') {
      // 中文日期格式：10月27日 - 10月31日 · 5天
      return '${startDate.month}月${startDate.day}日 - ${endDate.month}月${endDate.day}日 · ${l10n.daysCount(plan.itineraries.length)}';
    } else {
      // 英文日期格式：Oct 27 - Oct 31 · 5 days
      final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[startDate.month]} ${startDate.day} - ${months[endDate.month]} ${endDate.day} · ${l10n.daysCount(plan.itineraries.length)}';
    }
  }

  String _getCategoryName(String category, AppLocalizations l10n) {
    final map = {
      'clothing': l10n.categoryClothing,
      'electronics': l10n.categoryElectronics,
      'cosmetics': l10n.categoryCosmetics,
      'health': l10n.categoryHealth,
      'accessories': l10n.categoryAccessories,
      'books': l10n.categoryBooks,
      'entertainment': l10n.categoryEntertainment,
      'other': l10n.categoryOther,
    };
    return map[category] ?? category;
  }

  IconData _getPriorityIcon(String? priority) {
    switch (priority) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.remove;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
