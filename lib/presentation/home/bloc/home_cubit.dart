import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/enums/printer_enums.dart';
import '../../../domain/entities/printer.dart';
import '../../../domain/usecases/printer/get_default_printer.dart';
import '../../../domain/usecases/usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetDefaultPrinter getDefaultPrinter;

  HomeCubit({required this.getDefaultPrinter}) : super(const HomeState());

  /// Tải thông tin máy in mặc định
  Future<void> loadDefaultPrinter() async {
    emit(state.copyWith(status: HomeStatus.loading));
    
    final result = await getDefaultPrinter(const NoParams());
    
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: HomeStatus.error,
          errorMessage: failure.message,
        ));
      },
      (Printer? printer) {
        if (printer == null) {
          emit(state.copyWith(
            status: HomeStatus.loaded,
            defaultPrinter: null,
            printerStatus: PrinterStatus.notConfigured,
          ));
        } else {
          // Trạng thái mock là READY cho máy in mặc định đã cấu hình
          emit(state.copyWith(
            status: HomeStatus.loaded,
            defaultPrinter: printer,
            printerStatus: PrinterStatus.ready,
          ));
        }
      },
    );
  }
}
