import 'dart:typed_data';
import 'package:barcode/barcode.dart' as bc_lib;
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/image_utils.dart';
import '../../entities/enums/barcode_type.dart';
import '../usecase.dart';

/// Usecase sinh ảnh mã vạch dưới dạng mảng bytes PNG từ dữ liệu văn bản.
///
/// Thực hiện kiểm tra tính hợp lệ của dữ liệu trước khi sinh.
class GenerateBarcode implements UseCase<Uint8List, GenerateBarcodeParams> {
  @override
  Future<Either<Failure, Uint8List>> call(GenerateBarcodeParams params) async {
    try {
      // 1. Kiểm tra validation tương ứng từng loại barcode
      final validationError = _validateData(params.data, params.type);
      if (validationError != null) {
        return Left(ValidationFailure(message: validationError));
      }

      // 2. Map BarcodeType từ Domain sang Barcode class của package barcode
      final bc_lib.Barcode barcode;
      switch (params.type) {
        case BarcodeType.code128:
          barcode = bc_lib.Barcode.code128();
          break;
        case BarcodeType.ean13:
          barcode = bc_lib.Barcode.ean13();
          break;
        case BarcodeType.ean8:
          barcode = bc_lib.Barcode.ean8();
          break;
        case BarcodeType.upcA:
          barcode = bc_lib.Barcode.upcA();
          break;
      }

      // 3. Sinh ảnh bằng ImageUtils (tạm định nghĩa chiều rộng tỷ lệ theo chiều cao)
      // Thường mã vạch 1D có chiều rộng gấp 2.5 - 3 lần chiều cao.
      final double width = params.height * 3.0;

      final bytes = await ImageUtils.generateBarcodeBytes(
        data: params.data,
        barcodeType: barcode,
        width: width,
        height: params.height,
        showText: params.showText,
      );

      return Right(bytes);
    } catch (e) {
      return Left(PrinterFailure(message: e.toString()));
    }
  }

  /// Kiểm tra dữ liệu nhập vào có khớp với đặc tả của loại mã vạch đó hay không.
  String? _validateData(String data, BarcodeType type) {
    if (data.isEmpty) {
      return 'Nội dung mã vạch không được để trống';
    }

    switch (type) {
      case BarcodeType.ean13:
        if (data.length != 13 || int.tryParse(data) == null) {
          return 'Mã vạch EAN-13 phải chứa đúng 13 chữ số';
        }
        break;
      case BarcodeType.ean8:
        if (data.length != 8 || int.tryParse(data) == null) {
          return 'Mã vạch EAN-8 phải chứa đúng 8 chữ số';
        }
        break;
      case BarcodeType.upcA:
        if (data.length != 12 || int.tryParse(data) == null) {
          return 'Mã vạch UPC-A phải chứa đúng 12 chữ số';
        }
        break;
      case BarcodeType.code128:
        // Chấp nhận các ký tự ASCII in ra được
        final asciiRegex = RegExp(r'^[\x20-\x7F]*$');
        if (!asciiRegex.hasMatch(data)) {
          return 'Mã vạch Code-128 chỉ chấp nhận các ký tự chữ, số không dấu trong bảng mã ASCII';
        }
        break;
    }
    return null;
  }
}

/// Tham số truyền vào Usecase GenerateBarcode
class GenerateBarcodeParams extends Equatable {
  final String data;
  final BarcodeType type;
  final double height;
  final bool showText;

  const GenerateBarcodeParams({
    required this.data,
    required this.type,
    this.height = 100.0,
    this.showText = true,
  });

  @override
  List<Object?> get props => [data, type, height, showText];
}
