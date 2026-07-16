import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfx/pdfx.dart';

import '../../../domain/entities/preview_data.dart';
import '../../../domain/entities/printer_config.dart';
import '../../../domain/entities/enums/print_enums.dart';
import '../../../domain/entities/printer.dart';
import '../../../domain/entities/template.dart';
import '../../../domain/usecases/preview/generate_preview_bitmap.dart';
import '../../../domain/usecases/printer/get_default_printer.dart';
import '../../../domain/usecases/config/get_config.dart';
import '../../../domain/usecases/template/get_all_templates.dart';
import '../../../domain/usecases/printer/print_document.dart';
import '../../../domain/usecases/usecase.dart';
import 'print_preview_state.dart';

/// Cubit quản lý state cho màn hình Xem trước bản in.
class PrintPreviewCubit extends Cubit<PrintPreviewState> {
  final GeneratePreviewBitmap generatePreviewUsecase;
  final GetDefaultPrinter getDefaultPrinterUsecase;
  final GetConfig getConfigUsecase;
  final GetAllTemplates getAllTemplatesUsecase;
  final PrintDocument printDocumentUsecase;

  PrintPreviewCubit({
    required this.generatePreviewUsecase,
    required this.getDefaultPrinterUsecase,
    required this.getConfigUsecase,
    required this.getAllTemplatesUsecase,
    required this.printDocumentUsecase,
    required PrinterConfig initialConfig,
    DocumentType documentType = DocumentType.barcode,
  }) : super(PrintPreviewState(
          config: initialConfig,
          documentType: documentType,
        ));

  /// Tải cấu hình mặc định của máy in mặc định và danh sách bản mẫu
  Future<void> loadPrinterDefaultConfig(PreviewData previewData) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    int totalPages = 1;
    if (state.documentType == DocumentType.pdf && previewData is PdfPreviewData) {
      final pdfPath = previewData.pdfPath;
      if (pdfPath.isNotEmpty) {
        try {
          String cleanPath = pdfPath;
          if (cleanPath.startsWith('file://')) {
            try {
              cleanPath = Uri.parse(cleanPath).toFilePath();
            } catch (_) {
              cleanPath = cleanPath.replaceFirst('file://', '');
            }
          }
          final file = File(cleanPath);
          if (await file.exists()) {
            final doc = await PdfDocument.openFile(cleanPath);
            totalPages = doc.pagesCount;
            await doc.close();
          }
        } catch (e) {
          emit(state.copyWith(errorMessage: 'Không thể đọc số trang PDF: $e'));
        }
      }
    }

    final templatesResult = await getAllTemplatesUsecase(const NoParams());
    final List<Template> templates = templatesResult.fold(
      (failure) => [],
      (list) => list,
    );

    final printerResult = await getDefaultPrinterUsecase(const NoParams());

