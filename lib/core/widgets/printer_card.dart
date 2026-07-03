import 'package:flutter/material.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../domain/entities/enums/printer_enums.dart';
import '../../domain/entities/printer.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'printer_status_badge.dart';

/// Card hiển thị thông tin máy in trong danh sách máy in đã lưu.
///
/// Hiển thị:
/// - Tên máy in
/// - Loại máy in và giao thức (TSPL/ESC-POS)
/// - Trạng thái hoạt động (Ready, Idle, Error...)
/// - Địa chỉ kết nối (IP:Port cho WiFi, MAC cho Bluetooth)
/// - Badge "Mặc định" và icon tick nếu là mặc định
/// - Các nút thao tác nhanh: In thử, Chỉnh sửa, Xóa
class PrinterCard extends StatelessWidget {
  /// Thông tin máy in cần hiển thị.
  final Printer printer;

  /// Trạng thái hoạt động hiện tại (Runtime status).
  final PrinterStatus status;

  /// Callback khi nhấn nút "In thử".
  final VoidCallback? onTestPrint;

  /// Callback khi nhấn nút "Sửa".
  final VoidCallback? onEdit;

  /// Callback khi nhấn nút "Xóa".
  final VoidCallback? onDelete;

  /// Callback khi nhấn chọn máy in làm mặc định.
  final VoidCallback? onSetDefault;

  const PrinterCard({
    super.key,
    required this.printer,
    required this.status,
    this.onTestPrint,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Xác định thông tin kết nối
    final String connectionInfo;
    final IconData connectionIcon;
    if (printer.connectionMethod == ConnectionMethod.wifi) {
      connectionInfo = '${printer.wifiIp}:${printer.wifiPort}';
      connectionIcon = Icons.wifi;
    } else {
      connectionInfo = printer.btMacAddress ?? 'N/A';
      connectionIcon = Icons.bluetooth;
    }

    // Xác định tên hiển thị giao thức và loại máy in
    final String typeInfo = printer.type == PrinterType.label
        ? l10n.labelPrinterTspl
        : l10n.receiptPrinterEscpos;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: printer.isDefault ? AppColors.primary : AppColors.divider,
          width: printer.isDefault ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: printer.isDefault ? null : onSetDefault,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hàng tiêu đề: Tên máy in + Badge mặc định / Tick icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                printer.name,
                                style: AppTextStyles.headingSm.copyWith(
                                  color: AppColors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (printer.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.setDefault.replaceFirst(
                                    l10n.setDefault[0],
                                    l10n.setDefault[0].toUpperCase(),
                                  ), // Mock "Default"
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          typeInfo,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PrinterStatusBadge(status: status),
                ],
              ),
              const Divider(height: 24, color: AppColors.divider),

              // Hàng thông tin kết nối
              Row(
                children: [
                  Icon(
                    connectionIcon,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    printer.connectionMethod == ConnectionMethod.wifi
                        ? l10n.wifi
                        : l10n.bluetooth,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      connectionInfo,
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

              // Hàng các nút thao tác
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Nút In thử
                  TextButton.icon(
                    onPressed: onTestPrint,
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: Text(l10n.testConnection),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Nút Sửa
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: l10n.edit,
                    color: AppColors.onSurfaceVariant,
                  ),
                  // Nút Xóa
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: l10n.delete,
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
