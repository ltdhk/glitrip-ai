import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/itinerary_day.dart';
import '../providers/itinerary_provider.dart';
import '../../../destinations/domain/entities/destination.dart';

class AddItineraryDayPage extends ConsumerStatefulWidget {
  final Destination destination;
  final ItineraryDay? day;

  const AddItineraryDayPage({
    super.key,
    required this.destination,
    this.day,
  });

  @override
  ConsumerState<AddItineraryDayPage> createState() =>
      _AddItineraryDayPageState();
}

class _AddItineraryDayPageState extends ConsumerState<AddItineraryDayPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _activityController = TextEditingController();
  final _locationController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int _dayNumber = 1;
  List<ItineraryActivity> _activities = [];
  bool _isBooked = false;

  @override
  void initState() {
    super.initState();
    if (widget.day != null) {
      _titleController.text = widget.day!.title;
      _selectedDate = widget.day!.date;
      _dayNumber = widget.day!.dayNumber;
      _activities = List.from(widget.day!.activities);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _activityController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.day != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        title: Text(isEditing ? l10n.editItineraryDay : l10n.addItineraryDay),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _canSave() ? _saveDay : null,
            child: Text(
              l10n.save,
              style: TextStyle(
                color: _canSave() ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDayInformation(l10n),
              const SizedBox(height: 24),
              _buildActivitiesSection(l10n),
              const SizedBox(height: 24),
              _buildAddActivitySection(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayInformation(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dayInformation.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: l10n.dayTitle,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a day title'; // TODO: 使用国际化
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(l10n.date, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}, ${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.numbers, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(l10n.day(_dayNumber), style: const TextStyle(fontSize: 16)),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    setState(() => _dayNumber = (_dayNumber - 1).clamp(1, 100)),
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _dayNumber = (_dayNumber + 1).clamp(1, 100)),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.activities.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          if (_activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.noActivitiesPlanned,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ..._activities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              return _buildActivityItem(activity, index, l10n);
            }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      ItineraryActivity activity, int index, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                activity.time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: activity.isBooked ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    if (activity.isBooked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 10, color: Colors.green),
                            const SizedBox(width: 2),
                            Text(
                              l10n.alreadyBooked,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (activity.cost != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.cost!.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeActivity(index),
            icon: const Icon(Icons.close, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAddActivitySection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addActivity.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _timeController,
            icon: Icons.access_time,
            hintText: l10n.timeExample,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _activityController,
            icon: Icons.edit,
            hintText: l10n.activityTitle,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _locationController,
            icon: Icons.location_on,
            hintText: l10n.location,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _costController,
            icon: Icons.attach_money,
            hintText: l10n.costOptional,
            color: Colors.green,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _notesController,
            icon: Icons.notes,
            hintText: l10n.notes,
            color: Colors.grey,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(l10n.alreadyBooked, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              Switch(
                value: _isBooked,
                onChanged: (value) => setState(() => _isBooked = value),
                activeColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _canAddActivity() ? _addActivity : null,
              icon: const Icon(Icons.add),
              label: Text(l10n.addActivity),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required Color color,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: (value) {
              setState(() {
                // 触发重新构建以更新按钮状态
              });
            },
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  bool _canSave() {
    return _titleController.text.trim().isNotEmpty;
  }

  bool _canAddActivity() {
    return _timeController.text.trim().isNotEmpty &&
        _activityController.text.trim().isNotEmpty &&
        _locationController.text.trim().isNotEmpty;
    // 成本字段是可选的，不需要检查
  }

  void _addActivity() {
    if (!_canAddActivity()) return;

    final activity = ItineraryActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dayId: widget.day?.id ?? '',
      time: _timeController.text.trim(),
      title: _activityController.text.trim(),
      location: _locationController.text.trim(),
      cost: _costController.text.trim().isNotEmpty
          ? double.tryParse(_costController.text.trim())
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      isBooked: _isBooked,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _activities.add(activity);
      _timeController.clear();
      _activityController.clear();
      _locationController.clear();
      _costController.clear();
      _notesController.clear();
      _isBooked = false;
    });
  }

  void _removeActivity(int index) {
    setState(() {
      _activities.removeAt(index);
    });
  }

  void _saveDay() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final day = ItineraryDay(
      id: widget.day?.id ?? now.millisecondsSinceEpoch.toString(),
      destinationId: widget.destination.id,
      title: _titleController.text.trim(),
      date: _selectedDate,
      dayNumber: _dayNumber,
      activities: _activities
          .map((activity) => activity.copyWith(
                dayId: widget.day?.id ?? now.millisecondsSinceEpoch.toString(),
              ))
          .toList(),
      createdAt: widget.day?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.day != null) {
      ref.read(itineraryProvider.notifier).updateDay(day);
    } else {
      ref.read(itineraryProvider.notifier).addDay(day);
    }

    Navigator.of(context).pop(true);
  }
}
