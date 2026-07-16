import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// Tên ứng dụng
  ///
  /// In vi, this message translates to:
  /// **'Label Print'**
  String get appTitle;

  /// Tiêu đề trang chủ
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get homeTitle;

  /// Tiêu đề màn hình quản lý máy in
  ///
  /// In vi, this message translates to:
  /// **'Quản lý máy in'**
  String get printerManagement;

  /// Tiêu đề cấu hình in
  ///
  /// In vi, this message translates to:
  /// **'Cấu hình in'**
  String get printConfig;

  /// Nút lưu mẫu in
  ///
  /// In vi, this message translates to:
  /// **'Lưu mẫu in'**
  String get saveTemplate;

  /// Tiêu đề in mã vạch
  ///
  /// In vi, this message translates to:
  /// **'In mã vạch'**
  String get barcodePrinting;

  /// Tính năng in mã vạch
  ///
  /// In vi, this message translates to:
  /// **'Mã vạch'**
  String get featureBarcode;

  /// Tính năng in mã QR
  ///
  /// In vi, this message translates to:
  /// **'Mã QR'**
  String get featureQr;

  /// Tính năng in nhãn
  ///
  /// In vi, this message translates to:
  /// **'Nhãn hàng'**
  String get featureLabel;

  /// Tính năng in vận đơn
  ///
  /// In vi, this message translates to:
  /// **'Vận đơn'**
  String get featureShipping;

  /// Tính năng in hóa đơn
  ///
  /// In vi, this message translates to:
  /// **'Hóa đơn'**
  String get featureReceipt;

  /// Tính năng in file PDF
  ///
  /// In vi, this message translates to:
  /// **'In PDF'**
  String get featurePdf;

  /// Tính năng in hình ảnh
  ///
  /// In vi, this message translates to:
  /// **'In ảnh'**
  String get featureImage;

  /// Tính năng in phiếu giao hàng
  ///
  /// In vi, this message translates to:
  /// **'Phiếu giao hàng'**
  String get featureDelivery;

  /// Trạng thái máy in sẵn sàng
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng'**
  String get printerStatusReady;

  /// Trạng thái máy in chờ
  ///
  /// In vi, this message translates to:
  /// **'Chờ'**
  String get printerStatusIdle;

  /// Trạng thái máy in lỗi
  ///
  /// In vi, this message translates to:
  /// **'Lỗi'**
  String get printerStatusError;

  /// Máy in chưa được cấu hình
  ///
  /// In vi, this message translates to:
  /// **'Chưa cấu hình'**
  String get printerNotConfigured;

  /// Nút thêm máy in mới
  ///
  /// In vi, this message translates to:
  /// **'Thêm máy in'**
  String get addPrinter;

  /// Nút chỉnh sửa máy in
  ///
  /// In vi, this message translates to:
  /// **'Sửa máy in'**
  String get editPrinter;

  /// Nút xóa máy in
  ///
  /// In vi, this message translates to:
  /// **'Xóa máy in'**
  String get deletePrinter;

  /// Nút test kết nối
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra kết nối'**
  String get testConnection;

  /// Nút quét tìm thiết bị
  ///
  /// In vi, this message translates to:
  /// **'Quét thiết bị'**
  String get scanDevices;

  /// Label tên máy in
  ///
  /// In vi, this message translates to:
  /// **'Tên máy in'**
  String get printerName;

  /// Label loại máy in
  ///
  /// In vi, this message translates to:
  /// **'Loại máy in'**
  String get printerType;

  /// Label phương thức kết nối
  ///
  /// In vi, this message translates to:
  /// **'Phương thức kết nối'**
  String get connectionMethod;

  /// Label địa chỉ IP
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ IP'**
  String get ipAddress;

  /// Label cổng kết nối
  ///
  /// In vi, this message translates to:
  /// **'Cổng'**
  String get port;

  /// Nút đặt máy in mặc định
  ///
  /// In vi, this message translates to:
  /// **'Đặt mặc định'**
  String get setDefault;

  /// Label khổ giấy
  ///
  /// In vi, this message translates to:
  /// **'Khổ giấy'**
  String get paperSize;

  /// Label loại giấy
  ///
  /// In vi, this message translates to:
  /// **'Loại giấy'**
  String get paperType;

  /// Label hướng in
  ///
  /// In vi, this message translates to:
  /// **'Hướng in'**
  String get orientation;

  /// Hướng in dọc
  ///
  /// In vi, this message translates to:
  /// **'Dọc'**
  String get portrait;

  /// Hướng in ngang
  ///
  /// In vi, this message translates to:
  /// **'Ngang'**
  String get landscape;

  /// Label lề trên
  ///
  /// In vi, this message translates to:
  /// **'Lề trên'**
  String get marginTop;

  /// Label lề trái
  ///
  /// In vi, this message translates to:
  /// **'Lề trái'**
  String get marginLeft;

  /// Label lề phải
  ///
  /// In vi, this message translates to:
  /// **'Lề phải'**
  String get marginRight;

  /// Label độ đậm nét in
  ///
  /// In vi, this message translates to:
  /// **'Độ đậm in'**
  String get printDarkness;

  /// Label tốc độ in
  ///
  /// In vi, this message translates to:
  /// **'Tốc độ in'**
  String get printSpeed;

  /// Label chế độ tỷ lệ
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tỷ lệ'**
  String get scalingMode;

  /// Chế độ vừa chiều rộng
  ///
  /// In vi, this message translates to:
  /// **'Vừa chiều rộng'**
  String get fitWidth;

  /// Chế độ vừa chiều cao
  ///
  /// In vi, this message translates to:
  /// **'Vừa chiều cao'**
  String get fitHeight;

  /// Chế độ tỷ lệ tùy chỉnh
  ///
  /// In vi, this message translates to:
  /// **'Tùy chỉnh'**
  String get customScale;

  /// Label tên mẫu in
  ///
  /// In vi, this message translates to:
  /// **'Tên mẫu'**
  String get templateName;

  /// Nút lưu cấu hình
  ///
  /// In vi, this message translates to:
  /// **'Lưu cấu hình'**
  String get saveConfig;

  /// Nút lưu thành mẫu
  ///
  /// In vi, this message translates to:
  /// **'Lưu thành mẫu'**
  String get saveAsTemplate;

  /// Label dữ liệu mã vạch
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu mã vạch'**
  String get barcodeData;

  /// Label loại mã vạch
  ///
  /// In vi, this message translates to:
  /// **'Loại mã vạch'**
  String get barcodeType;

  /// Label chiều cao mã vạch
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao mã vạch'**
  String get barcodeHeight;

  /// Toggle hiện text dưới mã vạch
  ///
  /// In vi, this message translates to:
  /// **'Hiển thị chữ dưới mã'**
  String get showReadableText;

  /// Nút tiếp tục in
  ///
  /// In vi, this message translates to:
  /// **'In tiếp'**
  String get continuePrint;

  /// Nút in ngay
  ///
  /// In vi, this message translates to:
  /// **'In ngay'**
  String get printNow;

  /// Lỗi tên máy in trống
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên máy in'**
  String get errPrinterNameEmpty;

  /// Lỗi IP không đúng định dạng
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ IP không hợp lệ'**
  String get errIpInvalid;

  /// Lỗi trùng địa chỉ máy in
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ này đã được sử dụng'**
  String get errDuplicateAddress;

  /// Lỗi kết nối thất bại
  ///
  /// In vi, this message translates to:
  /// **'Không thể kết nối đến máy in'**
  String get errConnectionFailed;

  /// Lỗi định dạng ảnh/bytes không đúng cấu hình
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu hình ảnh không hợp lệ'**
  String get errInvalidImageData;

  /// Lỗi kích thước giấy ngoài phạm vi
  ///
  /// In vi, this message translates to:
  /// **'Kích thước giấy phải từ 20mm đến 220mm'**
  String get errPaperSizeRange;

  /// Lỗi tỷ lệ ngoài phạm vi
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ phải từ 50% đến 200%'**
  String get errScaleRange;

  /// Lỗi định dạng EAN-13
  ///
  /// In vi, this message translates to:
  /// **'Mã EAN-13 phải có đúng 13 chữ số'**
  String get errEan13Format;

  /// Lỗi ký tự không hợp lệ cho Code128
  ///
  /// In vi, this message translates to:
  /// **'Mã Code128 chỉ hỗ trợ ký tự ASCII'**
  String get errCode128Ascii;

  /// Thông báo thêm máy in thành công
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm máy in thành công'**
  String get successPrinterAdded;

  /// Thông báo in thử thành công
  ///
  /// In vi, this message translates to:
  /// **'In thử thành công'**
  String get successTestPrint;

  /// Thông báo lưu cấu hình thành công
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu cấu hình'**
  String get successConfigSaved;

  /// Thông báo lưu mẫu thành công
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu mẫu in'**
  String get successTemplateSaved;

  /// Thông báo gửi lệnh in thành công
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi lệnh in'**
  String get successPrintSent;

  /// Nút hủy
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// Nút lưu
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// Nút xóa
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// Nút sửa
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get edit;

  /// Nút xác nhận
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// Nút thử lại
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// Kết nối Bluetooth
  ///
  /// In vi, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// Kết nối Wi-Fi
  ///
  /// In vi, this message translates to:
  /// **'Wi-Fi'**
  String get wifi;

  /// Loại máy in nhãn TSPL
  ///
  /// In vi, this message translates to:
  /// **'Máy in nhãn (TSPL)'**
  String get labelPrinterTspl;

  /// Loại máy in hóa đơn ESC/POS
  ///
  /// In vi, this message translates to:
  /// **'Máy in hóa đơn (ESC/POS)'**
  String get receiptPrinterEscpos;

  /// Loại máy in nhãn
  ///
  /// In vi, this message translates to:
  /// **'Máy in nhãn'**
  String get printerTypeLabel;

  /// Loại máy in hóa đơn
  ///
  /// In vi, this message translates to:
  /// **'Máy in hóa đơn'**
  String get printerTypeReceipt;

  /// Label máy in mặc định
  ///
  /// In vi, this message translates to:
  /// **'Máy in mặc định'**
  String get defaultPrinter;

  /// Thông báo chưa có máy in
  ///
  /// In vi, this message translates to:
  /// **'Chưa có máy in nào'**
  String get noPrintersFound;

  /// Tiêu đề dialog xác nhận xóa
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa'**
  String get deleteConfirmTitle;

  /// Nội dung dialog xác nhận xóa
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa máy in này không?'**
  String get deleteConfirmMessage;

  /// Khổ giấy A5
  ///
  /// In vi, this message translates to:
  /// **'A5 (148 × 210 mm)'**
  String get paperSizeA5;

  /// Khổ giấy A6
  ///
  /// In vi, this message translates to:
  /// **'A6 (105 × 148 mm)'**
  String get paperSizeA6;

  /// Khổ giấy A7
  ///
  /// In vi, this message translates to:
  /// **'A7 (74 × 105 mm)'**
  String get paperSizeA7;

  /// Khổ giấy A8
  ///
  /// In vi, this message translates to:
  /// **'A8 (52 × 74 mm)'**
  String get paperSizeA8;

  /// Khổ giấy tùy chỉnh
  ///
  /// In vi, this message translates to:
  /// **'Tùy chỉnh'**
  String get paperSizeCustom;

  /// Loại giấy nhãn
  ///
  /// In vi, this message translates to:
  /// **'Nhãn'**
  String get paperTypeLabel;

  /// Loại giấy liên tục
  ///
  /// In vi, this message translates to:
  /// **'Liên tục'**
  String get paperTypeContinuous;

  /// Loại giấy đánh dấu đen
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu đen'**
  String get paperTypeBlackMark;

  /// Tỷ lệ vừa chiều rộng
  ///
  /// In vi, this message translates to:
  /// **'Vừa chiều rộng'**
  String get scalingFitWidth;

  /// Tỷ lệ vừa chiều cao
  ///
  /// In vi, this message translates to:
  /// **'Vừa chiều cao'**
  String get scalingFitHeight;

  /// Tỷ lệ tùy chỉnh
  ///
  /// In vi, this message translates to:
  /// **'Tùy chỉnh'**
  String get scalingCustom;

  /// Label chiều rộng tùy chỉnh
  ///
  /// In vi, this message translates to:
  /// **'Chiều rộng tùy chỉnh'**
  String get customWidth;

  /// Label chiều cao tùy chỉnh
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao tùy chỉnh'**
  String get customHeight;

  /// Tiêu đề lịch sử in
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử in'**
  String get printHistory;

  /// Tiêu đề danh sách mẫu in
  ///
  /// In vi, this message translates to:
  /// **'Mẫu in'**
  String get templates;

  /// Hiển thị giá trị độ đậm
  ///
  /// In vi, this message translates to:
  /// **'Độ đậm: {value}'**
  String darknessSetting(int value);

  /// Hiển thị giá trị tốc độ in
  ///
  /// In vi, this message translates to:
  /// **'Tốc độ: {value} inch/s'**
  String speedSetting(double value);

  /// Tiêu đề màn hình xem trước bản in
  ///
  /// In vi, this message translates to:
  /// **'Xem trước bản in'**
  String get printPreview;

  /// Tiêu đề thông tin cấu hình
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cấu hình'**
  String get configInfo;

  /// Hiển thị thông số lề
  ///
  /// In vi, this message translates to:
  /// **'Lề: {top}/{left}/{right}mm'**
  String marginInfo(double top, double left, double right);

  /// Hiển thị độ đậm in
  ///
  /// In vi, this message translates to:
  /// **'Độ đậm: {value}'**
  String darknessInfo(int value);

  /// Thông báo đang tải preview
  ///
  /// In vi, this message translates to:
  /// **'Đang tải preview...'**
  String get previewLoading;

  /// Thông báo lỗi preview
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tải preview'**
  String get previewError;

  /// Label số bản sao
  ///
  /// In vi, this message translates to:
  /// **'Số bản sao'**
  String get copies;

  /// Tooltip nút phóng to
  ///
  /// In vi, this message translates to:
  /// **'Phóng to'**
  String get zoomIn;

  /// Tooltip nút thu nhỏ
  ///
  /// In vi, this message translates to:
  /// **'Thu nhỏ'**
  String get zoomOut;

  /// Tooltip nút vừa màn hình
  ///
  /// In vi, this message translates to:
  /// **'Vừa màn hình'**
  String get fitScreen;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
