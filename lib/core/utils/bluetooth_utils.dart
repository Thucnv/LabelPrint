import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';

import '../errors/exceptions.dart';

/// Lớp tiện ích quản lý quét, kết nối và truyền dữ liệu qua Bluetooth.
///
/// Sử dụng thư viện `flutter_blue_plus`.
class BluetoothUtils {
  /// Bắt đầu quét các thiết bị Bluetooth LE xung quanh.
  ///
  /// Trả về một Stream các kết quả quét [ScanResult].
  static Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  /// Bắt đầu quét thiết bị trong một khoảng thời gian [timeout].
  static Future<void> startScan({Duration timeout = const Duration(seconds: 4)}) async {
    // Kiểm tra xem bluetooth có bật không trước khi quét
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      throw PrinterException(
        code: 'errConnectionFailed',
        message: 'Bluetooth chưa được bật trên thiết bị',
      );
    }
    await FlutterBluePlus.startScan(timeout: timeout);
  }

  /// Dừng quét thiết bị.
  static Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// Kết nối tới một thiết bị Bluetooth theo [remoteId] (MAC Address hoặc UUID).
  static Future<BluetoothDevice> connect(String remoteId) async {
    final device = BluetoothDevice.fromId(remoteId);
    try {
      await device.connect(autoConnect: false).timeout(const Duration(seconds: 10));
      return device;
    } on TimeoutException {
      throw PrinterException(
        code: 'errConnectionFailed',
        message: 'Kết nối Bluetooth hết hạn (Timeout 10s)',
      );
    } catch (e) {
      throw PrinterException(
        code: 'errConnectionFailed',
        message: 'Không thể kết nối đến máy in Bluetooth: $e',
      );
    }
  }

  /// Gửi mảng bytes dữ liệu in tới thiết bị Bluetooth đã kết nối.
  ///
  /// Tự động tìm dịch vụ (Service) và đặc tính ghi (Write Characteristic) phù hợp.
  static Future<void> writeBytes(BluetoothDevice device, Uint8List bytes) async {
    try {
      // 1. Khám phá các service của thiết bị
      final services = await device.discoverServices();
      BluetoothCharacteristic? writeCharacteristic;

      // 2. Tìm characteristic hỗ trợ write hoặc writeWithoutResponse
      for (final service in services) {
        for (final char in service.characteristics) {
          if (char.properties.write || char.properties.writeWithoutResponse) {
            writeCharacteristic = char;
            break;
          }
        }
        if (writeCharacteristic != null) break;
      }

      if (writeCharacteristic == null) {
        throw PrinterException(
          code: 'errConnectionFailed',
          message: 'Không tìm thấy kênh ghi dữ liệu (Write Characteristic) trên máy in',
        );
      }

      // 3. Phân mảnh bytes nếu mảng quá lớn (MTU size mặc định của BLE thường là 20-512 bytes)
      // Chúng ta chia nhỏ thành các gói 200 bytes để ghi an toàn
      const int chunkSize = 200;
      for (int i = 0; i < bytes.length; i += chunkSize) {
        final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        final chunk = bytes.sublist(i, end);
        await writeCharacteristic.write(
          chunk,
          withoutResponse: writeCharacteristic.properties.writeWithoutResponse,
        );
        // Delay một khoảng cực ngắn để tránh tràn buffer của máy in
        await Future.delayed(const Duration(milliseconds: 10));
      }
    } catch (e) {
      throw PrinterException(
        code: 'errConnectionFailed',
        message: 'Gửi lệnh in qua Bluetooth thất bại: $e',
      );
    }
  }

  /// Ngắt kết nối thiết bị Bluetooth.
  static Future<void> disconnect(String remoteId) async {
    final device = BluetoothDevice.fromId(remoteId);
    await device.disconnect();
  }
}
