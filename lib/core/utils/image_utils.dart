import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:barcode/barcode.dart' as bc_lib;
import 'package:flutter/material.dart';

import '../../domain/entities/printer_config.dart';

/// Các hàm tiện ích xử lý hình ảnh, bao gồm sinh mã vạch, nhị phân hóa ảnh,
/// thuật toán Floyd-Steinberg Dithering và convert ảnh sang bitmap 1-bit cho máy in nhiệt.
class ImageUtils {
  /// Sinh hình ảnh mã vạch dưới dạng [Uint8List] chứa định dạng PNG.
  ///
  /// Sử dụng package `barcode` để tính toán tọa độ và vẽ mã vạch lên [ui.Canvas].
  static Future<Uint8List> generateBarcodeBytes({
    required String data,
    required bc_lib.Barcode barcodeType,
    required double width,
    required double height,
    required bool showText,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width, height),
    );

    // Vẽ nền trắng
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Vẽ các thanh mã vạch
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Lấy các element vẽ mã vạch từ thư viện barcode
    // Định nghĩa khung vẽ cho mã vạch
    final barcodeWidth = width;
    final barcodeHeight = showText ? height * 0.75 : height;

    // make trả về danh sách các thanh (bar) và chữ (nếu có)
    final recipe = barcodeType.make(
      data,
      width: barcodeWidth,
      height: barcodeHeight,
    );

    for (final element in recipe) {
      if (element is bc_lib.BarcodeBar) {
        if (element.black) {
          canvas.drawRect(
            Rect.fromLTWH(
              element.left,
              element.top,
              element.width,
              element.height,
            ),
            paint,
          );
        }
      }
    }

    // Vẽ text số bên dưới nếu yêu cầu
    if (showText) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: data,
          style: TextStyle(
            color: Colors.black,
            fontSize: height * 0.15,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(
        minWidth: 0,
        maxWidth: width,
      );

      // Căn giữa text ở khoảng 15% chiều cao cuối cùng
      final textX = (width - textPainter.width) / 2;
      final textY = height * 0.82;
      textPainter.paint(canvas, Offset(textX, textY));
    }

