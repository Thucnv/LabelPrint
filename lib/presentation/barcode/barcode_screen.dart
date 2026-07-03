import 'package:barcode_widget/barcode_widget.dart' as bc_widget;
import 'package:barcode/barcode.dart' as bc_core;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../core/di/injection_container.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';
import '../../domain/entities/enums/barcode_type.dart';
import 'bloc/barcode_bloc.dart';
import 'bloc/barcode_event.dart';
import 'bloc/barcode_state.dart';

class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final _textController = TextEditingController(text: '12345678');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Map từ domain enum BarcodeType sang class Barcode của package barcode
  bc_core.Barcode _mapToBarcode(BarcodeType type) {
    switch (type) {
      case BarcodeType.code128:
        return bc_core.Barcode.code128();
      case BarcodeType.ean13:
        return bc_core.Barcode.ean13();
      case BarcodeType.ean8:
        return bc_core.Barcode.ean8();
      case BarcodeType.upcA:
        return bc_core.Barcode.upcA();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<BarcodeBloc>(
      create: (context) => sl<BarcodeBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            l10n.barcodePrinting,
            style: AppTextStyles.headingLg.copyWith(color: AppColors.onSurface),
          ),
          elevation: 0,
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune, color: AppColors.primary),
              tooltip: l10n.printConfig,
              onPressed: () => context.push('/print-config'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocConsumer<BarcodeBloc, BarcodeState>(
          listenWhen: (previous, current) =>
              current.success || current.errorMessage != null,
          listener: (context, state) {
            if (state.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.successPrintSent),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final bloc = context.read<BarcodeBloc>();

            // Đồng bộ dữ liệu Controller nếu có thay đổi từ state (tránh lệch pha)
            if (_textController.text != state.data) {
              _textController.text = state.data;
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Ô nhập nội dung
                        CustomTextField(
                          label: l10n.barcodeData,
                          controller: _textController,
                          errorText: state.validationError,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                            onPressed: () {
                              // Giả lập quét camera
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tính năng camera quét mã vạch đang phát triển')),
                              );
                            },
                          ),
                          onChanged: (value) => bloc.add(BarcodeDataChanged(value)),
                        ),
                        const SizedBox(height: 16),

                        // 2. Chọn loại barcode
                        SectionHeader(title: l10n.barcodeType.toUpperCase()),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<BarcodeType>(
                          value: state.barcodeType,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: BarcodeType.values.map((type) {
                            return DropdownMenuItem<BarcodeType>(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) bloc.add(BarcodeTypeChanged(val));
                          },
                        ),
                        const SizedBox(height: 16),

                        // 3. Chiều cao barcode
                        SectionHeader(title: '${l10n.barcodeHeight}: ${state.height.toInt()} dots'.toUpperCase()),
                        Slider(
                          value: state.height,
                          min: 40,
                          max: 200,
                          divisions: 16,
                          activeColor: AppColors.primary,
                          onChanged: (val) => bloc.add(BarcodeHeightChanged(val)),
                        ),
                        const SizedBox(height: 8),

                        // 4. Switch hiển thị text
                        SwitchListTile(
                          title: Text(
                            l10n.showReadableText,
                            style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
                          ),
                          value: state.showText,
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => bloc.add(BarcodeShowTextChanged(val)),
                        ),
                        const SizedBox(height: 24),

                        // 5. Xem trước (Live Preview)
                        SectionHeader(title: 'Xem trước'.toUpperCase()),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Center(
                            child: state.validationError != null
                                ? Text(
                                    state.validationError!,
                                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  )
                                : bc_widget.BarcodeWidget(
                                    data: state.data,
                                    barcode: _mapToBarcode(state.barcodeType),
                                    height: state.height,
                                    drawText: state.showText,
                                    style: AppTextStyles.bodyLg.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                    errorBuilder: (context, error) {
                                      return const Text(
                                        'Dữ liệu mã số không khớp định dạng',
                                        style: TextStyle(color: AppColors.error),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // 6. Nút In ngay dưới cùng
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: PrimaryButton(
                    text: l10n.continuePrint.toUpperCase(),
                    icon: Icons.print,
                    isLoading: state.isPrinting,
                    onPressed: state.validationError != null
                        ? null
                        : () => context.push(
                            '/print-preview',
                            extra: {
                              'documentType': 'barcode',
                              'barcodeData': {
                                'data': state.data,
                                'type': state.barcodeType,
                                'height': state.height,
                                'showText': state.showText,
                              },
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
