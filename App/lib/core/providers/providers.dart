import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_helper.dart';
import '../../features/destinations/data/datasources/destination_local_datasource.dart';
import '../../features/destinations/data/repositories/destination_repository_impl.dart';
import '../../features/destinations/domain/repositories/destination_repository.dart';
import '../../features/packing/data/datasources/packing_local_datasource.dart';
import '../../features/packing/data/repositories/packing_repository_impl.dart';
import '../../features/packing/domain/repositories/packing_repository.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

// 数据库提供器
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// 数据源提供器
final destinationLocalDataSourceProvider =
    Provider<DestinationLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return DestinationLocalDataSourceImpl(databaseHelper);
});

final packingLocalDataSourceProvider = Provider<PackingLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return PackingLocalDataSourceImpl(databaseHelper);
});

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return ProfileLocalDataSourceImpl(databaseHelper);
});

// 仓库提供器
final destinationRepositoryProvider = Provider<DestinationRepository>((ref) {
  final dataSource = ref.watch(destinationLocalDataSourceProvider);
  return DestinationRepositoryImpl(dataSource);
});

final packingRepositoryProvider = Provider<PackingRepository>((ref) {
  final dataSource = ref.watch(packingLocalDataSourceProvider);
  return PackingRepositoryImpl(dataSource);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.watch(profileLocalDataSourceProvider);
  return ProfileRepositoryImpl(dataSource);
});
