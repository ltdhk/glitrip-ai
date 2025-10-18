import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/destinations_provider.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';

class DestinationSearchBar extends ConsumerWidget {
  const DestinationSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(destinationSearchQueryProvider.notifier).state = value;
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: l10n.searchDestinations,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
          ),
          suffixIcon: Consumer(
            builder: (context, ref, child) {
              final query = ref.watch(destinationSearchQueryProvider);
              if (query.isEmpty) return const SizedBox.shrink();

              return IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: () {
                  ref.read(destinationSearchQueryProvider.notifier).state = '';
                },
              );
            },
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
