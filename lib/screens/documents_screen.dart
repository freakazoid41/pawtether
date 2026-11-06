import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../storage/image_helper.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../widgets/common.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  Future<void> _pickFile(BuildContext context) async {
    final app = context.read<AppProvider>();
    PlatformFile file;
    try {
      final picked = await FilePicker.pickFile();
      if (picked == null) return;
      file = picked;
    } catch (e) {
      debugPrint('File pick failed: $e');
      return;
    }
    if (!context.mounted) return;
    if (file.path == null) return;
    final messenger = ScaffoldMessenger.of(context);
    String stored;
    try {
      stored = await ImageHelper.storeFile(file.path!, file.name);
    } catch (e) {
      debugPrint('File store failed: $e');
      return;
    }
    if (!context.mounted) return;
    _saveDoc(messenger, app, stored, file.name);
  }

  Future<void> _pickImage(BuildContext context) async {
    final app = context.read<AppProvider>();
    late final String? path;
    try {
      path = await ImageHelper.pickAndStore();
    } catch (e) {
      debugPrint('Image pick failed: $e');
      return;
    }
    if (path == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    _saveDoc(messenger, app, path, ImageHelper.baseName(path));
  }

  void _saveDoc(ScaffoldMessengerState messenger, AppProvider app,
      String path, String title) {
    var pet = app.currentPet;
    if (pet == null && app.pets.isNotEmpty) pet = app.pets.first;
    if (pet == null) {
      messenger.showSnackBar(SnackBar(content: Text('scn_need_pet'.tr())));
      return;
    }
    app.addDoc(pet, MedicalDocument(
      petId: pet.id,
      title: title,
      category: DocCategory.other,
      filePath: path,
    ));
    messenger.showSnackBar(
        SnackBar(content: Text('doc_saved'.tr(namedArgs: {'name': pet.name}))));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final docs = <MedicalDocument>[];
    for (final pet in app.pets) {
      docs.addAll(app.documents(pet));
    }
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text('doc_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.picture),
            tooltip: 'doc_add_photo'.tr(),
            onPressed: () => _pickImage(context),
          ),
          IconButton(
            icon: const Icon(AppIcons.fileUpload),
            tooltip: 'doc_add_file'.tr(),
            onPressed: () => _pickFile(context),
          ),
        ],
      ),
      body: docs.isEmpty
          ? EmptyState(
              emoji: '🗂️',
              title: 'empty_docs'.tr(),
              subtitle: 'empty_docs_sub'.tr(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final doc = docs[i];
                Pet? pet;
                for (final p in app.pets) {
                  if (p.id == doc.petId) pet = p;
                }
                final isImage = _isImage(doc.filePath);
                return Card(
                  child: ListTile(
                    leading: isImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(doc.filePath),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              cacheWidth: 96,
                              cacheHeight: 96,
                              errorBuilder: (_, _, _) => Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(AppIcons.document,
                                    color: AppColors.secondary),
                              ),
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(AppIcons.document,
                                color: AppColors.secondary),
                          ),
                    title: Text(doc.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${pet?.name ?? ''} · ${_fmtDate(doc.createdAt)}'),
                    onTap: isImage
                        ? () => _viewImage(context, doc)
                        : () => _openExternal(context, doc.filePath),
                    trailing: IconButton(
                      icon: const Icon(AppIcons.trash, size: 20),
                      tooltip: 'common_delete'.tr(),
                      onPressed: () async {
                        if (await confirmDelete(context)) {
                          if (!context.mounted) return;
                          if (pet != null) {
                            app.deleteDoc(pet, doc);
                          } else {
                            // Pet gone but the row survived — delete by raw
                            // petId instead of abandoning an undeletable row.
                            app.deleteOrphanDoc(doc);
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: docs.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _pickImage(context),
              icon: const Icon(AppIcons.camera),
              label: Text('doc_add_photo'.tr()),
            )
          : null,
    );
  }

  void _viewImage(BuildContext context, MedicalDocument doc) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'doc_open_with'.tr(),
              onPressed: () => _openExternal(context, doc.filePath),
            ),
          ],
        ),
        body: Center(
          child: InteractiveViewer(
            // Downscale decode to screen size: camera originals would
            // otherwise decode full-res (memory spike + jank on open).
            child: Image.file(
              File(doc.filePath),
              fit: BoxFit.contain,
              cacheWidth: (MediaQuery.of(context).size.width *
                      MediaQuery.of(context).devicePixelRatio)
                  .round(),
              errorBuilder: (_, _, _) => const Icon(
                  AppIcons.triangleWarning,
                  size: 48,
                  color: Colors.white70),
            ),
          ),
        ),
      ),
    ));
  }

  /// Open any vault file with the system's default app (PDF viewer,
  /// gallery, Drive…). No in-app PDF engine — the OS handles it, and the
  /// file stays safe in the vault either way.
  Future<void> _openExternal(BuildContext context, String path) async {
    // Async existence check — existsSync on the UI thread janks on slow
    // storage, and the file may legitimately be gone.
    if (!await File(path).exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('doc_open_failed'.tr())));
      }
      return;
    }
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('doc_open_failed'.tr())));
    }
  }

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    // HEIC/HEIF deliberately excluded: Flutter/Skia can't reliably decode
    // them on Android, so they open externally instead of showing the
    // warning icon in the in-app viewer.
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }

  String _fmtDate(DateTime d) => DateFormat.yMd().format(d);
}