    await printerResult.fold(
      (failure) async {
        emit(state.copyWith(templates: templates, totalPages: totalPages));
        await generatePreview(previewData);
      },
      (Printer? printer) async {
        if (printer == null) {
          emit(state.copyWith(templates: templates, totalPages: totalPages));
          await generatePreview(previewData);
          return;
        }

        final configResult = await getConfigUsecase(printer.id!);
        await configResult.fold(
          (failure) async {
            emit(state.copyWith(templates: templates, totalPages: totalPages));
            await generatePreview(previewData);
          },
          (PrinterConfig? config) async {
            if (config != null) {
              final int rotation = (config.orientation == Orientation.landscape) ? 90 : 0;
              emit(state.copyWith(
                config: config,
                rotation: rotation,
                templates: templates,
                totalPages: totalPages,
              ));
            } else {
              emit(state.copyWith(templates: templates, totalPages: totalPages));
            }
            await generatePreview(previewData);
          },
        );
      },
    );
  }

  /// Cập nhật cấu hình in (từ màn hình Print Config)
  void updateConfig(PrinterConfig newConfig) {
    emit(state.copyWith(config: newConfig));
  }

  /// Cập nhật khổ giấy
  void updatePaperSize(PaperSize paperSize) {
    final newConfig = state.config.copyWith(paperSize: paperSize);
    emit(state.copyWith(config: newConfig));
  }

  /// Cập nhật khổ giấy và kích thước tùy chỉnh
  void updatePaperSizeAndCustomDimensions(PaperSize paperSize, {int? width, int? height}) {
    final newConfig = state.config.copyWith(
      paperSize: paperSize,
      customWidthMm: width ?? state.config.customWidthMm,
      customHeightMm: height ?? state.config.customHeightMm,
    );
    emit(state.copyWith(config: newConfig));
  }

  /// Cập nhật loại giấy
  void updatePaperType(PaperType paperType) {
    final newConfig = state.config.copyWith(paperType: paperType);
    emit(state.copyWith(config: newConfig));
  }

  /// Cập nhật hướng xoay (0, 90, 180, 270 độ)
  void updateRotation(int rotation) {
    final newOrientation = (rotation == 90 || rotation == 270)
        ? Orientation.landscape
        : Orientation.portrait;

    final newConfig = state.config.copyWith(orientation: newOrientation);
    emit(state.copyWith(config: newConfig, rotation: rotation));
  }

  /// Cập nhật độ đậm in
  void updateDarkness(int darkness) {
    final newConfig = state.config.copyWith(printDarkness: darkness);
    emit(state.copyWith(config: newConfig));
  }

  /// Cập nhật lề
  void updateMargins({
    double? top,
    double? left,
    double? right,
  }) {
    final newConfig = state.config.copyWith(
      marginTop: top ?? state.config.marginTop,
      marginLeft: left ?? state.config.marginLeft,
      marginRight: right ?? state.config.marginRight,
    );
    emit(state.copyWith(config: newConfig));
  }

  /// Cập nhật số bản sao
  void updateCopies(int copies) {
    emit(state.copyWith(copies: copies));
  }

  /// Cập nhật ảnh preview trực tiếp từ bytes.
  ///
  /// Dùng async/await với [ui.instantiateImageCodec] thay vì callback-based
  /// [ui.decodeImageFromList] để tránh race condition khi Cubit bị close.
  Future<void> updatePreviewImage(Uint8List image) async {
    try {
      final codec = await ui.instantiateImageCodec(image);
      final frame = await codec.getNextFrame();
      if (!isClosed) {
        emit(state.copyWith(
          previewImage: image,
          imageWidth: frame.image.width,
          imageHeight: frame.image.height,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'Không thể giải mã ảnh preview: $e'));
      }
    }
  }

  /// Sinh preview bitmap từ dữ liệu [PreviewData].
  ///
  /// Dùng async/await với [ui.instantiateImageCodec] thay vì callback-based
  /// [ui.decodeImageFromList] để tránh race condition khi Cubit bị close.
  Future<void> generatePreview(PreviewData previewData) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await generatePreviewUsecase(GeneratePreviewParams(
      documentType: state.documentType,
      previewData: previewData,
      config: state.config,
    ));

    await result.fold(
      (failure) async {
        if (!isClosed) {
          emit(state.copyWith(
            errorMessage: failure.message,
            isLoading: false,
          ));
        }
      },
      (bytes) async {
        try {
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          if (!isClosed) {
            emit(state.copyWith(
              previewImage: bytes,
              imageWidth: frame.image.width,
              imageHeight: frame.image.height,
              isLoading: false,
            ));
          }
        } catch (e) {
          if (!isClosed) {
            emit(state.copyWith(
              errorMessage: 'Không thể giải mã ảnh preview: $e',
              isLoading: false,
            ));
          }
        }
      },
    );
  }

  /// Thay đổi trang PDF hiện tại
  Future<void> updatePdfPage(int page, PdfPreviewData previewData) async {
    if (page < 1 || page > state.totalPages) return;
    emit(state.copyWith(currentPage: page));
    await generatePreview(previewData.copyWithPage(page));
  }

  /// Thực hiện gửi lệnh in tài liệu hiện tại
  Future<void> printCurrentDocument() async {
    if (state.previewImage == null) {
      emit(state.copyWith(errorMessage: 'Không có dữ liệu ảnh để in'));
      return;
    }

    emit(state.copyWith(isPrinting: true, errorMessage: null, success: false));

    String jobName = 'In tài liệu';
    if (state.documentType == DocumentType.barcode) {
      jobName = 'In mã vạch';
    } else if (state.documentType == DocumentType.image) {
      jobName = 'In hình ảnh';
    } else if (state.documentType == DocumentType.pdf) {
      jobName = 'In PDF - Trang ${state.currentPage}';
    }

    final result = await printDocumentUsecase(PrintDocumentParams(
      documentType: state.documentType,
      jobName: jobName,
      previewBytes: state.previewImage!,
      config: state.config,
      copies: state.copies,
      rotation: state.rotation,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        isPrinting: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isPrinting: false,
        success: true,
      )),
    );
  }

  /// Bắt đầu in
  void setPrinting(bool printing) {
    emit(state.copyWith(isPrinting: printing));
  }

  /// Xử lý lỗi
  void setError(String error) {
    emit(state.copyWith(
      errorMessage: error,
      isLoading: false,
      isPrinting: false,
    ));
  }

  /// Xử lý thành công
  void setSuccess() {
    emit(state.copyWith(
      success: true,
      isPrinting: false,
      errorMessage: null,
    ));
  }

  /// Reset trạng thái thành công
  void resetSuccess() {
    emit(state.copyWith(success: false));
  }
}
