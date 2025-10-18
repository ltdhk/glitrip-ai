import 'package:flutter/material.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/travel_buddy.dart';

class TravelBuddyCard extends StatelessWidget {
  final TravelBuddy buddy;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TravelBuddyCard({
    super.key,
    required this.buddy,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00BCD4).withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF00BCD4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buddy.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (buddy.email.isNotEmpty)
                          Text(
                            buddy.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (buddy.isConfirmedToTravel)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.confirmedToTravel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              l10n.delete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit' && onTap != null) {
                        onTap!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 联系信息
              if (buddy.phone.isNotEmpty)
                _buildInfoRow(
                  Icons.phone,
                  buddy.phone,
                  Colors.green,
                ),

              if (buddy.availability != null && buddy.availability!.isNotEmpty)
                _buildInfoRow(
                  Icons.calendar_today,
                  buddy.availability!,
                  Colors.orange,
                ),

              // 预算级别
              _buildInfoRow(
                Icons.attach_money,
                _getBudgetLevelText(buddy.budgetLevel, l10n),
                const Color(0xFF00BCD4),
              ),

              // 旅行偏好
              if (buddy.travelPreferences.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.travelPreferences,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: buddy.travelPreferences.map((preference) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPreferenceColor(preference).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPreferenceIcon(preference),
                            size: 14,
                            color: _getPreferenceColor(preference),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPreferenceLabel(preference, l10n),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPreferenceColor(preference),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              // 梦想目的地
              if (buddy.dreamDestinations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.dreamDestinations,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: buddy.dreamDestinations.take(3).map((destination) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9C27B0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (buddy.dreamDestinations.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${buddy.dreamDestinations.length - 3} more',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBudgetLevelText(BudgetLevel level, AppLocalizations l10n) {
    switch (level) {
      case BudgetLevel.low:
        return l10n.low;
      case BudgetLevel.medium:
        return l10n.medium;
      case BudgetLevel.high:
        return l10n.high;
    }
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

  Color _getPreferenceColor(TravelPreference preference) {
    switch (preference) {
      case TravelPreference.adventure:
        return Colors.orange;
      case TravelPreference.relaxation:
        return Colors.blue;
      case TravelPreference.culture:
        return Colors.purple;
      case TravelPreference.foodie:
        return Colors.red;
      case TravelPreference.nature:
        return Colors.green;
      case TravelPreference.urban:
        return Colors.grey;
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
}
