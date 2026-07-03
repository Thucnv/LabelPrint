import 'package:equatable/equatable.dart';

import '../../../domain/entities/enums/printer_enums.dart';
import '../../../domain/entities/printer.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final Printer? defaultPrinter;
  final PrinterStatus printerStatus;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.defaultPrinter,
    this.printerStatus = PrinterStatus.notConfigured,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    Printer? defaultPrinter,
    PrinterStatus? printerStatus,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      defaultPrinter: defaultPrinter ?? this.defaultPrinter,
      printerStatus: printerStatus ?? this.printerStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, defaultPrinter, printerStatus, errorMessage];
}
