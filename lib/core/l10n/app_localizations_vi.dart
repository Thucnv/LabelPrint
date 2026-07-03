// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Label Print';

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String get printerManagement => 'Quản lý máy in';

  @override
  String get printConfig => 'Cấu hình in';

  @override
  String get saveTemplate => 'Lưu mẫu in';

  @override
  String get barcodePrinting => 'In mã vạch';

  @override
  String get featureBarcode => 'Mã vạch';

  @override
  String get featureQr => 'Mã QR';

  @override
  String get featureLabel => 'Nhãn hàng';

  @override
  String get featureShipping => 'Vận đơn';

  @override
  String get featureReceipt => 'Hóa đơn';

  @override
  String get featurePdf => 'In PDF';

  @override
  String get featureImage => 'In ảnh';

  @override
  String get featureDelivery => 'Phiếu giao hàng';

  @override
  String get printerStatusReady => 'Sẵn sàng';

  @override
  String get printerStatusIdle => 'Chờ';

  @override
  String get printerStatusError => 'Lỗi';

  @override
  String get printerNotConfigured => 'Chưa cấu hình';

  @override
  String get addPrinter => 'Thêm máy in';

  @override
  String get editPrinter => 'Sửa máy in';

  @override
  String get deletePrinter => 'Xóa máy in';

  @override
  String get testConnection => 'Kiểm tra kết nối';

  @override
  String get scanDevices => 'Quét thiết bị';

  @override
  String get printerName => 'Tên máy in';

  @override
  String get printerType => 'Loại máy in';

  @override
  String get connectionMethod => 'Phương thức kết nối';

  @override
  String get ipAddress => 'Địa chỉ IP';

  @override
  String get port => 'Cổng';

  @override
  String get setDefault => 'Đặt mặc định';

  @override
  String get paperSize => 'Khổ giấy';

  @override
  String get paperType => 'Loại giấy';

  @override
  String get orientation => 'Hướng in';

  @override
  String get portrait => 'Dọc';

  @override
  String get landscape => 'Ngang';

  @override
  String get marginTop => 'Lề trên';

  @override
  String get marginLeft => 'Lề trái';

  @override
  String get marginRight => 'Lề phải';

  @override
  String get printDarkness => 'Độ đậm in';

  @override
  String get printSpeed => 'Tốc độ in';

  @override
  String get scalingMode => 'Chế độ tỷ lệ';

  @override
  String get fitWidth => 'Vừa chiều rộng';

  @override
  String get fitHeight => 'Vừa chiều cao';

  @override
  String get customScale => 'Tùy chỉnh';

  @override
  String get templateName => 'Tên mẫu';

  @override
  String get saveConfig => 'Lưu cấu hình';

  @override
  String get saveAsTemplate => 'Lưu thành mẫu';

  @override
  String get barcodeData => 'Dữ liệu mã vạch';

  @override
  String get barcodeType => 'Loại mã vạch';

  @override
  String get barcodeHeight => 'Chiều cao mã vạch';

  @override
  String get showReadableText => 'Hiển thị chữ dưới mã';

  @override
  String get continuePrint => 'In tiếp';

  @override
  String get printNow => 'In ngay';

  @override
  String get errPrinterNameEmpty => 'Vui lòng nhập tên máy in';

  @override
  String get errIpInvalid => 'Địa chỉ IP không hợp lệ';

  @override
  String get errDuplicateAddress => 'Địa chỉ này đã được sử dụng';

  @override
  String get errConnectionFailed => 'Không thể kết nối đến máy in';

  @override
  String get errPaperSizeRange => 'Kích thước giấy phải từ 20mm đến 220mm';

  @override
  String get errScaleRange => 'Tỷ lệ phải từ 50% đến 200%';

  @override
  String get errEan13Format => 'Mã EAN-13 phải có đúng 13 chữ số';

  @override
  String get errCode128Ascii => 'Mã Code128 chỉ hỗ trợ ký tự ASCII';

  @override
  String get successPrinterAdded => 'Đã thêm máy in thành công';

  @override
  String get successTestPrint => 'In thử thành công';

  @override
  String get successConfigSaved => 'Đã lưu cấu hình';

  @override
  String get successTemplateSaved => 'Đã lưu mẫu in';

  @override
  String get successPrintSent => 'Đã gửi lệnh in';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get edit => 'Sửa';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get retry => 'Thử lại';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'Wi-Fi';

  @override
  String get labelPrinterTspl => 'Máy in nhãn (TSPL)';

  @override
  String get receiptPrinterEscpos => 'Máy in hóa đơn (ESC/POS)';

  @override
  String get printerTypeLabel => 'Máy in nhãn';

  @override
  String get printerTypeReceipt => 'Máy in hóa đơn';

  @override
  String get defaultPrinter => 'Máy in mặc định';

  @override
  String get noPrintersFound => 'Chưa có máy in nào';

  @override
  String get deleteConfirmTitle => 'Xác nhận xóa';

  @override
  String get deleteConfirmMessage => 'Bạn có chắc muốn xóa máy in này không?';

  @override
  String get paperSizeA5 => 'A5 (148 × 210 mm)';

  @override
  String get paperSizeA6 => 'A6 (105 × 148 mm)';

  @override
  String get paperSizeA7 => 'A7 (74 × 105 mm)';

  @override
  String get paperSizeA8 => 'A8 (52 × 74 mm)';

  @override
  String get paperSizeCustom => 'Tùy chỉnh';

  @override
  String get paperTypeLabel => 'Nhãn';

  @override
  String get paperTypeContinuous => 'Liên tục';

  @override
  String get paperTypeBlackMark => 'Đánh dấu đen';

  @override
  String get scalingFitWidth => 'Vừa chiều rộng';

  @override
  String get scalingFitHeight => 'Vừa chiều cao';

  @override
  String get scalingCustom => 'Tùy chỉnh';

  @override
  String get customWidth => 'Chiều rộng tùy chỉnh';

  @override
  String get customHeight => 'Chiều cao tùy chỉnh';

  @override
  String get printHistory => 'Lịch sử in';

  @override
  String get templates => 'Mẫu in';

  @override
  String darknessSetting(int value) {
    return 'Độ đậm: $value';
  }

  @override
  String speedSetting(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return 'Tốc độ: $valueString inch/s';
  }

  @override
  String get printPreview => 'Xem trước bản in';

  @override
  String get configInfo => 'Thông tin cấu hình';

  @override
  String marginInfo(double top, double left, double right) {
    return 'Lề: $top/$left/${right}mm';
  }

  @override
  String darknessInfo(int value) {
    return 'Độ đậm: $value';
  }

  @override
  String get previewLoading => 'Đang tải preview...';

  @override
  String get previewError => 'Lỗi tải preview';

  @override
  String get copies => 'Số bản sao';

  @override
  String get zoomIn => 'Phóng to';

  @override
  String get zoomOut => 'Thu nhỏ';

  @override
  String get fitScreen => 'Vừa màn hình';
}
