import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FeatureGrid extends StatelessWidget {
  final VoidCallback onBarcodeTap;

  const FeatureGrid({
    super.key,
    required this.onBarcodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Danh sách các chức năng in ấn
    final List<_FeatureItem> features = [
      _FeatureItem(
        icon: Icons.barcode_reader,
        label: l10n.featureBarcode,
        color: AppColors.primary,
        onTap: onBarcodeTap,
      ),
      _FeatureItem(
        icon: Icons.qr_code_scanner_outlined,
        label: l10n.featureQr,
        color: Colors.teal,
        onTap: () => _showNotImplemented(context, l10n.featureQr),
      ),
      _FeatureItem(
        icon: Icons.label_important_outline,
        label: l10n.featureLabel,
        color: Colors.orange,
        onTap: () => _showNotImplemented(context, l10n.featureLabel),
      ),
      _FeatureItem(
        icon: Icons.local_shipping_outlined,
        label: l10n.featureShipping,
        color: Colors.blue,
        onTap: () => _showNotImplemented(context, l10n.featureShipping),
      ),
      _FeatureItem(
        icon: Icons.receipt_long_outlined,
        label: l10n.featureReceipt,
        color: Colors.purple,
        onTap: () => _showNotImplemented(context, l10n.featureReceipt),
      ),
      _FeatureItem(
        icon: Icons.picture_as_pdf_outlined,
        label: l10n.featurePdf,
        color: Colors.red,
        onTap: () => _pickPdf(context),
      ),
      _FeatureItem(
        icon: Icons.image_outlined,
        label: l10n.featureImage,
        color: Colors.green,
        onTap: () => _pickImage(context),
      ),
      _FeatureItem(
        icon: Icons.assignment_outlined,
        label: l10n.featureDelivery,
        color: Colors.blueGrey,
        onTap: () => context.push('/delivery-note-print'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final item = features[index];
        return _FeatureCard(item: item);
      },
    );
  }

  void _showNotImplemented(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tính năng "$featureName" đang được phát triển'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && context.mounted) {
        context.push(
          '/print-preview',
          extra: {
            'documentType': 'image',
            'imagePath': image.path,
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickPdf(BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null && context.mounted) {
        context.push(
          '/print-preview',
          extra: {
            'documentType': 'pdf',
            'pdfPath': result.files.single.path!,
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn file PDF: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureItem item;

  const _FeatureCard({required this.item});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.item.onTap,
      borderRadius: BorderRadius.circular(16),
      onHighlightChanged: (highlight) {
        setState(() {
          _isHovered = highlight;
        });
      },
      child: AnimatedScale(
        scale: _isHovered ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.item.icon,
                    color: widget.item.color,
                    size: 24,
                  ),
                ),
                // Text Label
                Text(
                  widget.item.label,
                  style: AppTextStyles.headingSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
