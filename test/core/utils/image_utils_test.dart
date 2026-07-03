import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:label_print/core/utils/image_utils.dart';
import 'package:label_print/domain/entities/printer_config.dart';

void main() {
  test('ImageUtils.rotateRgba90 rotates a 2x3 image correctly', () {
    // 2x3 image with 4 bytes per pixel (RGBA)
    final original = Uint8List.fromList([
      1, 1, 1, 1,   2, 2, 2, 2,
      3, 3, 3, 3,   4, 4, 4, 4,
      5, 5, 5, 5,   6, 6, 6, 6,
    ]);

    // Rotated 90 degrees clockwise should be 3x2:
    final expected = Uint8List.fromList([
      5, 5, 5, 5,   3, 3, 3, 3,   1, 1, 1, 1,
      6, 6, 6, 6,   4, 4, 4, 4,   2, 2, 2, 2,
    ]);

    final result = ImageUtils.rotateRgba90(original, 2, 3);
    expect(result, expected);
  });

  test('ImageUtils.rotateRgba180 rotates a 2x3 image correctly', () {
    final original = Uint8List.fromList([
      1, 1, 1, 1,   2, 2, 2, 2,
      3, 3, 3, 3,   4, 4, 4, 4,
      5, 5, 5, 5,   6, 6, 6, 6,
    ]);

    // Rotated 180 degrees should be 2x3:
    final expected = Uint8List.fromList([
      6, 6, 6, 6,   5, 5, 5, 5,
      4, 4, 4, 4,   3, 3, 3, 3,
      2, 2, 2, 2,   1, 1, 1, 1,
    ]);

    final result = ImageUtils.rotateRgba180(original, 2, 3);
    expect(result, expected);
  });

  test('ImageUtils.rotateRgba270 rotates a 2x3 image correctly', () {
    final original = Uint8List.fromList([
      1, 1, 1, 1,   2, 2, 2, 2,
      3, 3, 3, 3,   4, 4, 4, 4,
      5, 5, 5, 5,   6, 6, 6, 6,
    ]);

    // Rotated 270 degrees clockwise should be 3x2:
    final expected = Uint8List.fromList([
      2, 2, 2, 2,   4, 4, 4, 4,   6, 6, 6, 6,
      1, 1, 1, 1,   3, 3, 3, 3,   5, 5, 5, 5,
    ]);

    final result = ImageUtils.rotateRgba270(original, 2, 3);
    expect(result, expected);
  });

  test('ImageUtils.generateDeliveryNoteBytes renders successfully', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const config = PrinterConfig(
      printerId: 1,
      customWidthMm: 80,
      customHeightMm: 120,
    );
    final data = {
      'code': 'TEST-123',
      'sender': 'Cửa hàng A',
      'receiver': 'Khách hàng B',
      'items': [
        {'name': 'Sản phẩm 1', 'quantity': 2, 'unit': 'Cái'},
        {'name': 'Sản phẩm 2', 'quantity': 1, 'unit': 'Hộp'},
      ],
    };

    final bytes = await ImageUtils.generateDeliveryNoteBytes(
      deliveryNoteData: data,
      config: config,
    );

    expect(bytes, isNotEmpty);
    expect(bytes[0], 0x89);
    expect(bytes[1], 0x50);
    expect(bytes[2], 0x4E);
    expect(bytes[3], 0x47);
  });
}
