import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:label_print/core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'core/theme/app_theme.dart';
import 'presentation/barcode/barcode_screen.dart';
import 'presentation/delivery_note/delivery_note_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/print_config/print_config_screen.dart';
import 'presentation/print_preview/print_preview_screen.dart';
import 'presentation/printer_management/printer_management_screen.dart';

/// Lớp cấu hình routing và khởi tạo MaterialApp.
class LabelPrintApp extends StatefulWidget {
  const LabelPrintApp({super.key});

  @override
  State<LabelPrintApp> createState() => _LabelPrintAppState();

  // Cấu hình GoRouter điều hướng các màn hình
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/printer-management',
        builder: (context, state) => const PrinterManagementScreen(),
      ),
      GoRoute(
        path: '/print-config',
        builder: (context, state) => const PrintConfigScreen(),
      ),
      GoRoute(
        path: '/barcode-print',
        builder: (context, state) => const BarcodeScreen(),
      ),
      GoRoute(
        path: '/delivery-note-print',
        builder: (context, state) => const DeliveryNoteScreen(),
      ),
      GoRoute(
        path: '/print-preview',
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>?;
          return PrintPreviewScreen(extraData: extraData);
        },
      ),
    ],
  );
}

class _LabelPrintAppState extends State<LabelPrintApp> {
  StreamSubscription? _intentSub;

  @override
  void initState() {
    super.initState();

    // 1. Lắng nghe chia sẻ khi app đang chạy ngầm trong bộ nhớ
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _handleSharedFiles(value);
    }, onError: (err) {
      debugPrint("Lỗi nhận dữ liệu chia sẻ (getMediaStream): $err");
    });

    // 2. Nhận dữ liệu chia sẻ khi khởi động app từ trạng thái đóng hoàn toàn
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _handleSharedFiles(value);
      ReceiveSharingIntent.instance.reset();
    });
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }

  void _handleSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;

    // Chỉ quan tâm đến file ảnh đầu tiên được chia sẻ
    final imageFile = files.firstWhere(
      (file) => file.type == SharedMediaType.image,
      orElse: () => files.first,
    );

    if (imageFile.type == SharedMediaType.image) {
      // Delay nhẹ để đảm bảo GoRouter đã sẵn sàng
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LabelPrintApp._router.push(
          '/print-preview',
          extra: {
            'documentType': 'image',
            'imagePath': imageFile.path,
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Label Print',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      
      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'), // Mặc định dùng tiếng Việt theo BRD

      // Routing
      routerConfig: LabelPrintApp._router,
    );
  }
}
