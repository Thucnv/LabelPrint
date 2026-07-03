import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../../../domain/usecases/barcode/print_barcode.dart';
import 'barcode_event.dart';
import 'barcode_state.dart';

class BarcodeBloc extends Bloc<BarcodeEvent, BarcodeState> {
  final PrintBarcode printBarcodeUsecase;

  BarcodeBloc({
    required this.printBarcodeUsecase,
  }) : super(const BarcodeState()) {
    on<BarcodeDataChanged>(_onDataChanged);
    on<BarcodeTypeChanged>(_onTypeChanged);
    on<BarcodeHeightChanged>(_onHeightChanged);
    on<BarcodeShowTextChanged>(_onShowTextChanged);
    on<PrintBarcodeRequested>(_onPrintBarcodeRequested);
  }

  void _onDataChanged(BarcodeDataChanged event, Emitter<BarcodeState> emit) {
    final validation = Validators.validateBarcodeData(event.data, state.barcodeType);
    emit(state.copyWith(
      data: event.data,
      validationError: validation,
    ));
  }

  void _onTypeChanged(BarcodeTypeChanged event, Emitter<BarcodeState> emit) {
    // Validate lại với kiểu barcode mới
    final validation = Validators.validateBarcodeData(state.data, event.type);
    emit(state.copyWith(
      barcodeType: event.type,
      validationError: validation,
    ));
  }

  void _onHeightChanged(BarcodeHeightChanged event, Emitter<BarcodeState> emit) {
    emit(state.copyWith(height: event.height));
  }

  void _onShowTextChanged(BarcodeShowTextChanged event, Emitter<BarcodeState> emit) {
    emit(state.copyWith(showText: event.showText));
  }

  Future<void> _onPrintBarcodeRequested(
    PrintBarcodeRequested event,
    Emitter<BarcodeState> emit,
  ) async {
    // 1. Kiểm tra validation
    final validation = Validators.validateBarcodeData(state.data, state.barcodeType);
    if (validation != null) {
      emit(state.copyWith(validationError: validation));
      return;
    }

    emit(state.copyWith(isPrinting: true, success: false));

    final result = await printBarcodeUsecase(PrintBarcodeParams(
      data: state.data,
      type: state.barcodeType,
      height: state.height,
      showText: state.showText,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        isPrinting: false,
        success: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isPrinting: false,
        success: true,
      )),
    );
  }
}
