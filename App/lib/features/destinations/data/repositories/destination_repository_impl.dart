import '../../domain/entities/destination.dart';
import '../../domain/repositories/destination_repository.dart';
import '../datasources/destination_local_datasource.dart';
import '../models/destination_model.dart';

class DestinationRepositoryImpl implements DestinationRepository {
  final DestinationLocalDataSource _localDataSource;

  DestinationRepositoryImpl(this._localDataSource);

  @override
  Future<List<Destination>> getAllDestinations() async {
    final models = await _localDataSource.getAllDestinations();
    return models.cast<Destination>();
  }

  @override
  Future<List<Destination>> getDestinationsByStatus(
      DestinationStatus status) async {
    final models = await _localDataSource.getDestinationsByStatus(status.name);
    return models.cast<Destination>();
  }

  @override
  Future<List<Destination>> searchDestinations(String query) async {
    final models = await _localDataSource.searchDestinations(query);
    return models.cast<Destination>();
  }

  @override
  Future<Destination?> getDestinationById(String id) async {
    final model = await _localDataSource.getDestinationById(id);
    return model;
  }

  @override
  Future<String> createDestination(Destination destination) async {
    final model = DestinationModel.fromEntity(destination);
    return await _localDataSource.insertDestination(model);
  }

  @override
  Future<void> updateDestination(Destination destination) async {
    final model = DestinationModel.fromEntity(destination);
    await _localDataSource.updateDestination(model);
  }

  @override
  Future<void> deleteDestination(String id) async {
    await _localDataSource.deleteDestination(id);
  }

  @override
  Future<Map<String, int>> getDestinationStatistics() async {
    return await _localDataSource.getDestinationStatistics();
  }
}
