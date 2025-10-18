import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_local_datasource.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentLocalDataSource _localDataSource;

  DocumentRepositoryImpl(this._localDataSource);

  @override
  Future<List<Document>> getAllDocuments() async {
    final models = await _localDataSource.getAllDocuments();
    return models.cast<Document>();
  }

  @override
  Future<List<Document>> getDocumentsByType(DocumentType type) async {
    final models = await _localDataSource.getDocumentsByType(type.name);
    return models.cast<Document>();
  }

  @override
  Future<List<Document>> searchDocuments(String query) async {
    final models = await _localDataSource.searchDocuments(query);
    return models.cast<Document>();
  }

  @override
  Future<Document?> getDocumentById(String id) async {
    final model = await _localDataSource.getDocumentById(id);
    return model;
  }

  @override
  Future<String> createDocument(Document document) async {
    final model = DocumentModel.fromEntity(document);
    return await _localDataSource.insertDocument(model);
  }

  @override
  Future<void> updateDocument(Document document) async {
    final model = DocumentModel.fromEntity(document);
    await _localDataSource.updateDocument(model);
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _localDataSource.deleteDocument(id);
  }

  @override
  Future<List<Document>> getExpiringDocuments() async {
    final models = await _localDataSource.getExpiringDocuments();
    return models.cast<Document>();
  }
}
