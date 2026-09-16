import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import 'quick_log.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [
      BarcodeFormat.qrCode,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
    ],
  );

  String? _lastCode;
  String? _coolCode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final value = barcode?.rawValue;
    if (value == null || value.isEmpty) return;
    // Cool down only the code just seen — a different product scans instantly.
    if (value == _coolCode) return;
    _coolCode = value;
    setState(() => _lastCode = value);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _coolCode == value) _coolCode = null;
    });
  }

  Future<void> _rememberName(String code) async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('scn_name_product'.tr()),
        content: TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'scn_product_name'.tr(),
            hintText: 'scn_product_hint'.tr(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common_cancel'.tr()),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, nameController.text.trim()),
            child: Text('common_save'.tr()),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && mounted) {
      context.read<AppProvider>().rememberQrCode(code, name);
      setState(() {});
    }
  }

  void _log(CareType type) {
    final app = context.read<AppProvider>();
    final pet = app.currentPet;
    if (pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('scn_need_pet'.tr())));
      return;
    }
    final name = app.qrNameFor(_lastCode!);
    // Pop first, but show the sheet on the navigator's own context —
    // this screen's context is deactivated by the pop.
    final nav = Navigator.of(context);
    nav.pop();
    QuickLogSheet.show(
      nav.context,
      pet,
      type,
      initialDetail: name,
      initialNote: _lastCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final knownName = _lastCode == null ? null : app.qrNameFor(_lastCode!);
    final handle = _lastCode;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // scan frame overlay
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(AppIcons.cross, color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _controller.switchCamera(),
                  icon: const Icon(AppIcons.camera, color: Colors.white),
                ),
                IconButton(
                  onPressed: () => _controller.toggleTorch(),
                  icon: const Icon(AppIcons.bolt, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 0,
            right: 0,
            child: Text(
              'scn_hint'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          // result panel
          Align(
            alignment: Alignment.bottomCenter,
            child: handle == null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: Text(
                      'scn_scanning'.tr(),
                      style: const TextStyle(color: Colors.white54),
                    ),
                  )
                : _ResultPanel(
                    code: handle,
                    name: knownName,
                    onRemember: () => _rememberName(handle),
                    onLogFood: () => _log(CareType.feeding),
                    onLogMeds: () => _log(CareType.medication),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final String code;
  final String? name;
  final VoidCallback onRemember;
  final VoidCallback onLogFood;
  final VoidCallback onLogMeds;

  const _ResultPanel({
    required this.code,
    required this.name,
    required this.onRemember,
    required this.onLogFood,
    required this.onLogMeds,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(AppIcons.qrcode, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name ?? 'scn_scanned'.tr(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
                if (name == null)
                  TextButton(
                    onPressed: onRemember,
                    child: Text('scn_remember'.tr()),
                  ),
              ],
            ),
            if (name == null)
              Text(
                code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onLogFood,
                    icon: const Icon(AppIcons.restaurant, size: 18),
                    label: Text('scn_log_feeding'.tr()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onLogMeds,
                    icon: const Icon(AppIcons.capsules, size: 18),
                    label: Text('scn_log_meds'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}