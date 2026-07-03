import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:label_print/core/di/injection_container.dart' as di;
import 'package:label_print/core/l10n/app_localizations.dart';
import 'package:label_print/presentation/delivery_note/delivery_note_screen.dart';
import 'package:label_print/presentation/delivery_note/bloc/delivery_note_cubit.dart';

void main() {
  setUpAll(() async {
    // Đăng ký cubit vào DI
    if (!di.sl.isRegistered<DeliveryNoteCubit>()) {
      di.sl.registerFactory(() => DeliveryNoteCubit());
    }
  });

  testWidgets('DeliveryNoteScreen builds and runs successfully without throwing exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('vi'),
          Locale('en'),
        ],
        locale: Locale('vi'),
        home: DeliveryNoteScreen(),
      ),
    );

    // Đợi vẽ frame đầu tiên
    await tester.pump();

    // Xác nhận xem widget có tồn tại không
    expect(find.byType(DeliveryNoteScreen), findsOneWidget);
  });
}
