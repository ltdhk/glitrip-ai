import '../../../../core/database/database_helper.dart';
import '../models/document_model.dart';

abstract class DocumentLocalDataSource {
  Future<List<DocumentModel>> getAllDocuments();
  Future<List<DocumentModel>> getDocumentsByType(String type);
  Future<List<DocumentModel>> searchDocuments(String query);
  Future<DocumentModel?> getDocumentById(String id);
  Future<String> insertDocument(DocumentModel document);
  Future<int> updateDocument(DocumentModel document);
  Future<int> deleteDocument(String id);
  Future<List<DocumentModel>> getExpiringDocuments();
  Future<void> insertDocumentImages(String documentId, List<String> imagePaths);
  Future<void> deleteDocumentImages(String documentId);
  Future<List<String>> getDocumentImages(String documentId);
}

class DocumentLocalDataSourceImpl implements DocumentLocalDataSource {
  final DatabaseHelper _databaseHelper;

  DocumentLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<DocumentModel>> getAllDocuments() async {
    final maps = await _databaseHelper.query(
      'documents',
      orderBy: 'updated_at DESC',
    );

    final documents = <DocumentModel>[];
    for (final map in maps) {
      final imagePaths = await getDocumentImages(map['id'] as String);
      documents.add(DocumentModel.fromMap(map, imagePaths: imagePaths));
    }
    return documents;
  }

  @override
  Future<List<DocumentModel>> getDocumentsByType(String type) async {
    final maps = await _databaseHelper.query(
      'documents',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'updated_at DESC',
    );

    final documents = <DocumentModel>[];
    for (final map in maps) {
      final imagePaths = await getDocumentImages(map['id'] as String);
      documents.add(DocumentModel.fromMap(map, imagePaths: imagePaths));
    }
    return documents;
  }

  @override
  Future<List<DocumentModel>> searchDocuments(String query) async {
    final maps = await _databaseHelper.query(
      'documents',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );

    final documents = <DocumentModel>[];
    for (final map in maps) {
      final imagePaths = await getDocumentImages(map['id'] as String);
      documents.add(DocumentModel.fromMap(map, imagePaths: imagePaths));
    }
    return documents;
  }

  @override
  Future<DocumentModel?> getDocumentById(String id) async {
    final maps = await _databaseHelper.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    final imagePaths = await getDocumentImages(id);
    return DocumentModel.fromMap(maps.first, imagePaths: imagePaths);
  }

  @override
  Future<String> insertDocument(DocumentModel document) async {
    await _databaseHelper.insert('documents', document.toMap());
    if (document.imagePaths.isNotEmpty) {
      await insertDocumentImages(document.id, document.imagePaths);
    }
    return document.id;
  }

  @override
  Future<int> updateDocument(DocumentModel document) async {
    final result = await _databaseHelper.update(
      'documents',
      document.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );

    // 更新图片：先删除旧的，再插入新的
    await deleteDocumentImages(document.id);
    if (document.imagePaths.isNotEmpty) {
      await insertDocumentImages(document.id, document.imagePaths);
    }

    return result;
  }

  @override
  Future<int> deleteDocument(String id) async {
    return await _databaseHelper.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<DocumentModel>> getExpiringDocuments() async {
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    final maps = await _databaseHelper.query(
      'documents',
      where: 'has_expiry = 1 AND expiry_date <= ?',
      whereArgs: [thirtyDaysFromNow.toIso8601String()],
      orderBy: 'expiry_date ASC',
    );
    final documents = <DocumentModel>[];
    for (final map in maps) {
      final imagePaths = await getDocumentImages(map['id'] as String);
      documents.add(DocumentModel.fromMap(map, imagePaths: imagePaths));
    }
    return documents;
  }

  @override
  Future<void> insertDocumentImages(
      String documentId, List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await _databaseHelper.insert('document_images', {
        'id': DateTime.now().millisecondsSinceEpoch.toString() +
            imagePath.hashCode.toString(),
        'document_id': documentId,
        'image_path': imagePath,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  Future<void> deleteDocumentImages(String documentId) async {
    await _databaseHelper.delete(
      'document_images',
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
  }

  @override
  Future<List<String>> getDocumentImages(String documentId) async {
    final maps = await _databaseHelper.query(
      'document_images',
      where: 'document_id = ?',
      whereArgs: [documentId],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => map['image_path'] as String).toList();
  }
}
