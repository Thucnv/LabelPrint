import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:pdfx/pdfx.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/image_utils.dart';
import '../../entities/enums/barcode_type.dart';
import '../../entities/enums/print_enums.dart';
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
    final pdfPath = params.data['pdfPath'] as String?;
    if (pdfPath == null || pdfPath.isEmpty) {
      return const Left(ValidationFailure(message: 'Thiếu đường dẫn file PDF'));
    }

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
      final pageNumber = params.data['pageNumber'] as int? ?? 1;

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
    final imagePath = params.data['imagePath'] as String?;
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

    final imageBytes = params.data['imageBytes'] as Uint8List?;
    if (imageBytes != null) {
      return Right(imageBytes);
    }

    return const Left(ValidationFailure(message: 'Thiếu dữ liệu hình ảnh'));
  }

  /// Sinh preview cho barcode
  Future<Either<Failure, Uint8List>> _generateBarcodePreview(
    GeneratePreviewParams params,
  ) async {
    final barcodeData = params.data['barcodeData'] as Map<String, dynamic>?;
    if (barcodeData == null) {
      return const Left(ValidationFailure(message: 'Thiếu dữ liệu barcode'));
    }

    final data = barcodeData['data'] as String? ?? '';
    final type = barcodeData['type'] as BarcodeType? ?? BarcodeType.code128;
    final height = (barcodeData['height'] as num?)?.toDouble() ?? 100.0;
    final showText = barcodeData['showText'] as bool? ?? true;

    return await generateBarcodeUsecase(GenerateBarcodeParams(
      data: data,
      type: type,
      height: height,
      showText: showText,
    ));
  }

  /// Sinh preview cho phiếu giao hàng
  Future<Either<Failure, Uint8List>> _generateDeliveryNotePreview(
    GeneratePreviewParams params,
  ) async {
    final deliveryNoteData = params.data['deliveryNoteData'] as Map<String, dynamic>?;
    if (deliveryNoteData == null) {
      return const Left(ValidationFailure(message: 'Thiếu dữ liệu phiếu giao hàng'));
    }

    try {
      final bytes = await ImageUtils.generateDeliveryNoteBytes(
        deliveryNoteData: deliveryNoteData,
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

  /// Dữ liệu đầu vào (tùy theo loại document)
  final Map<String, dynamic> data;

  /// Cấu hình in hiện tại
  final PrinterConfig config;

  const GeneratePreviewParams({
    required this.documentType,
    required this.data,
    required this.config,
  });

  @override
  List<Object?> get props => [documentType, data, config];
}
