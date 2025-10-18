import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/destination.dart';
import '../providers/destinations_provider.dart';
import '../../../travel_buddy/presentation/providers/travel_buddy_provider.dart';
import '../../../travel_buddy/domain/entities/travel_buddy.dart'
    as buddy_entities;

class AddDestinationPage extends ConsumerStatefulWidget {
  final Destination? destination;

  const AddDestinationPage({super.key, this.destination});

  @override
  ConsumerState<AddDestinationPage> createState() => _AddDestinationPageState();
}

class _AddDestinationPageState extends ConsumerState<AddDestinationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bestTimeController = TextEditingController();
  final _estimatedCostController = TextEditingController();
  final _travelNotesController = TextEditingController();

  DestinationStatus _selectedStatus = DestinationStatus.wishlist;
  BudgetLevel _selectedBudgetLevel = BudgetLevel.medium;
  int _recommendedDays = 3;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _tags = [];
  final _tagController = TextEditingController();
  List<String> _selectedBuddyIds = [];

  bool get _isEditing => widget.destination != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    final dest = widget.destination!;
    _nameController.text = dest.name;
    _countryController.text = dest.country;
    _descriptionController.text = dest.description ?? '';
    _bestTimeController.text = dest.bestTimeDescription ?? '';
    _estimatedCostController.text = dest.estimatedCost?.toString() ?? '';
    _travelNotesController.text = dest.travelNotes ?? '';

    _selectedStatus = dest.status;
    _selectedBudgetLevel = dest.budgetLevel;
    _recommendedDays = dest.recommendedDays;
    _startDate = dest.startDate;
    _endDate = dest.endDate;
    _tags = List.from(dest.tags);
    _selectedBuddyIds = List.from(dest.travelBuddyIds);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _bestTimeController.dispose();
    _estimatedCostController.dispose();
    _travelNotesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editDestination : l10n.addDestination),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveDestination,
            child: Text(
              l10n.save,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(l10n.newDestination, Icons.flight_takeoff),
              Text(
                l10n.planYourNextAdventure,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.basicInformation),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: l10n.destinationName,
                icon: Icons.location_on,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.pleaseEnterDestinationName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _countryController,
                label: l10n.country,
                icon: Icons.public,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.pleaseEnterCountry;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: l10n.description,
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.travelDetails),
              const SizedBox(height: 16),
              _buildStatusSelector(l10n),
              const SizedBox(height: 16),
              _buildBudgetLevelSelector(l10n),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _estimatedCostController,
                label: l10n.estimatedCost,
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final cost = double.tryParse(value.trim());
                    if (cost == null || cost < 0) {
                      return l10n.pleaseEnterValidCost;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildRecommendedDaysSelector(l10n),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.bestTimeToVisit),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bestTimeController,
                label: l10n.bestTimeExample,
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              _buildDateSelectors(l10n),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.tags),
              const SizedBox(height: 16),
              _buildTagsSection(l10n),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.travelBuddies),
              const SizedBox(height: 16),
              _buildTravelBuddySelector(),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.notes),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _travelNotesController,
                label: l10n.travelNotes,
                icon: Icons.note,
                maxLines: 4,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, [IconData? icon]) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: const Color(0xFF00BCD4)),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: icon != null ? 20 : 14,
            fontWeight: icon != null ? FontWeight.bold : FontWeight.w500,
            color: icon != null ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00BCD4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00BCD4)),
        ),
      ),
    );
  }

  Widget _buildStatusSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.status,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatusChip(
                l10n.wishlist,
                DestinationStatus.wishlist,
                Icons.star,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusChip(
                l10n.planned,
                DestinationStatus.planned,
                Icons.schedule,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusChip(
                l10n.visited,
                DestinationStatus.visited,
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(
      String label, DestinationStatus status, IconData icon, Color color) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
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

  Widget _buildBudgetLevelSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.budgetLevel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildBudgetChip('\$', BudgetLevel.low),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBudgetChip('\$\$', BudgetLevel.medium),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBudgetChip('\$\$\$', BudgetLevel.high),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetChip(String label, BudgetLevel level) {
    final isSelected = _selectedBudgetLevel == level;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBudgetLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BCD4) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedDaysSelector(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.access_time, color: Color(0xFF00BCD4)),
        const SizedBox(width: 8),
        Text(
          l10n.recommendedDays(_recommendedDays),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_recommendedDays > 1) {
                    setState(() {
                      _recommendedDays--;
                    });
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              Text(
                '$_recommendedDays',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _recommendedDays++;
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectors(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                l10n.startDate,
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateSelector(
                l10n.endDate,
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector(
      String label, DateTime? date, Function(DateTime?) onChanged) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
                  ? '${date.month}/${date.day}/${date.year}'
                  : 'Sep 15, 2025',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: l10n.addTagAndPressReturn,
                  prefixIcon:
                      const Icon(Icons.local_offer, color: Color(0xFF00BCD4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00BCD4)),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty &&
                      !_tags.contains(value.trim())) {
                    setState(() {
                      _tags.add(value.trim());
                      _tagController.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
                deleteIconColor: const Color(0xFF00BCD4),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTravelBuddySelector() {
    final l10n = AppLocalizations.of(context);
    final travelBuddiesAsync = ref.watch(travelBuddiesProvider);

    return travelBuddiesAsync.when(
      data: (buddies) {
        if (buddies.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.noTravelBuddiesYet,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: buddies.map((buddy) {
                  final isSelected = _selectedBuddyIds.contains(buddy.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedBuddyIds.add(buddy.id!);
                        } else {
                          _selectedBuddyIds.remove(buddy.id);
                        }
                      });
                    },
                    title: Text(buddy.name),
                    subtitle: _buildBuddyMetaLineRich(buddy),
                    secondary: CircleAvatar(
                      backgroundColor: const Color(0xFF00BCD4),
                      child: Text(
                        buddy.name.isNotEmpty
                            ? buddy.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    activeColor: const Color(0xFF00BCD4),
                  );
                }).toList(),
              ),
            ),
            if (_selectedBuddyIds.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.selectedTravelBuddies(_selectedBuddyIds.length),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Text(l10n.loadingTravelBuddiesFailed(error.toString())),
    );
  }

  // 旧的纯文本副标题已不再使用

  Widget _buildBuddyMetaLineRich(buddy_entities.TravelBuddy buddy) {
    final l10n = AppLocalizations.of(context);
    final String budgetText = _getBuddyBudgetText(buddy.budgetLevel, l10n);
    final List<String> prefLabels = buddy.travelPreferences
        .map((p) => _getBuddyPreferenceLabel(p, l10n))
        .where((t) => t.isNotEmpty)
        .toList();

    final String prefsText = prefLabels.isNotEmpty ? prefLabels.join('、') : '';

    if (budgetText.isEmpty && prefsText.isEmpty && buddy.email.isEmpty) {
      return const SizedBox.shrink();
    }

    final baseStyle = TextStyle(fontSize: 12, color: Colors.grey[700]);
    const accentColor = Color(0xFF00BCD4);

    return Text.rich(
      TextSpan(children: [
        if (budgetText.isNotEmpty) ...[
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.attach_money, size: 14, color: accentColor),
          ),
          const WidgetSpan(child: SizedBox(width: 2)),
          TextSpan(text: budgetText, style: baseStyle),
        ],
        if (budgetText.isNotEmpty && prefsText.isNotEmpty)
          TextSpan(text: ' · ', style: baseStyle),
        if (prefsText.isNotEmpty) ...[
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.interests, size: 14, color: accentColor),
          ),
          const WidgetSpan(child: SizedBox(width: 2)),
          TextSpan(text: prefsText, style: baseStyle),
        ],
        if (budgetText.isEmpty && prefsText.isEmpty && buddy.email.isNotEmpty)
          TextSpan(text: buddy.email, style: baseStyle),
      ]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _getBuddyBudgetText(
      buddy_entities.BudgetLevel level, AppLocalizations l10n) {
    switch (level) {
      case buddy_entities.BudgetLevel.low:
        return l10n.low;
      case buddy_entities.BudgetLevel.medium:
        return l10n.medium;
      case buddy_entities.BudgetLevel.high:
        return l10n.high;
    }
  }

  String _getBuddyPreferenceLabel(
      buddy_entities.TravelPreference preference, AppLocalizations l10n) {
    switch (preference) {
      case buddy_entities.TravelPreference.adventure:
        return l10n.adventure;
      case buddy_entities.TravelPreference.relaxation:
        return l10n.relaxation;
      case buddy_entities.TravelPreference.culture:
        return l10n.culture;
      case buddy_entities.TravelPreference.foodie:
        return l10n.foodie;
      case buddy_entities.TravelPreference.nature:
        return l10n.nature;
      case buddy_entities.TravelPreference.urban:
        return l10n.urban;
    }
  }

  void _saveDestination() async {
    final l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证日期逻辑
    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.startDateMustBeBeforeEndDate),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final destination = _isEditing
        ? widget.destination!.copyWith(
            name: _nameController.text.trim(),
            country: _countryController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            status: _selectedStatus,
            budgetLevel: _selectedBudgetLevel,
            estimatedCost: _estimatedCostController.text.trim().isEmpty
                ? null
                : double.tryParse(_estimatedCostController.text.trim()),
            recommendedDays: _recommendedDays,
            bestTimeDescription: _bestTimeController.text.trim().isEmpty
                ? null
                : _bestTimeController.text.trim(),
            startDate: _startDate,
            endDate: _endDate,
            tags: _tags,
            travelNotes: _travelNotesController.text.trim().isEmpty
                ? null
                : _travelNotesController.text.trim(),
            travelBuddyIds: _selectedBuddyIds,
          )
        : Destination.create(
            name: _nameController.text.trim(),
            country: _countryController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            status: _selectedStatus,
            budgetLevel: _selectedBudgetLevel,
            estimatedCost: _estimatedCostController.text.trim().isEmpty
                ? null
                : double.tryParse(_estimatedCostController.text.trim()),
            recommendedDays: _recommendedDays,
            bestTimeDescription: _bestTimeController.text.trim().isEmpty
                ? null
                : _bestTimeController.text.trim(),
            startDate: _startDate,
            endDate: _endDate,
            tags: _tags,
            travelNotes: _travelNotesController.text.trim().isEmpty
                ? null
                : _travelNotesController.text.trim(),
            travelBuddyIds: _selectedBuddyIds,
          );

    try {
      if (_isEditing) {
        await ref
            .read(destinationsProvider.notifier)
            .updateDestination(destination);
      } else {
        await ref
            .read(destinationsProvider.notifier)
            .addDestination(destination);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSavingDestination(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
