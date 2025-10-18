import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/entities/document.dart';

// 所有文档状态
final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, AsyncValue<List<Document>>>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentsNotifier(repository);
});

// 按类型筛选的文档
final documentsByTypeProvider = StateNotifierProvider.family<
    DocumentsByTypeNotifier,
    AsyncValue<List<Document>>,
    DocumentType>((ref, type) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentsByTypeNotifier(repository, type);
});

// 搜索文档
final searchDocumentsProvider = StateNotifierProvider.family<
    SearchDocumentsNotifier, AsyncValue<List<Document>>, String>((ref, query) {
  final repository = ref.watch(documentRepositoryProvider);
  return SearchDocumentsNotifier(repository, query);
});

// 即将过期的文档
final expiringDocumentsProvider = FutureProvider<List<Document>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  // 监听文档列表变化，当文档发生变化时自动刷新
  ref.watch(documentsProvider);
  return await repository.getExpiringDocuments();
});

// 选中的文档类型筛选器
final selectedDocumentTypeProvider =
    StateProvider<DocumentType?>((ref) => null);

// 搜索查询
final documentSearchQueryProvider = StateProvider<String>((ref) => '');

// 文档统计
final documentStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  // 监听文档列表变化，当文档发生变化时自动刷新统计
  ref.watch(documentsProvider);
  final documents = await repository.getAllDocuments();

  final stats = <String, int>{
    'total': documents.length,
    'passport': documents.where((d) => d.type == DocumentType.passport).length,
    'idCard': documents.where((d) => d.type == DocumentType.idCard).length,
    'visa': documents.where((d) => d.type == DocumentType.visa).length,
    'insurance':
        documents.where((d) => d.type == DocumentType.insurance).length,
    'ticket': documents.where((d) => d.type == DocumentType.ticket).length,
    'hotel': documents.where((d) => d.type == DocumentType.hotel).length,
    'carRental':
        documents.where((d) => d.type == DocumentType.carRental).length,
    'other': documents.where((d) => d.type == DocumentType.other).length,
  };

  return stats;
});

class DocumentsNotifier extends StateNotifier<AsyncValue<List<Document>>> {
  final documentRepository;

  DocumentsNotifier(this.documentRepository)
      : super(const AsyncValue.loading()) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    try {
      state = const AsyncValue.loading();
      final documents = await documentRepository.getAllDocuments();
      state = AsyncValue.data(documents);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addDocument(Document document) async {
    try {
      await documentRepository.createDocument(document);
      await loadDocuments();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateDocument(Document document) async {
    try {
      await documentRepository.updateDocument(document);
      await loadDocuments();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await documentRepository.deleteDocument(id);
      await loadDocuments();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class DocumentsByTypeNotifier
    extends StateNotifier<AsyncValue<List<Document>>> {
  final documentRepository;
  final DocumentType type;

  DocumentsByTypeNotifier(this.documentRepository, this.type)
      : super(const AsyncValue.loading()) {
    loadDocumentsByType();
  }

  Future<void> loadDocumentsByType() async {
    try {
      state = const AsyncValue.loading();
      final documents = await documentRepository.getDocumentsByType(type);
      state = AsyncValue.data(documents);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class SearchDocumentsNotifier
    extends StateNotifier<AsyncValue<List<Document>>> {
  final documentRepository;
  final String query;

  SearchDocumentsNotifier(this.documentRepository, this.query)
      : super(const AsyncValue.loading()) {
    if (query.isNotEmpty) {
      searchDocuments();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> searchDocuments() async {
    try {
      state = const AsyncValue.loading();
      final documents = await documentRepository.searchDocuments(query);
      state = AsyncValue.data(documents);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
