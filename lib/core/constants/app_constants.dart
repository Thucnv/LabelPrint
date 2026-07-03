/// Hằng số toàn cục cho ứng dụng Label Print.
///
/// Tập trung quản lý tất cả giá trị cố định để tránh magic numbers
/// và đảm bảo tính nhất quán trong toàn bộ codebase.
abstract final class AppConstants {
  // ─── KẾT NỐI (Connection) ────────────────────────────────
  /// Thời gian chờ kết nối tối đa (giây)
  static const int connectionTimeoutSeconds = 5;

  /// Cổng mặc định kết nối WiFi đến máy in
  static const int defaultPort = 9100;

  // ─── MÁY IN (Printer) ────────────────────────────────────
  /// Độ dài tối đa tên máy in (ký tự)
  static const int maxPrinterNameLength = 50;

  // ─── GIẤY IN (Paper) ─────────────────────────────────────
  /// Kích thước giấy tùy chỉnh tối thiểu (mm)
  static const int minPaperSizeMm = 20;

  /// Kích thước giấy tùy chỉnh tối đa (mm)
  static const int maxPaperSizeMm = 220;

  // ─── TỶ LỆ CO GIÃN (Scaling) ─────────────────────────────
  /// Tỷ lệ co giãn tối thiểu (%)
  static const int minScale = 50;

  /// Tỷ lệ co giãn tối đa (%)
  static const int maxScale = 200;

  /// Tỷ lệ co giãn mặc định (%)
  static const int defaultScale = 100;

  // ─── ĐỘ ĐẬM IN (Darkness) ────────────────────────────────
  /// Độ đậm tối thiểu
  static const int minDarkness = 1;

  /// Độ đậm tối đa
  static const int maxDarkness = 15;

  /// Độ đậm mặc định
  static const int defaultDarkness = 8;

  // ─── TỐC ĐỘ IN (Print Speed) ─────────────────────────────
  /// Tốc độ in mặc định (inch/giây)
  static const double defaultSpeed = 4.0;

  /// Danh sách tốc độ in khả dụng (inch/giây)
  static const List<double> printSpeeds = [2.0, 3.0, 4.0, 5.0, 6.0];

  // ─── MÃ VẠCH (Barcode) ────────────────────────────────────
  /// Chiều cao mã vạch tối thiểu (dots)
  static const int minBarcodeHeight = 40;

  /// Chiều cao mã vạch tối đa (dots)
  static const int maxBarcodeHeight = 200;

  /// Chiều cao mã vạch mặc định (dots) ≈ 10mm
  static const int defaultBarcodeHeight = 80;

  // ─── TÀI LIỆU (Document) ─────────────────────────────────
  /// Kích thước file PDF tối đa (bytes) = 25 MB
  static const int maxPdfSizeBytes = 25 * 1024 * 1024;

  // ─── QUẢNG CÁO (Ads) ─────────────────────────────────────
  /// Thời gian chờ giữa 2 lần hiển thị quảng cáo xen kẽ (giây)
  static const int adInterstitialCooldownSeconds = 180;

  /// AdMob Test IDs (dùng cho debug build)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  /// AdMob Release IDs (dùng cho release build)
  /// TODO: Thay thế bằng ID thực tế từ AdMob Console
  static const String _releaseBannerId = 'ca-app-pub-5002016707618419/4669140807';
  static const String _releaseInterstitialId = 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';

  /// Lấy Banner Ad Unit ID dựa trên build mode
  static String get bannerAdUnitId =>
      bool.fromEnvironment('dart.vm.product') ? _releaseBannerId : _testBannerId;

  /// Lấy Interstitial Ad Unit ID dựa trên build mode
  static String get interstitialAdUnitId =>
      bool.fromEnvironment('dart.vm.product') ? _releaseInterstitialId : _testInterstitialId;

  // ─── CƠ SỞ DỮ LIỆU (Database) ────────────────────────────
  /// Phiên bản database hiện tại
  static const int databaseVersion = 1;

  /// Tên file database SQLite
  static const String databaseName = 'label_print.db';

  // ─── DPI ──────────────────────────────────────────────────
  /// Độ phân giải mặc định cho render PDF (dots per inch)
  static const int defaultDpi = 203;

  /// Độ phân giải cao cho render PDF
  static const int highDpi = 300;
}
