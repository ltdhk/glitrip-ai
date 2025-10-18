import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../domain/entities/document.dart';
import '../providers/documents_provider.dart';
import '../widgets/document_card.dart';
import 'add_document_page.dart';
import '../../../../ad_helper.dart';

class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key});

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _loadNativeAd();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'listTile', // 需要在原生端实现
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _nativeAd = null;
          setState(() {
            _isNativeAdLoaded = false;
          });
        },
      ),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final searchQuery = ref.watch(documentSearchQueryProvider);
    final statsAsync = ref.watch(documentStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.documents,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            statsAsync.when(
              data: (stats) => Text(
                l10n.documentsTotal(stats['total'] ?? 0),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 24),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddDocumentPage(),
                  ),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildSearchBar(),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: l10n.all),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.credit_card, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.passport),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.badge, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.idCard),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.description, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.visa),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.security, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.insurance),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.airplane_ticket, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.ticket),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hotel, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.hotel),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.car_rental, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.carRental),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder, size: 16),
                        const SizedBox(width: 4),
                        Text(l10n.other),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllDocuments(searchQuery),
          _buildDocumentsByType(DocumentType.passport, searchQuery),
          _buildDocumentsByType(DocumentType.idCard, searchQuery),
          _buildDocumentsByType(DocumentType.visa, searchQuery),
          _buildDocumentsByType(DocumentType.insurance, searchQuery),
          _buildDocumentsByType(DocumentType.ticket, searchQuery),
          _buildDocumentsByType(DocumentType.hotel, searchQuery),
          _buildDocumentsByType(DocumentType.carRental, searchQuery),
          _buildDocumentsByType(DocumentType.other, searchQuery),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(documentSearchQueryProvider.notifier).state = value;
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: l10n.searchDocuments,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAllDocuments(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      return _buildSearchResults(searchQuery);
    }

    return Consumer(
      builder: (context, ref, child) {
        final documentsAsync = ref.watch(documentsProvider);

        return documentsAsync.when(
          data: (documents) {
            if (documents.isEmpty) {
              return _buildEmptyState();
            }
            return _buildDocumentsList(documents);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            final l10n = AppLocalizations.of(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(documentsProvider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDocumentsByType(DocumentType type, String searchQuery) {
    if (searchQuery.isNotEmpty) {
      return _buildSearchResults(searchQuery);
    }

    return Consumer(
      builder: (context, ref, child) {
        final documentsAsync = ref.watch(documentsByTypeProvider(type));

        return documentsAsync.when(
          data: (documents) {
            if (documents.isEmpty) {
              return _buildEmptyStateForType(type);
            }
            return _buildDocumentsList(documents);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(String query) {
    return Consumer(
      builder: (context, ref, child) {
        final searchResultsAsync = ref.watch(searchDocumentsProvider(query));

        return searchResultsAsync.when(
          data: (documents) {
            if (documents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('没有找到匹配 "$query" 的文档'),
                  ],
                ),
              );
            }
            return _buildDocumentsList(documents);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('搜索出错: $error'),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsList(List<Document> documents) {
    // 按类型分组显示
    final groupedDocs = <DocumentType, List<Document>>{};
    for (final doc in documents) {
      groupedDocs.putIfAbsent(doc.type, () => []).add(doc);
    }

    // 计算总的item数量：分组数 + 广告（如果加载成功且有足够的文档）
    final int groupCount = groupedDocs.length;
    final bool showAd =
        _isNativeAdLoaded && _nativeAd != null && groupCount > 1;
    final int adPosition = 1; // 在第二个分组后显示广告
    final int totalItems = showAd ? groupCount + 1 : groupCount;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // 如果是广告位置
        if (showAd && index == adPosition) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 175, // 调整高度以匹配150dp MediaView + padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AdWidget(ad: _nativeAd!),
            ),
          );
        }

        // 计算实际的文档分组索引
        final groupIndex = showAd && index > adPosition ? index - 1 : index;
        final type = groupedDocs.keys.elementAt(groupIndex);
        final docs = groupedDocs[type]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getTypeIcon(type),
                const SizedBox(width: 8),
                Text(
                  _getTypeTitle(type),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD4),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${docs.length}',
                    style: const TextStyle(
                      color: Color(0xFF00BCD4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...docs.map((doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DocumentCard(document: doc),
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description,
            size: 120,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noDocumentsYet,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.addDocumentsDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddDocumentPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.addFirstDocument),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateForType(DocumentType type) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getTypeIcon(type, size: 120),
          const SizedBox(height: 24),
          Text(
            l10n.noDocumentsOfType(_getTypeTitle(type, l10n)),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.addDocumentsToGetStarted,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTypeIcon(DocumentType type, {double size = 24}) {
    IconData icon;
    Color color = const Color(0xFF00BCD4);

    switch (type) {
      case DocumentType.passport:
        icon = Icons.credit_card;
        break;
      case DocumentType.visa:
        icon = Icons.description;
        break;
      case DocumentType.insurance:
        icon = Icons.security;
        break;
      case DocumentType.ticket:
        icon = Icons.flight;
        break;
      case DocumentType.hotel:
        icon = Icons.hotel;
        break;
      case DocumentType.carRental:
        icon = Icons.directions_car;
        break;
      default:
        icon = Icons.description;
    }

    return Icon(icon, size: size, color: color);
  }

  String _getTypeTitle(DocumentType type, [AppLocalizations? l10n]) {
    l10n ??= AppLocalizations.of(context);

    switch (type) {
      case DocumentType.passport:
        return l10n.passport;
      case DocumentType.idCard:
        return l10n.idCard;
      case DocumentType.visa:
        return l10n.visa;
      case DocumentType.insurance:
        return l10n.insurance;
      case DocumentType.ticket:
        return l10n.ticket;
      case DocumentType.hotel:
        return l10n.hotel;
      case DocumentType.carRental:
        return l10n.carRental;
      case DocumentType.other:
        return l10n.other;
    }
  }
}
