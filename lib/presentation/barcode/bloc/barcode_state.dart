import 'package:equatable/equatable.dart';

import '../../../domain/entities/enums/barcode_type.dart';

class BarcodeState extends Equatable {
  final String data;
  final BarcodeType barcodeType;
  final double height;
  final bool showText;
  final bool isPrinting;
  final bool success;
  final String? errorMessage;
  final String? validationError;

  const BarcodeState({
    this.data = '12345678',
    this.barcodeType = BarcodeType.code128,
    this.height = 80.0,
    this.showText = true,
    this.isPrinting = false,
    this.success = false,
    this.errorMessage,
    this.validationError,
  });

  BarcodeState copyWith({
    String? data,
    BarcodeType? barcodeType,
    double? height,
    bool? showText,
    bool? isPrinting,
    bool? success,
    String? errorMessage,
    String? validationError,
  }) {
    return BarcodeState(
      data: data ?? this.data,
      barcodeType: barcodeType ?? this.barcodeType,
      height: height ?? this.height,
      showText: showText ?? this.showText,
      isPrinting: isPrinting ?? this.isPrinting,
      success: success ?? this.success,
      errorMessage: errorMessage, // Reset if null
      validationError: validationError, // Reset if null
    );
  }

  @override
  List<Object?> get props => [
        data,
        barcodeType,
        height,
        showText,
        isPrinting,
        success,
        errorMessage,
        validationError,
      ];
}
