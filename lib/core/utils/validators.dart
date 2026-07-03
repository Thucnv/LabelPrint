import '../../domain/entities/enums/barcode_type.dart';

/// Lớp tiện ích kiểm tra tính hợp lệ của dữ liệu nhập vào (Validation).
class Validators {
  /// Kiểm tra địa chỉ IPv4 hợp lệ
  static bool isValidIp(String ip) {
    final ipRegex = RegExp(
      r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
      r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegex.hasMatch(ip);
  }

  /// Kiểm tra cổng mạng (Port) hợp lệ (từ 1 đến 65535)
  static bool isValidPort(String portStr) {
    final port = int.tryParse(portStr);
    if (port == null) return false;
    return port >= 1 && port <= 65535;
  }

  /// Kiểm tra dữ liệu Barcode hợp lệ theo chuẩn
  static String? validateBarcodeData(String data, BarcodeType type) {
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
        final asciiRegex = RegExp(r'^[\x20-\x7F]*$');
        if (!asciiRegex.hasMatch(data)) {
          return 'Mã vạch Code-128 chỉ chấp nhận các ký tự ASCII hợp lệ';
        }
        break;
    }
    return null;
  }
}
