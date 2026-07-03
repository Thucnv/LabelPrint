import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';

class ScanDevicesSheet extends StatelessWidget {
  final List<ScanResult> scannedDevices;
  final bool isScanning;
  final VoidCallback onRefresh;
  final Function(String macAddress, String name) onDeviceSelected;

  const ScanDevicesSheet({
    super.key,
    required this.scannedDevices,
    required this.isScanning,
    required this.onRefresh,
    required this.onDeviceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Lọc thiết bị trùng và chỉ lấy thiết bị có tên
    final Map<String, ScanResult> uniqueDevices = {};
    for (final result in scannedDevices) {
      final name = result.device.platformName;
      if (name.isNotEmpty) {
        uniqueDevices[result.device.remoteId.str] = result;
      }
    }
    final deviceList = uniqueDevices.values.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.scanDevices,
                style: AppTextStyles.headingMd.copyWith(color: AppColors.onSurface),
              ),
              if (isScanning)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: onRefresh,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: deviceList.isEmpty
                ? Center(
                    child: Text(
                      isScanning ? 'Đang tìm kiếm thiết bị...' : 'Không tìm thấy thiết bị nào',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: deviceList.length,
                    itemBuilder: (context, index) {
                      final item = deviceList[index];
                      final name = item.device.platformName;
                      final id = item.device.remoteId.str;
                      final rssi = item.rssi;

                      return ListTile(
                        leading: const Icon(Icons.bluetooth, color: AppColors.primary),
                        title: Text(name, style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface)),
                        subtitle: Text(id, style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$rssi dBm', style: AppTextStyles.bodySm),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: AppColors.divider),
                          ],
                        ),
                        onTap: () => onDeviceSelected(id, name),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Đóng',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
