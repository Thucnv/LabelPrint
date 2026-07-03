import 'dart:io';
import 'dart:typed_data';

import '../../domain/entities/enums/printer_enums.dart';
import '../../domain/entities/printer.dart';
import '../errors/exceptions.dart';
import 'bluetooth_utils.dart';

/// Lớp tiện ích gửi bytes lệnh in trực tiếp đến máy in thông qua WiFi hoặc Bluetooth.
class PrinterSender {
  /// Kết nối và gửi bytes đến máy in được chỉ định.
  static Future<void> send({
    required Printer printer,
    required Uint8List bytes,
  }) async {
    if (printer.connectionMethod == ConnectionMethod.wifi) {
      if (printer.wifiIp == null || printer.wifiIp!.isEmpty) {
        throw PrinterException(
          code: 'errIpInvalid',
          message: 'Địa chỉ IP máy in WiFi trống',
        );
      }
      await _sendToWifi(printer.wifiIp!, printer.wifiPort, bytes);
    } else {
      if (printer.btMacAddress == null || printer.btMacAddress!.isEmpty) {
        throw PrinterException(
          code: 'errConnectionFailed',
          message: 'Địa chỉ MAC máy in Bluetooth trống',
        );
      }
      await _sendToBluetooth(printer.btMacAddress!, bytes);
    }
  }

  /// Gửi dữ liệu qua Socket TCP (WiFi)
  static Future<void> _sendToWifi(String ip, int port, Uint8List bytes) async {
    Socket? socket;
    try {
      socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      socket.add(bytes);
      await socket.flush();
    } on SocketException catch (e) {
      throw PrinterException(
        code: 'errConnectionFailed',
        message: 'Không thể kết nối WiFi tới máy in tại $ip:$port. Lỗi: ${e.message}',
      );
    } catch (e) {
      throw PrinterException(
        code: 'errConnectionFailed',
        message: 'Lỗi không xác định khi kết nối WiFi tới máy in: $e',
      );
    } finally {
      socket?.destroy();
    }
  }

  /// Gửi dữ liệu qua Bluetooth BLE
  static Future<void> _sendToBluetooth(String remoteId, Uint8List bytes) async {
    final device = await BluetoothUtils.connect(remoteId);
    try {
      await BluetoothUtils.writeBytes(device, bytes);
    } finally {
      await device.disconnect();
    }
  }
}
