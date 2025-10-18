import '../entities/document.dart';

abstract class DocumentRepository {
  Future<List<Document>> getAllDocuments();
  Future<List<Document>> getDocumentsByType(DocumentType type);
  Future<List<Document>> searchDocuments(String query);
  Future<Document?> getDocumentById(String id);
  Future<String> createDocument(Document document);
  Future<void> updateDocument(Document document);
  Future<void> deleteDocument(String id);
  Future<List<Document>> getExpiringDocuments();
}
