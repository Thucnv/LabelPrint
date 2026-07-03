import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/bluetooth_utils.dart';
import '../../../domain/usecases/printer/add_printer.dart';
import '../../../domain/usecases/printer/delete_printer.dart';
import '../../../domain/usecases/printer/get_all_printers.dart';
import '../../../domain/usecases/printer/set_default_printer.dart';
import '../../../domain/usecases/printer/test_connection.dart';
import '../../../domain/usecases/printer/update_printer.dart';
import '../../../domain/usecases/usecase.dart';
import 'printer_list_event.dart';
import 'printer_list_state.dart';

class PrinterListBloc extends Bloc<PrinterListEvent, PrinterListState> {
  final GetAllPrinters getAllPrinters;
  final AddPrinter addPrinterUsecase;
  final UpdatePrinter updatePrinterUsecase;
  final DeletePrinter deletePrinterUsecase;
  final SetDefaultPrinter setDefaultPrinterUsecase;
  final TestConnection testConnectionUsecase;

  StreamSubscription? _scanSubscription;

  PrinterListBloc({
    required this.getAllPrinters,
    required this.addPrinterUsecase,
    required this.updatePrinterUsecase,
    required this.deletePrinterUsecase,
    required this.setDefaultPrinterUsecase,
    required this.testConnectionUsecase,
  }) : super(PrinterListInitial()) {
    on<LoadPrinters>(_onLoadPrinters);
    on<AddPrinterEvent>(_onAddPrinter);
    on<UpdatePrinterEvent>(_onUpdatePrinter);
    on<DeletePrinterEvent>(_onDeletePrinter);
    on<SetDefaultEvent>(_onSetDefault);
    on<TestConnectionEvent>(_onTestConnection);
    on<ScanBluetoothEvent>(_onScanBluetooth);
    on<ScannedDevicesUpdated>(_onScannedDevicesUpdated);
  }

  void _onScannedDevicesUpdated(
    ScannedDevicesUpdated event,
    Emitter<PrinterListState> emit,
  ) {
    final currentState = state;
    if (currentState is PrinterListLoaded) {
      emit(currentState.copyWith(scannedDevices: event.scannedDevices));
    }
  }

  Future<void> _onLoadPrinters(
    LoadPrinters event,
    Emitter<PrinterListState> emit,
  ) async {
    emit(PrinterListLoading());
    final result = await getAllPrinters(const NoParams());
    
    result.fold(
      (failure) => emit(PrinterListError(failure.message)),
      (printers) => emit(PrinterListLoaded(printers: printers)),
    );
  }

  Future<void> _onAddPrinter(
    AddPrinterEvent event,
    Emitter<PrinterListState> emit,
  ) async {
    final result = await addPrinterUsecase(event.printer);
    await result.fold(
      (failure) async => emit(PrinterListError(failure.message)),
      (id) async => add(LoadPrinters()),
    );
  }

  Future<void> _onUpdatePrinter(
    UpdatePrinterEvent event,
    Emitter<PrinterListState> emit,
  ) async {
    final result = await updatePrinterUsecase(event.printer);
    await result.fold(
      (failure) async => emit(PrinterListError(failure.message)),
      (_) async => add(LoadPrinters()),
    );
  }

  Future<void> _onDeletePrinter(
    DeletePrinterEvent event,
    Emitter<PrinterListState> emit,
  ) async {
    final result = await deletePrinterUsecase(event.id);
    await result.fold(
      (failure) async => emit(PrinterListError(failure.message)),
      (_) async => add(LoadPrinters()),
    );
  }

  Future<void> _onSetDefault(
    SetDefaultEvent event,
    Emitter<PrinterListState> emit,
  ) async {
    final result = await setDefaultPrinterUsecase(event.id);
    await result.fold(
      (failure) async => emit(PrinterListError(failure.message)),
      (_) async => add(LoadPrinters()),
    );
  }

  Future<void> _onTestConnection(
    TestConnectionEvent event,
    Emitter<PrinterListState> emit,
  ) async {
    // Lưu lại state hiện tại để khôi phục sau khi in thử
    final currentState = state;
    emit(TestConnectionInProgress());

    final result = await testConnectionUsecase(event.printer);

    result.fold(
      (failure) => emit(TestConnectionFailed(failure.message)),
      (_) => emit(TestConnectionSuccess()),
    );

    // Quay lại hiển thị danh sách máy in sau 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));
    if (currentState is PrinterListLoaded) {
      emit(currentState);
    } else {
      add(LoadPrinters());
    }
  }

  Future<void> _onScanBluetooth(
    ScanBluetoothEvent event,
    Emitter<PrinterListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PrinterListLoaded) return;

    emit(currentState.copyWith(isScanning: true, scannedDevices: []));

    try {
      // Đăng ký lắng nghe kết quả quét bluetooth
      await _scanSubscription?.cancel();
      _scanSubscription = BluetoothUtils.scanResults.listen((results) {
        // Lọc thiết bị có tên hợp lệ (tránh rác)
        final cleanResults = results.where((r) => r.device.platformName.isNotEmpty).toList();
        add(ScannedDevicesUpdated(cleanResults));
      });

      // Bắt đầu quét bluetooth
      await BluetoothUtils.startScan(timeout: const Duration(seconds: 4));
      await Future.delayed(const Duration(seconds: 4));
      
      final currentLoadedState = state;
      if (currentLoadedState is PrinterListLoaded) {
        emit(currentLoadedState.copyWith(isScanning: false));
      }
    } catch (e) {
      emit(PrinterListError('Lỗi quét thiết bị Bluetooth: $e'));
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    BluetoothUtils.stopScan();
    return super.close();
  }
}
