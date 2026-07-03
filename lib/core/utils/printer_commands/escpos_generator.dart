import 'dart:typed_data';

import '../../errors/exceptions.dart';
import '../image_utils.dart';

/// Lớp sinh tập lệnh in ESC/POS (dành cho máy in hóa đơn/in receipt).
class EscPosGenerator {
  /// Sinh mảng byte lệnh ESC/POS để in một hình ảnh RGBA
  ///
  /// [rgbaBytes]: Dữ liệu byte ảnh RGBA (32-bit)
  /// [imageWidth]: Chiều rộng ảnh (pixels) - Thường máy in K80 là 576 pixels, K57 là 384 pixels
  /// [imageHeight]: Chiều cao ảnh (pixels)
  /// [useDithering]: Áp dụng Floyd-Steinberg dithering nếu true
  static Uint8List generatePrintJob({
    required Uint8List rgbaBytes,
    required int imageWidth,
    required int imageHeight,
    bool useDithering = true,
  }) {
    if (rgbaBytes.length != imageWidth * imageHeight * 4) {
      throw PrinterException(
        code: 'errConnectionFailed',
        message: 'Kích thước ảnh không khớp với mảng bytes RGBA',
      );
    }

    final List<int> bytesBuilder = [];

    // 1. Khởi tạo máy in (Initialize Printer: ESC @)
    bytesBuilder.addAll([0x1B, 0x40]);

    // 2. Chuyển đổi ảnh sang monochrome bitmap 1-bit
    final Uint8List monoBytes;
    if (useDithering) {
      monoBytes = ImageUtils.ditherToMonochrome(rgbaBytes, imageWidth, imageHeight);
    } else {
      monoBytes = ImageUtils.binarizeToMonochrome(rgbaBytes, imageWidth, imageHeight);
    }

    // 3. Đảo ngược bit (Invert bits) vì ESC/POS quy định: 1 là ĐEN, 0 là TRẮNG.
    // Trong khi ImageUtils sinh ra: 1 là TRẮNG, 0 là ĐEN.
    final invertedBytes = Uint8List(monoBytes.length);
    for (int i = 0; i < monoBytes.length; i++) {
      invertedBytes[i] = monoBytes[i] ^ 0xFF;
    }

    // 4. Tạo lệnh in ảnh Raster (GS v 0 m xL xH yL yH d1...dk)
    final int widthBytes = (imageWidth + 7) ~/ 8;
    final int xL = widthBytes % 256;
    final int xH = widthBytes ~/ 256;
    final int yL = imageHeight % 256;
    final int yH = imageHeight ~/ 256;

    bytesBuilder.addAll([
      0x1D, 0x76, 0x30, 0x00, // GS v 0 0 (mode normal)
      xL, xH,
      yL, yH,
    ]);

    // Nối dữ liệu ảnh đã đảo bit
    bytesBuilder.addAll(invertedBytes);

    // 5. Kéo giấy và Cắt giấy (Feed & Cut)
    bytesBuilder.addAll([
      0x1B, 0x64, 0x03, // ESC d 3 (Feed 3 lines)
      0x1D, 0x56, 0x42, 0x00, // GS V 66 0 (Feed and partial cut)
    ]);

    return Uint8List.fromList(bytesBuilder);
  }
}
