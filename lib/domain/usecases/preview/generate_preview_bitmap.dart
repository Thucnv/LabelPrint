import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:pdfx/pdfx.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/image_utils.dart';
import '../../entities/enums/print_enums.dart';
import '../../entities/preview_data.dart';
import '../../entities/printer_config.dart';
import '../barcode/generate_barcode.dart';
import '../usecase.dart';

/// Usecase sinh ảnh preview bitmap cho các loại tài liệu in khác nhau.
///
/// Hỗ trợ: Barcode, QR Code, Label, Shipping Label, Delivery Note, Receipt, PDF, Image
class GeneratePreviewBitmap implements UseCase<Uint8List, GeneratePreviewParams> {
  final GenerateBarcode generateBarcodeUsecase;

  GeneratePreviewBitmap({required this.generateBarcodeUsecase});

  @override
  Future<Either<Failure, Uint8List>> call(GeneratePreviewParams params) async {
    try {
      switch (params.documentType) {
        case DocumentType.barcode:
          return await _generateBarcodePreview(params);
        case DocumentType.qr:
          return Right(Uint8List(0));
        case DocumentType.label:
          return Right(Uint8List(0));
        case DocumentType.shippingLabel:
          return Right(Uint8List(0));
        case DocumentType.deliveryNote:
          return await _generateDeliveryNotePreview(params);
        case DocumentType.receipt:
          return Right(Uint8List(0));
        case DocumentType.pdf:
          return await _generatePdfPreview(params);
        case DocumentType.image:
          return await _generateImagePreview(params);
      }
    } catch (e) {
      return Left(PrinterFailure(message: e.toString()));
    }
  }

  /// Sinh preview cho trang PDF
  Future<Either<Failure, Uint8List>> _generatePdfPreview(
    GeneratePreviewParams params,
  ) async {
    final previewData = params.previewData;
    if (previewData is! PdfPreviewData) {
      return const Left(ValidationFailure(message: 'Dữ liệu PDF không hợp lệ'));
    }

    final pdfPath = previewData.pdfPath;

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
      if (!await file.exists()) {
        return Left(ValidationFailure(message: 'File PDF không tồn tại tại: $cleanPath'));
      }

      final document = await PdfDocument.openFile(cleanPath);
      final pageNumber = previewData.pageNumber;

      if (pageNumber < 1 || pageNumber > document.pagesCount) {
        await document.close();
        return Left(ValidationFailure(
          message: 'Trang $pageNumber không hợp lệ (PDF có ${document.pagesCount} trang)',
        ));
      }

      final page = await document.getPage(pageNumber);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );

      await page.close();
      await document.close();

      if (pageImage == null) {
        return const Left(PrinterFailure(message: 'Không thể render trang PDF'));
      }

      return Right(pageImage.bytes);
    } catch (e) {
      return Left(PrinterFailure(message: 'Lỗi xử lý file PDF: $e'));
    }
  }

  /// Sinh preview cho image từ file path hoặc bytes trực tiếp
  Future<Either<Failure, Uint8List>> _generateImagePreview(
    GeneratePreviewParams params,
  ) async {
    final previewData = params.previewData;
    if (previewData is! ImagePreviewData) {
      return const Left(ValidationFailure(message: 'Dữ liệu ảnh không hợp lệ'));
    }

    final imagePath = previewData.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        String cleanPath = imagePath;
        if (cleanPath.startsWith('file://')) {
          try {
            cleanPath = Uri.parse(cleanPath).toFilePath();
          } catch (_) {
            cleanPath = cleanPath.replaceFirst('file://', '');
          }
        }
        final file = File(cleanPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          return Right(bytes);
        } else {
          return Left(ValidationFailure(message: 'File ảnh không tồn tại tại: $cleanPath'));
        }
      } catch (e) {
        return Left(PrinterFailure(message: 'Không thể đọc file ảnh: $e'));
      }
    }

    final imageBytes = previewData.imageBytes;
    if (imageBytes != null) {
      return Right(Uint8List.fromList(imageBytes));
    }

    return const Left(ValidationFailure(message: 'Thiếu dữ liệu hình ảnh'));
  }

  /// Sinh preview cho barcode
  Future<Either<Failure, Uint8List>> _generateBarcodePreview(
    GeneratePreviewParams params,
  ) async {
    final previewData = params.previewData;
    if (previewData is! BarcodePreviewData) {
      return const Left(ValidationFailure(message: 'Dữ liệu barcode không hợp lệ'));
    }

    return await generateBarcodeUsecase(GenerateBarcodeParams(
      data: previewData.data,
      type: previewData.type,
      height: previewData.height,
      showText: previewData.showText,
    ));
  }

  /// Sinh preview cho phiếu giao hàng
  Future<Either<Failure, Uint8List>> _generateDeliveryNotePreview(
    GeneratePreviewParams params,
  ) async {
    final previewData = params.previewData;
    if (previewData is! DeliveryNotePreviewData) {
      return const Left(ValidationFailure(message: 'Dữ liệu phiếu giao hàng không hợp lệ'));
    }

    try {
      // Convert typed PreviewData sang Map để tương thích với ImageUtils.generateDeliveryNoteBytes
      final deliveryNoteMap = {
        'code': previewData.code,
        'sender': previewData.sender,
        'receiver': previewData.receiver,
        'items': previewData.items
            .map((item) => {
                  'name': item.name,
                  'quantity': item.quantity,
                  'unit': item.unit,
                })
            .toList(),
      };
      final bytes = await ImageUtils.generateDeliveryNoteBytes(
        deliveryNoteData: deliveryNoteMap,
        config: params.config,
      );
      return Right(bytes);
    } catch (e) {
      return Left(PrinterFailure(message: 'Lỗi vẽ phiếu giao hàng: $e'));
    }
  }
}

/// Tham số truyền vào Usecase GeneratePreviewBitmap
class GeneratePreviewParams extends Equatable {
  /// Loại tài liệu cần sinh preview
  final DocumentType documentType;

  /// Dữ liệu đầu vào dạng typed — đảm bảo type safety tại compile time.
  final PreviewData previewData;

  /// Cấu hình in hiện tại
  final PrinterConfig config;

  const GeneratePreviewParams({
    required this.documentType,
    required this.previewData,
    required this.config,
  });

  @override
  List<Object?> get props => [documentType, previewData, config];
}
