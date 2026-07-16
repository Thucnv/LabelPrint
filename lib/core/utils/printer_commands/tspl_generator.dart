import 'dart:convert';
import 'dart:typed_data';

import '../../errors/exceptions.dart';
import '../image_utils.dart';
import '../../../domain/entities/enums/print_enums.dart';

/// Lớp sinh tập lệnh in TSPL (dành cho máy in nhãn chuyên dụng).
class TsplGenerator {
  /// Sinh mảng byte lệnh TSPL để in một hình ảnh RGBA
  ///
  /// [widthMm]: Chiều rộng nhãn (mm)
  /// [heightMm]: Chiều cao nhãn (mm)
  /// [darkness]: Độ đậm in (1 - 15)
  /// [speed]: Tốc độ in (1.5 - 6.0 ips)
  /// [rgbaBytes]: Dữ liệu byte ảnh RGBA (32-bit)
  /// [imageWidth]: Chiều rộng ảnh (pixels)
  /// [imageHeight]: Chiều cao ảnh (pixels)
  /// [useDithering]: Áp dụng Floyd-Steinberg dithering nếu true, ngược lại dùng binarize thường.
  static Uint8List generatePrintJob({
    required int widthMm,
    required int heightMm,
    required int darkness,
    required double speed,
    required Uint8List rgbaBytes,
    required int imageWidth,
    required int imageHeight,
    bool useDithering = true,
    int xDots = 0,
    int yDots = 0,
    PaperType paperType = PaperType.label,
    double labelGap = 0.0,
    int copies = 1,
  }) {
    if (rgbaBytes.length != imageWidth * imageHeight * 4) {
      throw PrinterException(
        code: 'errInvalidImageData',
        message: 'Kích thước ảnh không khớp với mảng bytes RGBA',
      );
    }

    final List<int> bytesBuilder = [];

    // 1. Gửi lệnh cấu hình định dạng văn bản
    // SIZE w mm, h mm
    // GAP g mm, 0 mm / BLINE g mm, 0 mm / GAP 0,0
    // SPEED s
    // DENSITY d
    // DIRECTION 0
    // CLS (Xóa bộ đệm)
    final String gapCmd;
    if (paperType == PaperType.continuous) {
      gapCmd = 'GAP 0,0\r\n';
    } else if (paperType == PaperType.blackMark) {
      final gapValue = labelGap > 0 ? labelGap : 3.0;
      gapCmd = 'BLINE $gapValue mm, 0 mm\r\n';
    } else {
      final gapValue = labelGap > 0 ? labelGap : 3.0;
      gapCmd = 'GAP $gapValue mm, 0 mm\r\n';
    }

    final setupString = 'SIZE $widthMm mm, $heightMm mm\r\n'
        '$gapCmd'
        'SPEED $speed\r\n'
        'DENSITY $darkness\r\n'
        'DIRECTION 0\r\n'
        'CLS\r\n';
    bytesBuilder.addAll(utf8.encode(setupString));

    // 2. Chuyển đổi ảnh sang monochrome bitmap 1-bit
    final Uint8List monoBytes;
    if (useDithering) {
      monoBytes = ImageUtils.ditherToMonochrome(rgbaBytes, imageWidth, imageHeight);
    } else {
      monoBytes = ImageUtils.binarizeToMonochrome(rgbaBytes, imageWidth, imageHeight);
    }

    // 3. Tạo lệnh BITMAP
    // BITMAP X, Y, width_bytes, height_pixels, mode, data
    final int widthBytes = (imageWidth + 7) ~/ 8;
    final bitmapHeader = 'BITMAP $xDots,$yDots,$widthBytes,$imageHeight,0,';
    bytesBuilder.addAll(utf8.encode(bitmapHeader));
    
    // Nối dữ liệu bitmap nhị phân trực tiếp
    bytesBuilder.addAll(monoBytes);
    
    // Gửi ký tự xuống dòng sau dữ liệu bitmap
    bytesBuilder.addAll(utf8.encode('\r\n'));

    // 4. Lệnh PRINT copies, [options]
    final feedCmd = paperType == PaperType.continuous ? 'FEED 80\r\n' : '';
    final printString = 'PRINT $copies,1\r\n'
        'SOUND 2,50\r\n'
        '$feedCmd';
    bytesBuilder.addAll(utf8.encode(printString));

    return Uint8List.fromList(bytesBuilder);
  }
}
