import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/travel_buddy.dart';
import '../providers/travel_buddy_provider.dart';

class AddTravelBuddyPage extends ConsumerStatefulWidget {
  final TravelBuddy? existingBuddy;

  const AddTravelBuddyPage({super.key, this.existingBuddy});

  @override
  ConsumerState<AddTravelBuddyPage> createState() => _AddTravelBuddyPageState();
}

class _AddTravelBuddyPageState extends ConsumerState<AddTravelBuddyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _dreamDestinationsController = TextEditingController();

  BudgetLevel _selectedBudgetLevel = BudgetLevel.medium;
  bool _isConfirmedToTravel = false;
  List<TravelPreference> _selectedPreferences = [];
  List<String> _dreamDestinations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingBuddy != null) {
      _initializeWithExistingBuddy();
    }
  }

  void _initializeWithExistingBuddy() {
    final buddy = widget.existingBuddy!;
    _nameController.text = buddy.name;
    _emailController.text = buddy.email;
    _phoneController.text = buddy.phone;
    _availabilityController.text = buddy.availability ?? '';
    _selectedBudgetLevel = buddy.budgetLevel;
    _isConfirmedToTravel = buddy.isConfirmedToTravel;
    _selectedPreferences = List.from(buddy.travelPreferences);
    _dreamDestinations = List.from(buddy.dreamDestinations);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _availabilityController.dispose();
    _dreamDestinationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.existingBuddy != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editTravelBuddy : l10n.addTravelBuddy),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTravelBuddy,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBasicInformationSection(l10n),
                  const SizedBox(height: 24),
                  _buildTravelDetailsSection(l10n),
                  const SizedBox(height: 24),
                  _buildTravelPreferencesSection(l10n),
                  const SizedBox(height: 24),
                  _buildDreamDestinationsSection(l10n),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildBasicInformationSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.basicInformation,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: l10n.name,
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseEnterName;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: l10n.email,
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseEnterEmail;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: l10n.phone,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseEnterPhone;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTravelDetailsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.travelDetails,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _availabilityController,
          label: l10n.availability,
          icon: Icons.calendar_today,
          hintText: l10n.availability,
        ),
        const SizedBox(height: 16),
        _buildBudgetLevelSelector(l10n),
        const SizedBox(height: 16),
        _buildConfirmationSwitch(l10n),
      ],
    );
  }

  Widget _buildTravelPreferencesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.travelPreferences,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ...TravelPreference.values.map((preference) {
          return _buildPreferenceItem(preference, l10n);
        }).toList(),
      ],
    );
  }

  Widget _buildDreamDestinationsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dreamDestinations,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dreamDestinationsController,
          decoration: InputDecoration(
            labelText: l10n.addDestinationAndPressReturn,
            prefixIcon:
                const Icon(Icons.flight_takeoff, color: Color(0xFF9C27B0)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: _addDreamDestination,
        ),
        const SizedBox(height: 12),
        if (_dreamDestinations.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dreamDestinations.map((destination) {
              return Chip(
                label: Text(destination),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeDreamDestination(destination),
                backgroundColor: const Color(0xFF9C27B0).withOpacity(0.1),
                labelStyle: const TextStyle(color: Color(0xFF9C27B0)),
                deleteIconColor: const Color(0xFF9C27B0),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF00BCD4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildBudgetLevelSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.budgetLevel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attach_money,
                      color: Color(0xFF00BCD4), size: 16),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF00BCD4), size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: BudgetLevel.values.map((level) {
            return Expanded(
              child: RadioListTile<BudgetLevel>(
                title: Text(_getBudgetLevelLabel(level, l10n)),
                value: level,
                groupValue: _selectedBudgetLevel,
                onChanged: (BudgetLevel? value) {
                  setState(() {
                    _selectedBudgetLevel = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmationSwitch(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.confirmedToTravel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: _isConfirmedToTravel,
          onChanged: (value) {
            setState(() {
              _isConfirmedToTravel = value;
            });
          },
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildPreferenceItem(
      TravelPreference preference, AppLocalizations l10n) {
    final isSelected = _selectedPreferences.contains(preference);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _togglePreference(preference),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF00BCD4) : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00BCD4)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  color:
                      isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Icon(
                _getPreferenceIcon(preference),
                color:
                    isSelected ? const Color(0xFF00BCD4) : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Text(
                _getPreferenceLabel(preference, l10n),
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected
                      ? const Color(0xFF00BCD4)
                      : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPreferenceIcon(TravelPreference preference) {
    switch (preference) {
      case TravelPreference.adventure:
        return Icons.hiking;
      case TravelPreference.relaxation:
        return Icons.beach_access;
      case TravelPreference.culture:
        return Icons.account_balance;
      case TravelPreference.foodie:
        return Icons.restaurant;
      case TravelPreference.nature:
        return Icons.nature_people;
      case TravelPreference.urban:
        return Icons.location_city;
    }
  }

  String _getPreferenceLabel(
      TravelPreference preference, AppLocalizations l10n) {
    switch (preference) {
      case TravelPreference.adventure:
        return l10n.adventure;
      case TravelPreference.relaxation:
        return l10n.relaxation;
      case TravelPreference.culture:
        return l10n.culture;
      case TravelPreference.foodie:
        return l10n.foodie;
      case TravelPreference.nature:
        return l10n.nature;
      case TravelPreference.urban:
        return l10n.urban;
    }
  }

  String _getBudgetLevelLabel(BudgetLevel level, AppLocalizations l10n) {
    switch (level) {
      case BudgetLevel.low:
        return l10n.low;
      case BudgetLevel.medium:
        return l10n.medium;
      case BudgetLevel.high:
        return l10n.high;
    }
  }

  void _togglePreference(TravelPreference preference) {
    setState(() {
      if (_selectedPreferences.contains(preference)) {
        _selectedPreferences.remove(preference);
      } else {
        _selectedPreferences.add(preference);
      }
    });
  }

  void _addDreamDestination(String destination) {
    if (destination.trim().isNotEmpty &&
        !_dreamDestinations.contains(destination.trim())) {
      setState(() {
        _dreamDestinations.add(destination.trim());
        _dreamDestinationsController.clear();
      });
    }
  }

  void _removeDreamDestination(String destination) {
    setState(() {
      _dreamDestinations.remove(destination);
    });
  }

  Future<void> _saveTravelBuddy() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final buddy = TravelBuddy(
        id: widget.existingBuddy?.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        availability: _availabilityController.text.trim().isEmpty
            ? null
            : _availabilityController.text.trim(),
        budgetLevel: _selectedBudgetLevel,
        isConfirmedToTravel: _isConfirmedToTravel,
        travelPreferences: _selectedPreferences,
        dreamDestinations: _dreamDestinations,
        createdAt: widget.existingBuddy?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.existingBuddy != null) {
        await ref.read(travelBuddiesProvider.notifier).updateTravelBuddy(buddy);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context).travelBuddyUpdatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await ref.read(travelBuddiesProvider.notifier).addTravelBuddy(buddy);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context).travelBuddyAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)
                  .errorSavingTravelBuddy(error.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
