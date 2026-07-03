import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  // Đảm bảo Flutter framework được khởi tạo trước khi gọi DI/DB
  WidgetsFlutterBinding.ensureInitialized();

  // Thiết lập chỉ cho phép chiều dọc (portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Khởi tạo MobileAds cho AdMob
  await MobileAds.instance.initialize();

  // Khởi tạo Dependency Injection (SQLite init nằm trong hàm này)
  await di.init();

  runApp(const LabelPrintApp());
}