    // Kết thúc vẽ và tạo Image
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Không thể tạo byte data từ ảnh mã vạch');
    }

    return byteData.buffer.asUint8List();
  }

  /// Thuật toán Binarization đơn giản (Ngưỡng cố định 128)
  ///
  /// Nhận vào mảng bytes RGBA, trả về mảng bytes đen trắng (1-bit trên mỗi pixel).
  /// Trong mảng kết quả, mỗi byte chứa 8 pixel: bit 1 là màu trắng, bit 0 là màu đen.
  static Uint8List binarizeToMonochrome(Uint8List rgbaBytes, int width, int height) {
    final byteWidth = (width + 7) ~/ 8; // Số byte trên mỗi dòng
    final monochromeBytes = Uint8List(byteWidth * height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixelIndex = (y * width + x) * 4;
        
        // Tính độ sáng (luminance) theo hệ số chuẩn BT.601
        final r = rgbaBytes[pixelIndex];
        final g = rgbaBytes[pixelIndex + 1];
        final b = rgbaBytes[pixelIndex + 2];
        final a = rgbaBytes[pixelIndex + 3];

        final double luminance;
        if (a < 128) {
          // Pixel trong suốt coi như màu trắng (1)
          luminance = 255;
        } else {
          luminance = 0.299 * r + 0.587 * g + 0.114 * b;
        }

        // Ngưỡng 128 để phân biệt đen/trắng
        final isWhite = luminance >= 128;

        // Điền bit vào byte tương ứng
        final targetByteIndex = y * byteWidth + (x ~/ 8);
        final bitOffset = 7 - (x % 8);

        if (isWhite) {
          // Đặt bit đó thành 1 (màu trắng)
          monochromeBytes[targetByteIndex] |= (1 << bitOffset);
        } else {
          // Đặt bit đó thành 0 (màu đen)
          monochromeBytes[targetByteIndex] &= ~(1 << bitOffset);
        }
      }
    }

    return monochromeBytes;
  }

  /// Thuật toán Floyd-Steinberg Dithering cho hình ảnh mượt mà hơn khi in nhiệt.
  ///
  /// Nhận vào mảng bytes RGBA, áp dụng thuật toán lan truyền sai số và trả về mảng bytes nhị phân 1-bit.
  static Uint8List ditherToMonochrome(Uint8List rgbaBytes, int width, int height) {
    // Để dithering dễ dàng, convert sang mảng mức xám (grayscale) 2 chiều
    final gray = List<double>.generate(width * height, (index) {
      final pixelIndex = index * 4;
      final r = rgbaBytes[pixelIndex];
      final g = rgbaBytes[pixelIndex + 1];
      final b = rgbaBytes[pixelIndex + 2];
      final a = rgbaBytes[pixelIndex + 3];

      if (a < 128) return 255.0; // Trong suốt là màu trắng
      return 0.299 * r + 0.587 * g + 0.114 * b;
    });

    final byteWidth = (width + 7) ~/ 8;
    final monochromeBytes = Uint8List(byteWidth * height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final currentIdx = y * width + x;
        final oldPixel = gray[currentIdx];
        final newPixel = oldPixel < 128 ? 0.0 : 255.0;
        
        // Lưu giá trị vào bitmap 1-bit
        final targetByteIndex = y * byteWidth + (x ~/ 8);
        final bitOffset = 7 - (x % 8);
        
        if (newPixel >= 128) {
          monochromeBytes[targetByteIndex] |= (1 << bitOffset);
        } else {
          monochromeBytes[targetByteIndex] &= ~(1 << bitOffset);
        }

        // Tính sai số
        final error = oldPixel - newPixel;

        // Lan truyền sai số cho các pixel lân cận theo ma trận Floyd-Steinberg:
        //      *   7/16
        // 3/16 5/16 1/16
        if (x + 1 < width) {
          gray[currentIdx + 1] += error * 7 / 16;
        }
        if (y + 1 < height) {
          if (x - 1 >= 0) {
            gray[currentIdx + width - 1] += error * 3 / 16;
          }
          gray[currentIdx + width] += error * 5 / 16;
          if (x + 1 < width) {
            gray[currentIdx + width + 1] += error * 1 / 16;
          }
        }
      }
    }

    return monochromeBytes;
  }

  /// Xoay hình ảnh RGBA (32-bit) góc 90 độ theo chiều kim đồng hồ.
  ///
  /// Kích thước của ảnh xoay sẽ được hoán đổi: chiều rộng mới bằng chiều cao cũ,
  /// và chiều cao mới bằng chiều rộng cũ.
  static Uint8List rotateRgba90(Uint8List rgbaBytes, int width, int height) {
    final rotated = Uint8List(rgbaBytes.length);
    final newWidth = height;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final oldIdx = (y * width + x) * 4;
        final newX = height - 1 - y;
        final newY = x;
        final newIdx = (newY * newWidth + newX) * 4;
        
        rotated[newIdx] = rgbaBytes[oldIdx];         // R
        rotated[newIdx + 1] = rgbaBytes[oldIdx + 1]; // G
        rotated[newIdx + 2] = rgbaBytes[oldIdx + 2]; // B
        rotated[newIdx + 3] = rgbaBytes[oldIdx + 3]; // A
      }
    }
    return rotated;
  }

  /// Xoay hình ảnh RGBA (32-bit) góc 180 độ.
  static Uint8List rotateRgba180(Uint8List rgbaBytes, int width, int height) {
    final rotated = Uint8List(rgbaBytes.length);
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final oldIdx = (y * width + x) * 4;
        final newX = width - 1 - x;
        final newY = height - 1 - y;
        final newIdx = (newY * width + newX) * 4;
        
        rotated[newIdx] = rgbaBytes[oldIdx];
        rotated[newIdx + 1] = rgbaBytes[oldIdx + 1];
        rotated[newIdx + 2] = rgbaBytes[oldIdx + 2];
        rotated[newIdx + 3] = rgbaBytes[oldIdx + 3];
      }
    }
    return rotated;
  }

  /// Xoay hình ảnh RGBA (32-bit) góc 270 độ.
  static Uint8List rotateRgba270(Uint8List rgbaBytes, int width, int height) {
    final rotated = Uint8List(rgbaBytes.length);
    final newWidth = height;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final oldIdx = (y * width + x) * 4;
        final newX = y;
        final newY = width - 1 - x;
        final newIdx = (newY * newWidth + newX) * 4;
        
        rotated[newIdx] = rgbaBytes[oldIdx];
        rotated[newIdx + 1] = rgbaBytes[oldIdx + 1];
        rotated[newIdx + 2] = rgbaBytes[oldIdx + 2];
        rotated[newIdx + 3] = rgbaBytes[oldIdx + 3];
      }
    }
    return rotated;
  }

  /// Sinh hình ảnh phiếu giao hàng dưới dạng [Uint8List] chứa định dạng PNG.
  static Future<Uint8List> generateDeliveryNoteBytes({
    required Map<String, dynamic> deliveryNoteData,
    required PrinterConfig config,
  }) async {
    final String code = deliveryNoteData['code'] as String? ?? '';
    final String sender = deliveryNoteData['sender'] as String? ?? '';
    final String receiver = deliveryNoteData['receiver'] as String? ?? '';
    final List<dynamic> rawItems = deliveryNoteData['items'] as List<dynamic>? ?? [];

    // Lấy kích thước giấy in (mặc định A7 74x105 mm nếu chưa chỉ định)
    final double widthMm = config.effectiveWidthMm > 0 ? config.effectiveWidthMm.toDouble() : 74.0;
    final double heightMm = config.effectiveHeightMm > 0 ? config.effectiveHeightMm.toDouble() : 105.0;

    // Quy đổi từ mm sang pixels (8 dots/mm cho độ phân giải 203 DPI)
    final double pxWidth = widthMm * 8.0;
    final double pxHeight = heightMm * 8.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, pxWidth, pxHeight),
    );

    // 1. Vẽ nền trắng
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, pxWidth, pxHeight), bgPaint);

    final double margin = pxWidth * 0.04; // Lề tương đối 4%
    final double contentWidth = pxWidth - (margin * 2);
    double currentY = margin;

    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dividerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 2. Tiêu đề Phiếu Giao Hàng
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'PHIẾU GIAO HÀNG\nDELIVERY NOTE',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout(maxWidth: contentWidth);
    titlePainter.paint(canvas, Offset(margin + (contentWidth - titlePainter.width) / 2, currentY));
    currentY += titlePainter.height + 12.0;

    // 3. Số phiếu
    if (code.isNotEmpty) {
      final codePainter = TextPainter(
        text: TextSpan(
          text: 'Số phiếu / No: $code',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      codePainter.layout(maxWidth: contentWidth);
      codePainter.paint(canvas, Offset(margin + (contentWidth - codePainter.width) / 2, currentY));
      currentY += codePainter.height + 16.0;
    }

    // Đường kẻ phân cách phần header
    canvas.drawLine(Offset(margin, currentY), Offset(margin + contentWidth, currentY), blackPaint);
    currentY += 12.0;

    // 4. Thông tin Người gửi / Người nhận
    const infoStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      height: 1.3,
    );

    if (sender.isNotEmpty) {
      final senderPainter = TextPainter(
        text: TextSpan(
          text: 'Người gửi / Sender: $sender',
          style: infoStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      senderPainter.layout(maxWidth: contentWidth);
      senderPainter.paint(canvas, Offset(margin, currentY));
      currentY += senderPainter.height + 8.0;
    }

    if (receiver.isNotEmpty) {
      final receiverPainter = TextPainter(
        text: TextSpan(
          text: 'Người nhận / Receiver: $receiver',
          style: infoStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      receiverPainter.layout(maxWidth: contentWidth);
      receiverPainter.paint(canvas, Offset(margin, currentY));
      currentY += receiverPainter.height + 16.0;
    }

    // 5. Bảng danh sách sản phẩm
    final col1Width = contentWidth * 0.55;
    final col2Width = contentWidth * 0.20;
    final col3Width = contentWidth * 0.25;

    final col1X = margin;
    final col2X = margin + col1Width;
    final col3X = margin + col1Width + col2Width;

    const headerStyle = TextStyle(
      color: Colors.black,
      fontSize: 13,
      fontWeight: FontWeight.bold,
    );

    final col1Header = TextPainter(
      text: const TextSpan(text: 'Sản phẩm / Item', style: headerStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: col1Width);

    final col2Header = TextPainter(
      text: const TextSpan(text: 'SL / Qty', style: headerStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: col2Width);

    final col3Header = TextPainter(
      text: const TextSpan(text: 'ĐVT / Unit', style: headerStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: col3Width);

    canvas.drawLine(Offset(margin, currentY), Offset(margin + contentWidth, currentY), blackPaint);
    currentY += 6.0;

    col1Header.paint(canvas, Offset(col1X, currentY));
    col2Header.paint(canvas, Offset(col2X + (col2Width - col2Header.width) / 2, currentY));
    col3Header.paint(canvas, Offset(col3X + (col3Width - col3Header.width) / 2, currentY));

    currentY += col1Header.height + 6.0;
    canvas.drawLine(Offset(margin, currentY), Offset(margin + contentWidth, currentY), blackPaint);
    currentY += 8.0;

    const itemStyle = TextStyle(
      color: Colors.black,
      fontSize: 13,
      height: 1.2,
    );

    int totalQty = 0;

    if (rawItems.isEmpty) {
      final noItemsPainter = TextPainter(
        text: const TextSpan(
          text: '(Không có sản phẩm / No items)',
          style: TextStyle(color: Colors.black, fontSize: 13, fontStyle: FontStyle.italic),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: contentWidth);
      noItemsPainter.paint(canvas, Offset(margin, currentY));
      currentY += noItemsPainter.height + 8.0;
    } else {
      for (var item in rawItems) {
        final String name = item['name'] as String? ?? '';
        final int qty = (item['quantity'] as num?)?.toInt() ?? 0;
        final String unit = item['unit'] as String? ?? '';
        totalQty += qty;

        final namePainter = TextPainter(
          text: TextSpan(text: name, style: itemStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: col1Width - 8.0);

        final qtyPainter = TextPainter(
          text: TextSpan(text: '$qty', style: itemStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: col2Width);

        final unitPainter = TextPainter(
          text: TextSpan(text: unit, style: itemStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: col3Width);

        final double rowHeight = namePainter.height;

        namePainter.paint(canvas, Offset(col1X, currentY));
        qtyPainter.paint(canvas, Offset(col2X + (col2Width - qtyPainter.width) / 2, currentY));
        unitPainter.paint(canvas, Offset(col3X + (col3Width - unitPainter.width) / 2, currentY));

        currentY += rowHeight + 8.0;
        canvas.drawLine(Offset(margin, currentY), Offset(margin + contentWidth, currentY), dividerPaint);
        currentY += 8.0;
      }
    }

    // 6. Tổng số lượng
    final totalPainter = TextPainter(
      text: TextSpan(
        text: 'Tổng số lượng / Total Qty: $totalQty',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: contentWidth);
    
    totalPainter.paint(canvas, Offset(margin, currentY));
    currentY += totalPainter.height + 24.0;

    // 7. Khu vực chữ ký xác nhận
    double signatureY = pxHeight - margin - 80.0;
    if (currentY > signatureY) {
      signatureY = currentY + 16.0;
    }

    const sigStyle = TextStyle(
      color: Colors.black,
      fontSize: 13,
      fontWeight: FontWeight.bold,
      height: 1.2,
    );
    const sigSubStyle = TextStyle(
      color: Colors.black,
      fontSize: 11,
      fontStyle: FontStyle.italic,
    );

    final receiverSig = TextPainter(
      text: const TextSpan(text: 'Người nhận hàng\n(Receiver)', style: sigStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: contentWidth / 2);

    final receiverSubSig = TextPainter(
      text: const TextSpan(text: '(Ký, ghi rõ họ tên)', style: sigSubStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: contentWidth / 2);

    final delivererSig = TextPainter(
      text: const TextSpan(text: 'Người giao hàng\n(Deliverer)', style: sigStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: contentWidth / 2);

    final delivererSubSig = TextPainter(
      text: const TextSpan(text: '(Ký, ghi rõ họ tên)', style: sigSubStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: contentWidth / 2);

    final leftColX = margin;
    final rightColX = margin + contentWidth / 2;

    receiverSig.paint(canvas, Offset(leftColX + (contentWidth / 2 - receiverSig.width) / 2, signatureY));
    receiverSubSig.paint(canvas, Offset(leftColX + (contentWidth / 2 - receiverSubSig.width) / 2, signatureY + receiverSig.height + 4.0));

    delivererSig.paint(canvas, Offset(rightColX + (contentWidth / 2 - delivererSig.width) / 2, signatureY));
    delivererSubSig.paint(canvas, Offset(rightColX + (contentWidth / 2 - delivererSubSig.width) / 2, signatureY + delivererSig.height + 4.0));

    // Kết thúc vẽ và tạo Image
    final picture = recorder.endRecording();
    // Tạo image với kích thước an toàn chẵn số
    final img = await picture.toImage(pxWidth.toInt(), (signatureY + receiverSig.height + receiverSubSig.height + margin + 20).toInt().clamp(pxHeight.toInt(), 5000));
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Không thể tạo byte data từ ảnh phiếu giao hàng');
    }

    return byteData.buffer.asUint8List();
  }
}


