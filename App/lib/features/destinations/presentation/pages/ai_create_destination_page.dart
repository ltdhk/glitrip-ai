// AI Create Destination Page
//
// AI智能创建目的地页面 - 简洁的4字段表单

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../ai_planning/presentation/providers/ai_create_provider.dart';
import 'ai_plan_preview_page.dart';

class AICreateDestinationPage extends ConsumerStatefulWidget {
  const AICreateDestinationPage({super.key});

  @override
  ConsumerState<AICreateDestinationPage> createState() =>
      _AICreateDestinationPageState();
}

class _AICreateDestinationPageState
    extends ConsumerState<AICreateDestinationPage> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();

  String _selectedBudgetLevel = 'medium';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectTravelDates),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 显示生成对话框
    _showGeneratingDialog();

    // 生成AI计划
    final plan = await ref.read(aiCreateStateProvider.notifier).generatePlan(
          destinationName: _destinationController.text.trim(),
          budgetLevel: _selectedBudgetLevel,
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
        );

    if (mounted) {
      Navigator.of(context).pop(); // 关闭生成对话框

      if (plan != null) {
        // 成功：跳转到预览页面
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AIPlanPreviewPage(
              plan: plan,
              budgetLevel: _selectedBudgetLevel,
              startDate: _startDate!,
              endDate: _endDate!,
              destinationName: _destinationController.text.trim(),
            ),
          ),
        );
      } else {
        // 失败：显示错误消息
        final l10n = AppLocalizations.of(context);
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

  void _showGeneratingDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              l10n.aiPlanning,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aiPlanningTime,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final aiUsage = ref.watch(aiUsageV2Provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiSmartCreateDestination),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题和说明
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 32,
                    color: Color(0xFF00BCD4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.letAiPlanYourTrip,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.fourStepsAutoGenerate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 配额显示
              aiUsage.when(
                data: (usage) {
                  if (usage != null) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: usage.hasQuota
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: usage.hasQuota
                              ? Colors.green[200]!
                              : Colors.red[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            usage.hasQuota
                                ? Icons.check_circle
                                : Icons.error,
                            color: usage.hasQuota
                                ? Colors.green[600]
                                : Colors.red[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              usage.hasQuota
                                  ? l10n.remainingAiPlans(usage.remainingQuota)
                                  : l10n.aiQuotaExhausted,
                              style: TextStyle(
                                fontSize: 14,
                                color: usage.hasQuota
                                    ? Colors.green[800]
                                    : Colors.red[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 1. 目的地名称
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: l10n.destinationNameLabel,
                  hintText: l10n.destinationNameHint,
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00BCD4)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterDestinationName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 2. 预算级别
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.budgetLevelLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBudgetChip(l10n.budgetEconomy, 'low', Icons.savings),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBudgetChip(l10n.budgetComfort, 'medium', Icons.hotel),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBudgetChip(l10n.budgetLuxury, 'high', Icons.diamond),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. 出行日期
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.travelDatesLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateSelector(
                          l10n.startDateLabel,
                          _startDate,
                          (date) => setState(() => _startDate = date),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateSelector(
                          l10n.endDateLabel,
                          _endDate,
                          (date) => setState(() => _endDate = date),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // AI生成按钮
              FilledButton.icon(
                onPressed: _handleGenerate,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  l10n.aiSmartPlanButton,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 提示信息
              Text(
                l10n.aiAutoDetectCountry,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetChip(String label, String value, IconData icon) {
    final isSelected = _selectedBudgetLevel == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedBudgetLevel = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BCD4) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged,
  ) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        onChanged(pickedDate);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                  : l10n.selectDate,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: date != null ? Colors.black87 : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
