import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/entities/user_profile.dart';

// 用户资料状态
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UserProfileNotifier(repository);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final profileRepository;

  UserProfileNotifier(this.profileRepository)
      : super(const AsyncValue.loading()) {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      state = const AsyncValue.loading();
      final profile = await profileRepository.getUserProfile();
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await profileRepository.updateUserProfile(profile);
      await loadUserProfile();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
