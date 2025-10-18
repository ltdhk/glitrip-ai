import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _localDataSource;

  ProfileRepositoryImpl(this._localDataSource);

  @override
  Future<UserProfile?> getUserProfile() async {
    final model = await _localDataSource.getUserProfile();
    return model;
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    final model = UserProfileModel.fromEntity(profile);
    await _localDataSource.updateUserProfile(model);
  }
}
