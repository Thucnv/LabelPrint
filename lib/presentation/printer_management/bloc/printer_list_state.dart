import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../domain/entities/printer.dart';

abstract class PrinterListState extends Equatable {
  const PrinterListState();

  @override
  List<Object?> get props => [];
}

class PrinterListInitial extends PrinterListState {}

class PrinterListLoading extends PrinterListState {}

class PrinterListLoaded extends PrinterListState {
  final List<Printer> printers;
  final bool isScanning;
  final List<ScanResult> scannedDevices;

  const PrinterListLoaded({
    required this.printers,
    this.isScanning = false,
    this.scannedDevices = const [],
  });

  PrinterListLoaded copyWith({
    List<Printer>? printers,
    bool? isScanning,
    List<ScanResult>? scannedDevices,
  }) {
    return PrinterListLoaded(
      printers: printers ?? this.printers,
      isScanning: isScanning ?? this.isScanning,
      scannedDevices: scannedDevices ?? this.scannedDevices,
    );
  }

  @override
  List<Object?> get props => [printers, isScanning, scannedDevices];
}

class PrinterListError extends PrinterListState {
  final String message;

  const PrinterListError(this.message);

  @override
  List<Object?> get props => [message];
}

class TestConnectionInProgress extends PrinterListState {}

class TestConnectionSuccess extends PrinterListState {}

class TestConnectionFailed extends PrinterListState {
  final String message;

  const TestConnectionFailed(this.message);

  @override
  List<Object?> get props => [message];
}
