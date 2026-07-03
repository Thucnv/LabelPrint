import 'package:equatable/equatable.dart';

import '../../../domain/entities/enums/print_enums.dart';
import '../../../domain/entities/enums/printer_enums.dart';
import '../../../domain/entities/template.dart';

enum PrintConfigStatus { initial, loading, loaded, success, error }

class PrintConfigState extends Equatable {
  final PrintConfigStatus status;
  final int? printerId;
  final String? printerName;
  final PrinterType? printerType;
  final PaperSize paperSize;
  final PaperType paperType;
  final Orientation orientation;
  final double marginTop;
  final double marginLeft;
  final double marginRight;
  final int printDarkness;
  final double printSpeed;
  final ScalingMode scalingMode;
  final int scalingValue;
  final int? customWidthMm;
  final int? customHeightMm;
  final double labelGap;

  final String templateName;
  final String? errorMessage;
  final String? successMessage;
  
  /// Danh sách các bản mẫu đã lưu
  final List<Template> templates;

  const PrintConfigState({
    this.status = PrintConfigStatus.initial,
    this.printerId,
    this.printerName,
    this.printerType,
    this.paperSize = PaperSize.A6,
    this.paperType = PaperType.label,
    this.orientation = Orientation.portrait,
    this.marginTop = 0.0,
    this.marginLeft = 0.0,
    this.marginRight = 0.0,
    this.printDarkness = 8,
    this.printSpeed = 4.0,
    this.scalingMode = ScalingMode.fitWidth,
    this.scalingValue = 100,
    this.customWidthMm = 100,
    this.customHeightMm = 150,
    this.labelGap = 0.0,
    this.templateName = '',
    this.errorMessage,
    this.successMessage,
    this.templates = const [],
  });

  PrintConfigState copyWith({
    PrintConfigStatus? status,
    int? printerId,
    String? printerName,
    PrinterType? printerType,
    PaperSize? paperSize,
    PaperType? paperType,
    Orientation? orientation,
    double? marginTop,
    double? marginLeft,
    double? marginRight,
    int? printDarkness,
    double? printSpeed,
    ScalingMode? scalingMode,
    int? scalingValue,
    int? customWidthMm,
    int? customHeightMm,
    double? labelGap,
    String? templateName,
    String? errorMessage,
    String? successMessage,
    List<Template>? templates,
  }) {
    return PrintConfigState(
      status: status ?? this.status,
      printerId: printerId ?? this.printerId,
      printerName: printerName ?? this.printerName,
      printerType: printerType ?? this.printerType,
      paperSize: paperSize ?? this.paperSize,
      paperType: paperType ?? this.paperType,
      orientation: orientation ?? this.orientation,
      marginTop: marginTop ?? this.marginTop,
      marginLeft: marginLeft ?? this.marginLeft,
      marginRight: marginRight ?? this.marginRight,
      printDarkness: printDarkness ?? this.printDarkness,
      printSpeed: printSpeed ?? this.printSpeed,
      scalingMode: scalingMode ?? this.scalingMode,
      scalingValue: scalingValue ?? this.scalingValue,
      customWidthMm: customWidthMm ?? this.customWidthMm,
      customHeightMm: customHeightMm ?? this.customHeightMm,
      labelGap: labelGap ?? this.labelGap,
      templateName: templateName ?? this.templateName,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      templates: templates ?? this.templates,
    );
  }

  @override
  List<Object?> get props => [
        status,
        printerId,
        printerName,
        printerType,
        paperSize,
        paperType,
        orientation,
        marginTop,
        marginLeft,
        marginRight,
        printDarkness,
        printSpeed,
        scalingMode,
        scalingValue,
        customWidthMm,
        customHeightMm,
        labelGap,
        templateName,
        errorMessage,
        successMessage,
        templates,
      ];
}
