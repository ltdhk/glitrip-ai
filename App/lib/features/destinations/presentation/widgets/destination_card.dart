import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/destination.dart';
import '../pages/destination_detail_page.dart';

class DestinationCard extends ConsumerWidget {
  final Destination destination;

  const DestinationCard({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  DestinationDetailPage(destination: destination),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _getStatusGradient(destination.status),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                destination.country,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusIcon(destination.status, context),
                  ],
                ),
                if (destination.description != null &&
                    destination.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    destination.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.calendar_today,
                      label: _getDateRangeText(destination.startDate, destination.endDate),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.attach_money,
                      label: _getBudgetLevelText(destination.budgetLevel),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: '${destination.recommendedDays}d',
                    ),
                  ],
                ),
                if (destination.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildTagsRow(destination.tags),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getStatusGradient(DestinationStatus status) {
    switch (status) {
      case DestinationStatus.visited:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationStatus.planned:
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationStatus.wishlist:
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Widget _buildStatusIcon(DestinationStatus status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    IconData icon;
    String text;
    switch (status) {
      case DestinationStatus.visited:
        icon = Icons.check_circle;
        text = l10n.visited;
        break;
      case DestinationStatus.planned:
        icon = Icons.schedule;
        text = l10n.planned;
        break;
      case DestinationStatus.wishlist:
        icon = Icons.star;
        text = l10n.wishlist;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeText(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Not set';
    }

    // 格式化为 "MM/DD-MM/DD" 或 "MM/DD" (如果同一天)
    final startMonth = startDate.month.toString().padLeft(2, '0');
    final startDay = startDate.day.toString().padLeft(2, '0');
    final endMonth = endDate.month.toString().padLeft(2, '0');
    final endDay = endDate.day.toString().padLeft(2, '0');

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return '$startMonth/$startDay';
    }

    return '$startMonth/$startDay-$endMonth/$endDay';
  }

  String _getBudgetLevelText(BudgetLevel level) {
    switch (level) {
      case BudgetLevel.low:
        return '\$';
      case BudgetLevel.medium:
        return '\$\$';
      case BudgetLevel.high:
        return '\$\$\$';
    }
  }

  Widget _buildTagsRow(List<String> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.take(4).map((tag) => _buildTagChip(tag)).toList(),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
