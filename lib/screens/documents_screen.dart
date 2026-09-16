import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    final messenger = ScaffoldMessenger.of(context);
    final app = context.read<AppProvider>();
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.path == null) return;
    String stored;
    try {
      stored = await ImageHelper.storeFile(file.path!, file.name);
    } catch (_) {
      stored = file.path!;
    }
    _saveDoc(messenger, app, stored, file.name);
  }

  Future<void> _pickImage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final app = context.read<AppProvider>();
    final path = await ImageHelper.pickAndStore();
    if (path == null) return;
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
                              errorBuilder: (_, __, ___) => Container(
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
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('doc_no_preview'.tr()))),
                    trailing: IconButton(
                      icon: const Icon(AppIcons.trash, size: 20),
                      tooltip: 'common_delete'.tr(),
                      onPressed: () async {
                        if (await confirmDelete(context)) {
                          if (context.mounted && pet != null) {
                            app.deleteDoc(pet, doc);
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
        appBar: AppBar(backgroundColor: Colors.black87, foregroundColor: Colors.white),
        body: Center(
          child: InteractiveViewer(
            child: Image.file(
              File(doc.filePath),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                  AppIcons.triangleWarning,
                  size: 48,
                  color: Colors.white70),
            ),
          ),
        ),
      ),
    ));
  }

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.heic') ||
        lower.endsWith('.webp');
  }

  String _fmtDate(DateTime d) => DateFormat.yMd().format(d);
}