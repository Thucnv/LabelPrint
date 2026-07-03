import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/printer_commands/escpos_generator.dart';
import '../../../core/utils/printer_commands/tspl_generator.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/printer_sender.dart';
import '../../entities/enums/print_enums.dart';
import '../../entities/enums/printer_enums.dart';
import '../../entities/print_job.dart';
import '../../entities/printer.dart';
import '../../entities/printer_config.dart';
import '../../repositories/print_job_repository.dart';
import '../../repositories/printer_repository.dart';
import '../usecase.dart';

/// Usecase thực hiện in tài liệu tổng quát (PDF, Image, Barcode, etc.):
/// Lấy thông tin máy in mặc định, giải mã ảnh preview, xoay theo góc chọn,
/// chuyển đổi sang mã lệnh in tương ứng (TSPL/ESC-POS) và gửi tới máy in qua mạng/Bluetooth.
class PrintDocument implements UseCase<void, PrintDocumentParams> {
  final PrinterRepository printerRepository;
  final PrintJobRepository printJobRepository;

  PrintDocument({
    required this.printerRepository,
    required this.printJobRepository,
  });

  @override
  Future<Either<Failure, void>> call(PrintDocumentParams params) async {
    int? jobId;
    try {
      // 1. Lấy thông tin máy in mặc định
      final printerResult = await printerRepository.getDefaultPrinter();
      if (printerResult.isLeft()) {
        return Left(printerResult.fold((l) => l, (r) => throw Exception()));
      }

      final Printer? printer = printerResult.fold((l) => null, (r) => r);
      if (printer == null) {
        return const Left(PrinterFailure(message: 'Chưa cấu hình máy in mặc định'));
      }

      // 2. Giải mã và điều chỉnh kích thước hình ảnh để phù hợp với độ phân giải/khổ giấy của máy in
      // Điều này giúp tránh tràn bộ đệm máy in (buffer overflow) và in ra các ký tự rác/mảng byte
      final originalCodec = await ui.instantiateImageCodec(params.previewBytes);
      final originalFrame = await originalCodec.getNextFrame();
      final originalImage = originalFrame.image;
      
      final double aspectRatio = originalImage.height / originalImage.width;
      
      // Tính toán kích thước đích (đơn vị dot/pixel)
      int targetWidth;
      if (printer.protocol == PrinterProtocol.tspl) {
        targetWidth = (params.config.effectiveWidthMm * 8.0).toInt();
      } else {
        // ESC/POS cho máy in receipt (K80: 576 dots, K57: 384 dots)
        if (params.config.effectiveWidthMm > 0 && params.config.effectiveWidthMm <= 60) {
          targetWidth = 384;
        } else {
          targetWidth = 576;
        }
      }
      
      int targetHeight;
      if (params.config.paperType == PaperType.continuous) {
        targetHeight = (targetWidth * aspectRatio).round();
      } else {
        // Giấy nhãn có chiều cao cố định
        final maxLabelHeightDots = (params.config.effectiveHeightMm * 8.0).toInt();
        
        if (params.config.scalingMode == ScalingMode.fitHeight) {
          targetHeight = maxLabelHeightDots;
          targetWidth = (targetHeight / aspectRatio).round();
        } else if (params.config.scalingMode == ScalingMode.custom) {
          final scaleFactor = params.config.scalingValue / 100.0;
          targetWidth = (targetWidth * scaleFactor).round();
          targetHeight = (targetWidth * aspectRatio).round();
        } else {
          // fitWidth (mặc định)
          targetWidth = targetWidth;
          targetHeight = (targetWidth * aspectRatio).round();
          if (targetHeight > maxLabelHeightDots) {
            targetHeight = maxLabelHeightDots;
            targetWidth = (targetHeight / aspectRatio).round();
          }
        }
      }

      // Đảm bảo chiều rộng chia hết cho 8 (yêu cầu bắt buộc đối với máy in nhiệt để không bị lệch cột/lệch bit)
      targetWidth = ((targetWidth + 7) ~/ 8) * 8;
      if (targetWidth < 8) targetWidth = 8;
      if (targetHeight < 8) targetHeight = 8;

      // Decode lại với kích thước đích tối ưu
      final codec = await ui.instantiateImageCodec(
        params.previewBytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      
      if (byteData == null) {
        return const Left(PrinterFailure(message: 'Không thể decode dữ liệu hình ảnh preview'));
      }
      
      Uint8List rgbaBytes = byteData.buffer.asUint8List();
      int imageWidth = uiImage.width;
      int imageHeight = uiImage.height;

      // 3. Xoay hình ảnh dựa trên tham số rotation (0, 90, 180, 270)
      if (params.rotation == 90) {
        rgbaBytes = ImageUtils.rotateRgba90(rgbaBytes, imageWidth, imageHeight);
        final temp = imageWidth;
        imageWidth = imageHeight;
        imageHeight = temp;
      } else if (params.rotation == 180) {
        rgbaBytes = ImageUtils.rotateRgba180(rgbaBytes, imageWidth, imageHeight);
      } else if (params.rotation == 270) {
        rgbaBytes = ImageUtils.rotateRgba270(rgbaBytes, imageWidth, imageHeight);
        final temp = imageWidth;
        imageWidth = imageHeight;
        imageHeight = temp;
      }

      // 4. Tạo lịch sử PrintJob (trạng thái PENDING)
      final printJob = PrintJob(
        printerId: printer.id!,
        jobName: params.jobName,
        documentType: params.documentType,
        copies: params.copies,
        status: JobStatus.pending,
      );
      
      final jobResult = await printJobRepository.createJob(printJob);
      jobId = jobResult.fold((l) => null, (r) => r);

      // 5. Sinh tập lệnh in dựa trên protocol của máy in
      final Uint8List printBytes;
      if (printer.protocol == PrinterProtocol.tspl) {
        // Tính toán tọa độ bù lề (margin) theo đơn vị dot (8 dots/mm cho 203 DPI)
        final xDots = (params.config.marginLeft * 8).toInt();
        final yDots = (params.config.marginTop * 8).toInt();

        int printHeightMm = params.config.effectiveHeightMm;
        if (params.config.paperType == PaperType.continuous) {
          final double aspectRatio = imageHeight / imageWidth;
          printHeightMm = (params.config.effectiveWidthMm * aspectRatio).round();
        }

        printBytes = TsplGenerator.generatePrintJob(
          widthMm: params.config.effectiveWidthMm,
          heightMm: printHeightMm,
          darkness: params.config.printDarkness,
          speed: params.config.printSpeed,
          rgbaBytes: rgbaBytes,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          useDithering: params.documentType != DocumentType.barcode, // Barcode dùng binarization, PDF/Ảnh dùng dithering
          xDots: xDots,
          yDots: yDots,
          paperType: params.config.paperType,
          labelGap: params.config.labelGap,
          copies: params.copies,
        );
      } else {
        // ESC/POS cho máy in receipt
        printBytes = EscPosGenerator.generatePrintJob(
          rgbaBytes: rgbaBytes,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          useDithering: params.documentType != DocumentType.barcode,
        );
      }

      // 6. Gửi bytes lệnh in tới máy in
      if (printer.protocol == PrinterProtocol.tspl) {
        await PrinterSender.send(printer: printer, bytes: printBytes);
      } else {
        // ESC/POS: lặp lại mảng bytes copies lần trong 1 luồng gửi duy nhất
        final bytesBuilder = BytesBuilder();
        for (int i = 0; i < params.copies; i++) {
          bytesBuilder.add(printBytes);
        }
        await PrinterSender.send(printer: printer, bytes: bytesBuilder.toBytes());
      }

      // 7. Cập nhật trạng thái PrintJob thành SUCCESS
      if (jobId != null) {
        await printJobRepository.updateJobStatus(jobId, JobStatus.success);
      }

      return const Right(null);
    } catch (e) {
      // Cập nhật trạng thái PrintJob thành FAILED nếu gặp lỗi
      if (jobId != null) {
        await printJobRepository.updateJobStatus(jobId, JobStatus.failed);
      }
      return Left(PrinterFailure(message: e.toString()));
    }
  }
}

/// Tham số truyền vào Usecase PrintDocument
class PrintDocumentParams extends Equatable {
  final DocumentType documentType;
  final String jobName;
  final Uint8List previewBytes;
  final PrinterConfig config;
  final int copies;
  final int rotation;

  const PrintDocumentParams({
    required this.documentType,
    required this.jobName,
    required this.previewBytes,
    required this.config,
    this.copies = 1,
    this.rotation = 0,
  });

  @override
  List<Object?> get props => [
        documentType,
        jobName,
        previewBytes,
        config,
        copies,
        rotation,
      ];
}
