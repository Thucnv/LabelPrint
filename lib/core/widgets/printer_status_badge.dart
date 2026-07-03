import 'package:flutter/material.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../domain/entities/enums/printer_enums.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Badge hiển thị trạng thái máy in dưới dạng chip nhỏ.
///
/// Bao gồm:
/// - Chấm tròn màu tương ứng trạng thái
/// - Text mô tả trạng thái
///
/// Màu sắc theo semantic:
/// - ready → [AppColors.success]
/// - idle → [AppColors.statusIdle]
/// - error → [AppColors.error]
/// - notConfigured → [AppColors.warning]
///
/// Ví dụ:
/// ```dart
/// PrinterStatusBadge(status: PrinterStatus.ready)
/// ```
class PrinterStatusBadge extends StatelessWidget {
  /// Trạng thái máy in cần hiển thị.
  final PrinterStatus status;

  const PrinterStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chấm tròn trạng thái
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),

          // Text trạng thái
          Text(
            config.label,
            style: AppTextStyles.label.copyWith(
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  /// Lấy cấu hình màu và label theo trạng thái.
  _StatusConfig _getStatusConfig(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case PrinterStatus.ready:
        return _StatusConfig(
          color: AppColors.success,
          label: l10n.printerStatusReady,
        );
      case PrinterStatus.idle:
        return _StatusConfig(
          color: AppColors.statusIdle,
          label: l10n.printerStatusIdle,
        );
      case PrinterStatus.error:
        return _StatusConfig(
          color: AppColors.error,
          label: l10n.printerStatusError,
        );
      case PrinterStatus.notConfigured:
        return _StatusConfig(
          color: AppColors.warning,
          label: l10n.printerNotConfigured,
        );
    }
  }
}

/// Cấu hình nội bộ cho badge trạng thái.
class _StatusConfig {
  final Color color;
  final String label;

  const _StatusConfig({
    required this.color,
    required this.label,
  });
}
