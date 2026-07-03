import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../domain/entities/printer.dart';

abstract class PrinterListEvent extends Equatable {
  const PrinterListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrinters extends PrinterListEvent {}

class AddPrinterEvent extends PrinterListEvent {
  final Printer printer;

  const AddPrinterEvent(this.printer);

  @override
  List<Object?> get props => [printer];
}

class UpdatePrinterEvent extends PrinterListEvent {
  final Printer printer;

  const UpdatePrinterEvent(this.printer);

  @override
  List<Object?> get props => [printer];
}

class DeletePrinterEvent extends PrinterListEvent {
  final int id;

  const DeletePrinterEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SetDefaultEvent extends PrinterListEvent {
  final int id;

  const SetDefaultEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class TestConnectionEvent extends PrinterListEvent {
  final Printer printer;

  const TestConnectionEvent(this.printer);

  @override
  List<Object?> get props => [printer];
}

class ScanBluetoothEvent extends PrinterListEvent {}

class ScannedDevicesUpdated extends PrinterListEvent {
  final List<ScanResult> scannedDevices;

  const ScannedDevicesUpdated(this.scannedDevices);

  @override
  List<Object?> get props => [scannedDevices];
}
