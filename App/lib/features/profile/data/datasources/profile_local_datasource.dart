import '../../../../core/database/database_helper.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getUserProfile();
  Future<int> updateUserProfile(UserProfileModel profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final DatabaseHelper _databaseHelper;

  ProfileLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<UserProfileModel?> getUserProfile() async {
    final maps = await _databaseHelper.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: ['default_user'],
    );
    if (maps.isEmpty) return null;
    return UserProfileModel.fromMap(maps.first);
  }

  @override
  Future<int> updateUserProfile(UserProfileModel profile) async {
    return await _databaseHelper.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }
}
