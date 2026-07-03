import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../core/di/injection_container.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/printer_card.dart';
import '../../core/widgets/section_header.dart';
import '../../domain/entities/enums/printer_enums.dart';
import '../../domain/entities/printer.dart';
import 'bloc/printer_list_bloc.dart';
import 'bloc/printer_list_event.dart';
import 'bloc/printer_list_state.dart';
import 'widgets/add_printer_dialog.dart';
import 'widgets/scan_devices_sheet.dart';

class PrinterManagementScreen extends StatelessWidget {
  const PrinterManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<PrinterListBloc>(
      create: (context) => sl<PrinterListBloc>()..add(LoadPrinters()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            l10n.printerManagement,
            style: AppTextStyles.headingLg.copyWith(color: AppColors.onSurface),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
          actions: [
            // Nút Thêm máy in dạng [+]
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.add, color: AppColors.primary, size: 28),
                  onPressed: () => _showAddPrinterDialog(context),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocListener<PrinterListBloc, PrinterListState>(
          listenWhen: (previous, current) =>
              current is TestConnectionInProgress ||
              current is TestConnectionSuccess ||
              current is TestConnectionFailed ||
              current is PrinterListError,
          listener: (context, state) {
            if (state is TestConnectionInProgress) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        SizedBox(width: 16),
                        Text('Đang kết nối thử nghiệm...'),
                      ],
                    ),
                    duration: Duration(days: 1), // Giữ hiển thị
                  ),
                );
            } else if (state is TestConnectionSuccess) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.successTestPrint),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            } else if (state is TestConnectionFailed) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text('${l10n.errConnectionFailed}: ${state.message}'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            } else if (state is PrinterListError) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          },
          child: Column(
            children: [
              // 1. Danh sách máy in
              Expanded(
                child: BlocBuilder<PrinterListBloc, PrinterListState>(
                  buildWhen: (previous, current) => current is PrinterListLoaded || current is PrinterListLoading,
                  builder: (context, state) {
                    if (state is PrinterListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is PrinterListLoaded) {
                      final printers = state.printers;

                      if (printers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.print_outlined, size: 64, color: AppColors.statusIdle),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có máy in nào được thêm',
                                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 16),
                              PrimaryButton(
                                text: l10n.addPrinter,
                                icon: Icons.add,
                                onPressed: () => _showAddPrinterDialog(context),
                                isFullWidth: false,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        children: [
                          SectionHeader(title: 'DANH SÁCH MÁY IN ĐÃ LƯU'.toUpperCase()),
                          const SizedBox(height: 8),
                          ...printers.map((printer) {
                            return PrinterCard(
                              printer: printer,
                              status: printer.isDefault ? PrinterStatus.ready : PrinterStatus.idle,
                              onTestPrint: () => context
                                  .read<PrinterListBloc>()
                                  .add(TestConnectionEvent(printer)),
                              onEdit: () => _showEditPrinterDialog(context, printer),
                              onDelete: () => _showDeleteConfirmDialog(context, printer),
                              onSetDefault: () => context
                                  .read<PrinterListBloc>()
                                  .add(SetDefaultEvent(printer.id!)),
                            );
                          }),
                        ],
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),

              // 2. Nút quét bluetooth dưới cùng
              BlocBuilder<PrinterListBloc, PrinterListState>(
                buildWhen: (previous, current) => current is PrinterListLoaded,
                builder: (context, state) {
                  final isScanning = state is PrinterListLoaded ? state.isScanning : false;
                  final scanned = state is PrinterListLoaded ? state.scannedDevices : <ScanResult>[];

                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 16 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: PrimaryButton(
                      text: isScanning ? 'ĐANG QUÉT THIẾT BỊ...' : l10n.scanDevices.toUpperCase(),
                      icon: Icons.bluetooth_searching,
                      isLoading: isScanning,
                      onPressed: () => _showScanBluetoothBottomSheet(context, isScanning, scanned),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPrinterDialog(BuildContext context) async {
    final bloc = context.read<PrinterListBloc>();
    final newPrinter = await showDialog<Printer>(
      context: context,
      builder: (context) => const AddPrinterDialog(),
    );

    if (newPrinter != null) {
      bloc.add(AddPrinterEvent(newPrinter));
    }
  }

  void _showEditPrinterDialog(BuildContext context, Printer printer) async {
    final bloc = context.read<PrinterListBloc>();
    final updatedPrinter = await showDialog<Printer>(
      context: context,
      builder: (context) => AddPrinterDialog(printerToEdit: printer),
    );

    if (updatedPrinter != null) {
      bloc.add(UpdatePrinterEvent(updatedPrinter));
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, Printer printer) {
    final bloc = context.read<PrinterListBloc>();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePrinter),
        content: Text('Bạn chắc chắn muốn xóa máy in "${printer.name}"? Cấu hình in liên quan cũng sẽ bị xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: const TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              bloc.add(DeletePrinterEvent(printer.id!));
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showScanBluetoothBottomSheet(
    BuildContext parentContext,
    bool isScanning,
    List<ScanResult> scannedDevices,
  ) {
    final bloc = parentContext.read<PrinterListBloc>();
    
    // Gọi event quét ngay khi mở bottom sheet
    bloc.add(ScanBluetoothEvent());

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider<PrinterListBloc>.value(
          value: bloc,
          child: BlocBuilder<PrinterListBloc, PrinterListState>(
            builder: (context, state) {
              final currentScanState = state is PrinterListLoaded ? state.isScanning : false;
              final currentDevices = state is PrinterListLoaded ? state.scannedDevices : <ScanResult>[];

              return ScanDevicesSheet(
                scannedDevices: currentDevices,
                isScanning: currentScanState,
                onRefresh: () => bloc.add(ScanBluetoothEvent()),
                onDeviceSelected: (macAddress, name) async {
                  Navigator.pop(sheetContext); // Đóng sheet

                  // Hiển thị add dialog với địa chỉ MAC tự điền
                  final prefilledPrinter = Printer(
                    name: name,
                    type: PrinterType.label,
                    protocol: PrinterProtocol.tspl,
                    connectionMethod: ConnectionMethod.bluetooth,
                    btMacAddress: macAddress,
                  );

                  final addedPrinter = await showDialog<Printer>(
                    context: parentContext,
                    builder: (context) => AddPrinterDialog(printerToEdit: prefilledPrinter),
                  );

                  if (addedPrinter != null) {
                    bloc.add(AddPrinterEvent(addedPrinter));
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
