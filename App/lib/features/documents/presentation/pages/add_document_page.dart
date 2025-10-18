import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/document.dart';
import '../providers/documents_provider.dart';

class AddDocumentPage extends ConsumerStatefulWidget {
  final Document? document;

  const AddDocumentPage({super.key, this.document});

  @override
  ConsumerState<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends ConsumerState<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DocumentType _selectedType = DocumentType.other;
  bool _hasExpiry = false;
  DateTime? _expiryDate;
  List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.document != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    final doc = widget.document!;
    _nameController.text = doc.name;
    _descriptionController.text = doc.description ?? '';
    _selectedType = doc.type;
    _hasExpiry = doc.hasExpiry;
    _expiryDate = doc.expiryDate;
    _imagePaths = List.from(doc.imagePaths);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editDocument : l10n.addDocument),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveDocument,
            child: Text(
              l10n.save,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.documentInformation,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.pleaseEnterDocumentName;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: l10n.documentName,
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00BCD4)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDocumentTypeSelector(l10n),
              const SizedBox(height: 16),
              _buildExpiryToggle(l10n),
              if (_hasExpiry) ...[
                const SizedBox(height: 16),
                _buildExpiryDateSelector(l10n),
              ],
              const SizedBox(height: 24),
              Text(
                l10n.images,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildImageSection(l10n),
              const SizedBox(height: 24),
              Text(
                l10n.notes,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.addNotesAboutDocument,
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00BCD4)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTypeSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.documentType,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DocumentType>(
              value: _selectedType,
              isExpanded: true,
              onChanged: (DocumentType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedType = newValue;
                  });
                }
              },
              items: DocumentType.values
                  .map<DropdownMenuItem<DocumentType>>((DocumentType type) {
                return DropdownMenuItem<DocumentType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getTypeIcon(type), color: const Color(0xFF00BCD4)),
                      const SizedBox(width: 12),
                      Text(_getTypeDisplayName(type, l10n)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryToggle(AppLocalizations l10n) {
    return Row(
      children: [
        Text(
          l10n.hasExpiryDate,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Switch(
          value: _hasExpiry,
          onChanged: (value) {
            setState(() {
              _hasExpiry = value;
              if (!value) {
                _expiryDate = null;
              }
            });
          },
          activeColor: const Color(0xFF00BCD4),
        ),
      ],
    );
  }

  Widget _buildExpiryDateSelector(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate:
              _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        );
        if (pickedDate != null) {
          setState(() {
            _expiryDate = pickedDate;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.expiryDate,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _expiryDate != null
                  ? '${_expiryDate!.month}/${_expiryDate!.day}/${_expiryDate!.year}'
                  : l10n.selectExpiryDate,
              style: TextStyle(
                fontSize: 16,
                color: _expiryDate != null ? Colors.black87 : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.passport:
        return Icons.credit_card;
      case DocumentType.idCard:
        return Icons.badge;
      case DocumentType.visa:
        return Icons.description;
      case DocumentType.insurance:
        return Icons.security;
      case DocumentType.ticket:
        return Icons.flight;
      case DocumentType.hotel:
        return Icons.hotel;
      case DocumentType.carRental:
        return Icons.directions_car;
      case DocumentType.other:
        return Icons.description;
    }
  }

  String _getTypeDisplayName(DocumentType type, AppLocalizations l10n) {
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
        return l10n.hotelBooking;
      case DocumentType.carRental:
        return l10n.carRental;
      case DocumentType.other:
        return l10n.other;
    }
  }

  void _saveDocument() async {
    final l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hasExpiry && _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectExpiryDate),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final document = _isEditing
        ? widget.document!.copyWith(
            name: _nameController.text.trim(),
            type: _selectedType,
            hasExpiry: _hasExpiry,
            expiryDate: _expiryDate,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            imagePaths: _imagePaths,
          )
        : Document.create(
            name: _nameController.text.trim(),
            type: _selectedType,
            hasExpiry: _hasExpiry,
            expiryDate: _expiryDate,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            imagePaths: _imagePaths,
          );

    try {
      if (_isEditing) {
        await ref.read(documentsProvider.notifier).updateDocument(document);
      } else {
        await ref.read(documentsProvider.notifier).addDocument(document);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSavingDocument(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImageSection(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text(l10n.takePhoto),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text(l10n.choosePhoto),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (_imagePaths.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildImageGrid(),
        ],
      ],
    );
  }

  Widget _buildImageGrid() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imagePaths.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imagePaths[index]),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final String savedPath = await _saveImageToLocal(image.path);
        setState(() {
          _imagePaths.add(savedPath);
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorPickingImage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _saveImageToLocal(String imagePath) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String documentsPath = path.join(appDocDir.path, 'documents');
    final Directory documentsDir = Directory(documentsPath);

    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }

    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagePath)}';
    final String newPath = path.join(documentsPath, fileName);

    final File sourceFile = File(imagePath);
    await sourceFile.copy(newPath);

    return newPath;
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }
}
