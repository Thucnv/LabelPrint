import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/printer_commands/escpos_generator.dart';
import '../../../core/utils/printer_commands/tspl_generator.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/utils/printer_sender.dart';
import '../../entities/enums/barcode_type.dart';
import '../../entities/enums/print_enums.dart';
import '../../entities/enums/printer_enums.dart';
import '../../entities/print_job.dart';
import '../../entities/printer.dart';
import '../../entities/printer_config.dart';
import '../../repositories/config_repository.dart';
import '../../repositories/print_job_repository.dart';
import '../../repositories/printer_repository.dart';
import '../usecase.dart';
import 'generate_barcode.dart';

/// Usecase thực hiện in mã vạch: Lấy máy in mặc định, sinh ảnh mã vạch, chuyển đổi sang mã lệnh in tương ứng và gửi đi.
class PrintBarcode implements UseCase<void, PrintBarcodeParams> {
  final PrinterRepository printerRepository;
  final ConfigRepository configRepository;
  final PrintJobRepository printJobRepository;
  final GenerateBarcode generateBarcode;

  PrintBarcode({
    required this.printerRepository,
    required this.configRepository,
    required this.printJobRepository,
    required this.generateBarcode,
  });

  @override
  Future<Either<Failure, void>> call(PrintBarcodeParams params) async {
    int? jobId;
    try {
      // 1. Lấy thông tin máy in mặc định
      final printerResult = await printerRepository.getDefaultPrinter();
      if (printerResult.isLeft()) {
        return Left(printerResult.fold((l) => l, (r) => throw Exception()));
      }

      final Printer? printer = printerResult.fold((l) => null, (r) => r);
      if (printer == null) {
        return Left(PrinterFailure(message: 'Chưa cấu hình máy in mặc định'));
      }

      // 2. Lấy cấu hình của máy in đó
      final configResult = await configRepository.getConfigByPrinterId(printer.id!);
      PrinterConfig config = PrinterConfig(printerId: printer.id!);
      configResult.fold(
        (l) => null,
        (PrinterConfig? r) {
          if (r != null) config = r;
        },
      );

      // 3. Sinh ảnh mã vạch (dạng bytes PNG)
      final barcodeResult = await generateBarcode(GenerateBarcodeParams(
        data: params.data,
        type: params.type,
        height: params.height,
        showText: params.showText,
      ));

      if (barcodeResult.isLeft()) {
        return Left(barcodeResult.fold((l) => l, (r) => throw Exception()));
      }

      final pngBytes = barcodeResult.fold((l) => null, (r) => r)!;

      // Decode PNG thành raw RGBA bytes của Flutter để binarize
      final codec = await ui.instantiateImageCodec(pngBytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      
      if (byteData == null) {
        return Left(PrinterFailure(message: 'Không thể decode dữ liệu hình ảnh mã vạch'));
      }
      Uint8List rgbaBytes = byteData.buffer.asUint8List();
      int imageWidth = uiImage.width;
      int imageHeight = uiImage.height;

      // Xoay hình ảnh 90 độ nếu hướng in là landscape (ngang)
      if (config.orientation == Orientation.landscape) {
        rgbaBytes = ImageUtils.rotateRgba90(rgbaBytes, imageWidth, imageHeight);
        final temp = imageWidth;
        imageWidth = imageHeight;
        imageHeight = temp;
      }

      // 4. Tạo PrintJob lịch sử (trạng thái PENDING)
      final printJob = PrintJob(
        printerId: printer.id!,
        jobName: 'In mã vạch: ${params.data}',
        documentType: DocumentType.barcode,
        copies: 1,
        status: JobStatus.pending,
      );
      
      final jobResult = await printJobRepository.createJob(printJob);
      jobId = jobResult.fold((l) => null, (r) => r);

      // 5. Sinh tập lệnh in
      final Uint8List printBytes;
      if (printer.protocol == PrinterProtocol.tspl) {
        printBytes = TsplGenerator.generatePrintJob(
          widthMm: config.effectiveWidthMm,
          heightMm: config.effectiveHeightMm,
          darkness: config.printDarkness,
          speed: config.printSpeed,
          rgbaBytes: rgbaBytes,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          useDithering: false, // In mã vạch không nên dùng dithering vì làm mờ vạch, dùng binarization
          paperType: config.paperType,
          labelGap: config.labelGap,
        );
      } else {
        printBytes = EscPosGenerator.generatePrintJob(
          rgbaBytes: rgbaBytes,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          useDithering: false,
        );
      }

      // 6. Gửi bytes lệnh in tới máy in
      await PrinterSender.send(printer: printer, bytes: printBytes);

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

/// Tham số truyền vào Usecase PrintBarcode
class PrintBarcodeParams extends Equatable {
  final String data;
  final BarcodeType type;
  final double height;
  final bool showText;

  const PrintBarcodeParams({
    required this.data,
    required this.type,
    this.height = 80.0,
    this.showText = true,
  });

  @override
  List<Object?> get props => [data, type, height, showText];
}
