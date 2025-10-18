/// AI Plan Button Widget
///
/// AI规划按钮和对话框

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_planning_provider.dart';
import '../../data/models/ai_plan_model.dart';

class AIPlanButton extends ConsumerWidget {
  final String destinationName;
  final String budgetLevel;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(AIPlanModel) onPlanGenerated;

  const AIPlanButton({
    super.key,
    required this.destinationName,
    required this.budgetLevel,
    required this.startDate,
    required this.endDate,
    required this.onPlanGenerated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiUsage = ref.watch(aiUsageProvider);

    return aiUsage.when(
      data: (usage) {
        final hasQuota = usage?.hasQuota ?? false;
        final remainingQuota = usage?.remainingQuota ?? 0;

        return Column(
          children: [
            // AI规划按钮
            FilledButton.icon(
              onPressed: hasQuota
                  ? () => _showAIDialog(context, ref)
                  : null,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('使用AI规划行程'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 配额显示
            if (usage != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasQuota
                        ? '剩余 $remainingQuota 次AI规划'
                        : 'AI规划次数已用尽',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasQuota ? Colors.grey[600] : Colors.red,
                    ),
                  ),
                  if (!hasQuota) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _navigateToUpgrade(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 24),
                      ),
                      child: const Text(
                        '升级VIP',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => FilledButton.icon(
        onPressed: () => _showAIDialog(context, ref),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('使用AI规划行程'),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF00BCD4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showAIDialog(BuildContext context, WidgetRef ref) {
    // 验证必填字段
    if (destinationName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先输入目的地名称'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先选择出行日期'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AIGenerationDialog(
        destinationName: destinationName,
        budgetLevel: budgetLevel,
        startDate: startDate!,
        endDate: endDate!,
        onPlanGenerated: onPlanGenerated,
      ),
    );
  }

  void _navigateToUpgrade(BuildContext context) {
    // TODO: 导航到VIP升级页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('VIP升级功能即将推出'),
      ),
    );
  }
}

class _AIGenerationDialog extends ConsumerStatefulWidget {
  final String destinationName;
  final String budgetLevel;
  final DateTime startDate;
  final DateTime endDate;
  final Function(AIPlanModel) onPlanGenerated;

  const _AIGenerationDialog({
    required this.destinationName,
    required this.budgetLevel,
    required this.startDate,
    required this.endDate,
    required this.onPlanGenerated,
  });

  @override
  ConsumerState<_AIGenerationDialog> createState() => _AIGenerationDialogState();
}

class _AIGenerationDialogState extends ConsumerState<_AIGenerationDialog> {
  @override
  void initState() {
    super.initState();
    _generatePlan();
  }

  Future<void> _generatePlan() async {
    final plan = await ref.read(aiPlanningStateProvider.notifier).generatePlan(
          destinationName: widget.destinationName,
          budgetLevel: widget.budgetLevel,
          startDate: widget.startDate.toIso8601String().split('T')[0],
          endDate: widget.endDate.toIso8601String().split('T')[0],
        );

    if (plan != null && mounted) {
      widget.onPlanGenerated(plan);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI规划生成成功！'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiPlanningStateProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (aiState.isLoading) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'AI正在为您规划行程...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '这可能需要几秒钟',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ] else if (aiState.error != null) ...[
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'AI生成失败',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              aiState.error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () {
                    ref.read(aiPlanningStateProvider.notifier).clearError();
                    _generatePlan();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
