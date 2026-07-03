import 'package:flutter/material.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/printer_status_badge.dart';
import '../../../domain/entities/enums/printer_enums.dart';
import '../../../domain/entities/printer.dart';

/// Widget hiển thị trạng thái kết nối máy in mặc định ở màn hình chính.
class PrinterStatusWidget extends StatelessWidget {
  final Printer? defaultPrinter;
  final PrinterStatus status;
  final VoidCallback onManagePrinters;

  const PrinterStatusWidget({
    super.key,
    required this.defaultPrinter,
    required this.status,
    required this.onManagePrinters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (defaultPrinter == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.print_disabled_outlined,
              size: 48,
              color: AppColors.statusIdle,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.printerNotConfigured,
              style: AppTextStyles.headingSm.copyWith(
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: l10n.addPrinter,
              icon: Icons.add,
              onPressed: onManagePrinters,
              isFullWidth: false,
            ),
          ],
        ),
      );
    }

    final isWifi = defaultPrinter!.connectionMethod == ConnectionMethod.wifi;
    final connectionDetails = isWifi
        ? '${defaultPrinter!.wifiIp}:${defaultPrinter!.wifiPort}'
        : defaultPrinter!.btMacAddress ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  defaultPrinter!.name,
                  style: AppTextStyles.headingSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PrinterStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            defaultPrinter!.type == PrinterType.label
                ? l10n.labelPrinterTspl
                : l10n.receiptPrinterEscpos,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            children: [
              Icon(
                isWifi ? Icons.wifi : Icons.bluetooth,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isWifi ? l10n.wifi : l10n.bluetooth,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: AppColors.divider)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  connectionDetails,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onManagePrinters,
              icon: const Icon(Icons.settings_outlined, size: 16),
              label: Text(l10n.printerManagement),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
