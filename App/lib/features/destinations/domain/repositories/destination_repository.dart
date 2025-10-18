import '../entities/destination.dart';

abstract class DestinationRepository {
  Future<List<Destination>> getAllDestinations();
  Future<List<Destination>> getDestinationsByStatus(DestinationStatus status);
  Future<List<Destination>> searchDestinations(String query);
  Future<Destination?> getDestinationById(String id);
  Future<String> createDestination(Destination destination);
  Future<void> updateDestination(Destination destination);
  Future<void> deleteDestination(String id);
  Future<Map<String, int>> getDestinationStatistics();
}
