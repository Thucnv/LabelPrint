import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/enums/print_enums.dart';
import '../../../domain/entities/printer.dart';
import '../../../domain/entities/printer_config.dart';
import '../../../domain/entities/template.dart';
import '../../../domain/usecases/config/get_config.dart';
import '../../../domain/usecases/config/save_config.dart';
import '../../../domain/usecases/printer/get_default_printer.dart';
import '../../../domain/usecases/template/save_as_template.dart';
import '../../../domain/usecases/template/get_all_templates.dart';
import '../../../domain/usecases/usecase.dart';
import 'print_config_state.dart';

class PrintConfigCubit extends Cubit<PrintConfigState> {
  final GetConfig getConfigUsecase;
  final SaveConfig saveConfigUsecase;
  final SaveAsTemplate saveAsTemplateUsecase;
  final GetDefaultPrinter getDefaultPrinterUsecase;
  final GetAllTemplates getAllTemplatesUsecase;

  PrintConfigCubit({
    required this.getConfigUsecase,
    required this.saveConfigUsecase,
    required this.saveAsTemplateUsecase,
    required this.getDefaultPrinterUsecase,
    required this.getAllTemplatesUsecase,
  }) : super(const PrintConfigState());

  /// Tải cấu hình hiện tại của máy in mặc định và danh sách bản mẫu
  Future<void> loadConfig() async {
    emit(state.copyWith(status: PrintConfigStatus.loading));

    final templatesResult = await getAllTemplatesUsecase(const NoParams());
    final List<Template> templates = templatesResult.fold(
      (failure) => [],
      (list) => list,
    );

    final printerResult = await getDefaultPrinterUsecase(const NoParams());
    
    await printerResult.fold(
      (failure) async {
        emit(state.copyWith(
          status: PrintConfigStatus.error,
          errorMessage: failure.message,
          templates: templates,
        ));
      },
      (Printer? printer) async {
        if (printer == null) {
          emit(state.copyWith(
            status: PrintConfigStatus.error,
            errorMessage: 'Chưa cấu hình máy in mặc định',
            templates: templates,
          ));
          return;
        }

        final configResult = await getConfigUsecase(printer.id!);
        configResult.fold(
          (failure) {
            emit(state.copyWith(
              status: PrintConfigStatus.loaded,
              printerId: printer.id,
              printerName: printer.name,
              printerType: printer.type,
              templates: templates,
            ));
          },
          (PrinterConfig? config) {
            if (config == null) {
              emit(state.copyWith(
                status: PrintConfigStatus.loaded,
                printerId: printer.id,
                printerName: printer.name,
                printerType: printer.type,
                templates: templates,
              ));
            } else {
              emit(state.copyWith(
                status: PrintConfigStatus.loaded,
                printerId: printer.id,
                printerName: printer.name,
                printerType: printer.type,
                paperSize: config.paperSize,
                paperType: config.paperType,
                orientation: config.orientation,
                marginTop: config.marginTop,
                marginLeft: config.marginLeft,
                marginRight: config.marginRight,
                printDarkness: config.printDarkness,
                printSpeed: config.printSpeed,
                scalingMode: config.scalingMode,
                scalingValue: config.scalingValue,
                customWidthMm: config.customWidthMm ?? 100,
                customHeightMm: config.customHeightMm ?? 150,
                labelGap: config.labelGap,
                templates: templates,
              ));
            }
          },
        );
      },
    );
  }

  // Cập nhật state realtime từ UI
  void updatePaperSize(PaperSize value) => emit(state.copyWith(paperSize: value));
  void updatePaperType(PaperType value) => emit(state.copyWith(paperType: value));
  void updateOrientation(Orientation value) => emit(state.copyWith(orientation: value));
  void updateMargins(double top, double left, double right) =>
      emit(state.copyWith(marginTop: top, marginLeft: left, marginRight: right));
  void updateDarkness(int value) => emit(state.copyWith(printDarkness: value));
  void updateSpeed(double value) => emit(state.copyWith(printSpeed: value));
  void updateScaling(ScalingMode mode, int value) =>
      emit(state.copyWith(scalingMode: mode, scalingValue: value));
  void updateCustomSize(int width, int height) =>
      emit(state.copyWith(customWidthMm: width, customHeightMm: height));
  void updateLabelGap(double value) => emit(state.copyWith(labelGap: value));
  void updateTemplateName(String value) => emit(state.copyWith(templateName: value));

  /// Lưu cấu hình hiện tại
  Future<void> saveConfig() async {
    if (state.printerId == null) {
      emit(state.copyWith(status: PrintConfigStatus.error, errorMessage: 'Không có máy in mặc định'));
      return;
    }

    emit(state.copyWith(status: PrintConfigStatus.loading));

    final config = PrinterConfig(
      printerId: state.printerId!,
      paperSize: state.paperSize,
      paperType: state.paperType,
      orientation: state.orientation,
      marginTop: state.marginTop,
      marginLeft: state.marginLeft,
      marginRight: state.marginRight,
      printDarkness: state.printDarkness,
      printSpeed: state.printSpeed,
      scalingMode: state.scalingMode,
      scalingValue: state.scalingValue,
      customWidthMm: state.paperSize == PaperSize.custom ? state.customWidthMm : null,
      customHeightMm: state.paperSize == PaperSize.custom ? state.customHeightMm : null,
      labelGap: state.labelGap,
    );

    final result = await saveConfigUsecase(config);

    result.fold(
      (failure) => emit(state.copyWith(status: PrintConfigStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: PrintConfigStatus.success, successMessage: 'Đã lưu cấu hình trang in.')),
    );
  }

  /// Lưu thành bản mẫu thiết kế mới (Template)
  Future<void> saveAsTemplate() async {
    if (state.templateName.trim().isEmpty) {
      emit(state.copyWith(status: PrintConfigStatus.error, errorMessage: 'Tên bản mẫu không được trống'));
      return;
    }

    emit(state.copyWith(status: PrintConfigStatus.loading));

    final template = Template(
      name: state.templateName.trim(),
      widthMm: state.paperSize == PaperSize.custom ? state.customWidthMm! : state.paperSize.widthMm,
      heightMm: state.paperSize == PaperSize.custom ? state.customHeightMm! : state.paperSize.heightMm,
    );

    final result = await saveAsTemplateUsecase(template);

    await result.fold(
      (failure) async => emit(state.copyWith(status: PrintConfigStatus.error, errorMessage: failure.message)),
      (_) async {
        // Tải lại danh sách bản mẫu sau khi lưu thành công
        final templatesResult = await getAllTemplatesUsecase(const NoParams());
        final List<Template> templates = templatesResult.fold(
          (failure) => [],
          (list) => list,
        );
        emit(state.copyWith(
          status: PrintConfigStatus.success,
          successMessage: 'Mẫu thiết kế đã được lưu vào thư viện.',
          templates: templates,
        ));
      },
    );
  }
}
