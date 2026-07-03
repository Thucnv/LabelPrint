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
import '../../domain/entities/delivery_note_item.dart';
import 'bloc/delivery_note_cubit.dart';
import 'bloc/delivery_note_state.dart';

class DeliveryNoteScreen extends StatefulWidget {
  const DeliveryNoteScreen({super.key});

  @override
  State<DeliveryNoteScreen> createState() => _DeliveryNoteScreenState();
}

class _DeliveryNoteScreenState extends State<DeliveryNoteScreen> {
  late final DeliveryNoteCubit _cubit;
  late final TextEditingController _codeController;
  late final TextEditingController _senderController;
  late final TextEditingController _receiverController;
  final List<TextEditingController> _itemNameControllers = [];
  final List<TextEditingController> _itemUnitControllers = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo Cubit duy nhất
    _cubit = sl<DeliveryNoteCubit>();
    _codeController = TextEditingController(text: _cubit.state.code);
    _senderController = TextEditingController(text: _cubit.state.sender);
    _receiverController = TextEditingController(text: _cubit.state.receiver);
    for (var item in _cubit.state.items) {
      _itemNameControllers.add(TextEditingController(text: item.name));
      _itemUnitControllers.add(TextEditingController(text: item.unit));
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _senderController.dispose();
    _receiverController.dispose();
    for (var controller in _itemNameControllers) {
      controller.dispose();
    }
    for (var controller in _itemUnitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Đồng bộ hóa các text controllers của danh sách sản phẩm với State an toàn
  void _syncControllers(List<DeliveryNoteItem> items) {
    while (_itemNameControllers.length < items.length) {
      final index = _itemNameControllers.length;
      _itemNameControllers.add(TextEditingController(text: items[index].name));
    }
    while (_itemNameControllers.length > items.length) {
      _itemNameControllers.removeLast().dispose();
    }

    while (_itemUnitControllers.length < items.length) {
      final index = _itemUnitControllers.length;
      _itemUnitControllers.add(TextEditingController(text: items[index].unit));
    }
    while (_itemUnitControllers.length > items.length) {
      _itemUnitControllers.removeLast().dispose();
    }

    for (int i = 0; i < items.length; i++) {
      final idx = i;
      if (_itemNameControllers[idx].text != items[idx].name) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && idx < _itemNameControllers.length) {
            _itemNameControllers[idx].text = items[idx].name;
          }
        });
      }
      if (_itemUnitControllers[idx].text != items[idx].unit) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && idx < _itemUnitControllers.length) {
            _itemUnitControllers[idx].text = items[idx].unit;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<DeliveryNoteCubit>(
      create: (context) => _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Phiếu Giao Hàng',
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
        body: BlocConsumer<DeliveryNoteCubit, DeliveryNoteState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
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
            final cubit = context.read<DeliveryNoteCubit>();
            _syncControllers(state.items);

            // Đồng bộ dữ liệu chung an toàn
            if (_codeController.text != state.code) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _codeController.text = state.code;
              });
            }
            if (_senderController.text != state.sender) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _senderController.text = state.sender;
              });
            }
            if (_receiverController.text != state.receiver) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _receiverController.text = state.receiver;
              });
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Thông tin chung
                        SectionHeader(title: 'Thông tin chung'.toUpperCase()),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Số phiếu / No.',
                          hint: 'Nhập số phiếu giao hàng...',
                          controller: _codeController,
                          onChanged: cubit.updateCode,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Người gửi / Sender',
                          hint: 'Tên người gửi hoặc cửa hàng...',
                          controller: _senderController,
                          onChanged: cubit.updateSender,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Người nhận / Receiver',
                          hint: 'Tên người nhận hàng...',
                          controller: _receiverController,
                          onChanged: cubit.updateReceiver,
                        ),
                        const SizedBox(height: 24),

                        // 2. Danh sách sản phẩm
                        SectionHeader(
                          title: 'Sản phẩm'.toUpperCase(),
                          trailing: TextButton.icon(
                            onPressed: cubit.addItem,
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Thêm sản phẩm'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              textStyle: AppTextStyles.label,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Vùng lặp danh sách sản phẩm
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // Tên sản phẩm
                                      Expanded(
                                        child: CustomTextField(
                                          label: 'Tên sản phẩm / Item Name',
                                          hint: 'Ví dụ: Áo thun Polo...',
                                          controller: _itemNameControllers[index],
                                          onChanged: (val) => cubit.updateItemName(index, val),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Nút xóa sản phẩm
                                      if (state.items.length > 1)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                          onPressed: () => cubit.removeItem(index),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      // Đơn vị tính
                                      Expanded(
                                        flex: 2,
                                        child: CustomTextField(
                                          label: 'ĐVT / Unit',
                                          hint: 'Cái, Hộp, kg...',
                                          controller: _itemUnitControllers[index],
                                          onChanged: (val) => cubit.updateItemUnit(index, val),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Tăng giảm số lượng
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Số lượng / Qty',
                                              style: AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (item.quantity > 1) {
                                                      cubit.updateItemQuantity(index, item.quantity - 1);
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.surfaceVariant,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(Icons.remove, size: 16, color: AppColors.onSurface),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    '${item.quantity}',
                                                    textAlign: TextAlign.center,
                                                    style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    cubit.updateItemQuantity(index, item.quantity + 1);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.surfaceVariant,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(Icons.add, size: 16, color: AppColors.onSurface),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Hiển thị lỗi validation (nếu có)
                        if (state.validationError != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              state.validationError!,
                              style: AppTextStyles.bodyMd.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // 3. Nút In nằm cố định phía dưới
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
                    text: 'TIẾP TỤC IN',
                    icon: Icons.print,
                    isLoading: state.isPrinting,
                    onPressed: state.validationError != null
                        ? null
                        : () {
                            context.push(
                              '/print-preview',
                              extra: {
                                'documentType': 'deliveryNote',
                                'deliveryNoteData': {
                                  'code': state.code,
                                  'sender': state.sender,
                                  'receiver': state.receiver,
                                  'items': state.items
                                      .map((e) => {
                                            'name': e.name,
                                            'quantity': e.quantity,
                                            'unit': e.unit,
                                          })
                                      .toList(),
                                },
                              },
                            );
                          },
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
