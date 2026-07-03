import 'package:flutter/material.dart' hide Orientation;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../core/di/injection_container.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/section_header.dart';
import '../../domain/entities/enums/print_enums.dart';
import 'bloc/print_config_cubit.dart';
import 'bloc/print_config_state.dart';

class PrintConfigScreen extends StatefulWidget {
  const PrintConfigScreen({super.key});

  @override
  State<PrintConfigScreen> createState() => _PrintConfigScreenState();
}

class _PrintConfigScreenState extends State<PrintConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _marginTopController;
  late final TextEditingController _marginLeftController;
  late final TextEditingController _marginRightController;
  late final TextEditingController _customWidthController;
  late final TextEditingController _customHeightController;
  late final TextEditingController _templateNameController;
  late final TextEditingController _scalePercentController;
  late final TextEditingController _labelGapController;

  @override
  void initState() {
    super.initState();
    _marginTopController = TextEditingController(text: '0.0');
    _marginLeftController = TextEditingController(text: '0.0');
    _marginRightController = TextEditingController(text: '0.0');
    _customWidthController = TextEditingController(text: '100');
    _customHeightController = TextEditingController(text: '150');
    _templateNameController = TextEditingController(text: '');
    _scalePercentController = TextEditingController(text: '100');
    _labelGapController = TextEditingController(text: '0.0');
  }

  @override
  void dispose() {
    _marginTopController.dispose();
    _marginLeftController.dispose();
    _marginRightController.dispose();
    _customWidthController.dispose();
    _customHeightController.dispose();
    _templateNameController.dispose();
    _scalePercentController.dispose();
    _labelGapController.dispose();
    super.dispose();
  }

  void _syncControllersWithState(PrintConfigState state) {
    // Chỉ cập nhật controller nếu giá trị text khác biệt (tránh giật lag khi gõ)
    final mtVal = double.tryParse(_marginTopController.text);
    if (_marginTopController.text.isEmpty) {
      // Keep empty while typing
    } else if (mtVal == null || mtVal != state.marginTop) {
      _marginTopController.text = state.marginTop.toString();
    }

    final mlVal = double.tryParse(_marginLeftController.text);
    if (_marginLeftController.text.isEmpty) {
      // Keep empty while typing
    } else if (mlVal == null || mlVal != state.marginLeft) {
      _marginLeftController.text = state.marginLeft.toString();
    }

    final mrVal = double.tryParse(_marginRightController.text);
    if (_marginRightController.text.isEmpty) {
      // Keep empty while typing
    } else if (mrVal == null || mrVal != state.marginRight) {
      _marginRightController.text = state.marginRight.toString();
    }

    final wVal = int.tryParse(_customWidthController.text);
    if (_customWidthController.text.isEmpty) {
      // Keep empty while typing
    } else if (wVal == null || wVal != state.customWidthMm) {
      _customWidthController.text = (state.customWidthMm ?? 100).toString();
    }

    final hVal = int.tryParse(_customHeightController.text);
    if (_customHeightController.text.isEmpty) {
      // Keep empty while typing
    } else if (hVal == null || hVal != state.customHeightMm) {
      _customHeightController.text = (state.customHeightMm ?? 150).toString();
    }

    final scaleVal = int.tryParse(_scalePercentController.text);
    if (_scalePercentController.text.isEmpty) {
      // Keep empty while typing
    } else if (scaleVal == null || scaleVal != state.scalingValue) {
      _scalePercentController.text = state.scalingValue.toString();
    }

    final gapVal = double.tryParse(_labelGapController.text);
    if (_labelGapController.text.isEmpty) {
      // Keep empty while typing
    } else if (gapVal == null || gapVal != state.labelGap) {
      _labelGapController.text = state.labelGap.toString();
    }

    if (_templateNameController.text != state.templateName) {
      _templateNameController.text = state.templateName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<PrintConfigCubit>(
      create: (context) => sl<PrintConfigCubit>()..loadConfig(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            l10n.printConfig,
            style: AppTextStyles.headingLg.copyWith(color: AppColors.onSurface),
          ),
          elevation: 0,
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
        body: BlocConsumer<PrintConfigCubit, PrintConfigState>(
          listenWhen: (previous, current) =>
              current.status == PrintConfigStatus.success || current.status == PrintConfigStatus.error,
          listener: (context, state) {
            if (state.status == PrintConfigStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage ?? 'Thành công'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state.status == PrintConfigStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            _syncControllersWithState(state);

            if (state.status == PrintConfigStatus.loading && state.printerId == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final cubit = context.read<PrintConfigCubit>();

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  // Printer Info Card
                  if (state.printerName != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.print,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.printerName!,
                                  style: AppTextStyles.headingMd.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.printerType?.displayName ?? '',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                              SectionHeader(title: l10n.paperSize.toUpperCase()),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (state.printerType != null
                                    ? PaperSize.getAvailableSizesForPrinterType(state.printerType!)
                                    : PaperSize.values)
                                .map((size) {
                              final bool hasMatchingTemplate = state.paperSize == PaperSize.custom &&
                                  state.templates.any((t) =>
                                      t.widthMm == state.customWidthMm &&
                                      t.heightMm == state.customHeightMm);

                              final isSelected = state.paperSize == size &&
                                  !(size == PaperSize.custom && hasMatchingTemplate);

                              final sizeName = size == PaperSize.custom ? 'Custom' : size.name.toUpperCase();
                              return FilterChip(
                                label: Text(sizeName),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                checkmarkColor: Colors.transparent,
                                showCheckmark: false,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (selected) {
                                  if (selected) cubit.updatePaperSize(size);
                                },
                              );
                            }).toList(),
                          ),
                          if (state.templates.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'BẢN MẪU CỦA TÔI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.templates.map((t) {
                                final isSelected = state.paperSize == PaperSize.custom &&
                                    state.customWidthMm == t.widthMm &&
                                    state.customHeightMm == t.heightMm;

                                return FilterChip(
                                  label: Text('${t.name} (${t.widthMm}×${t.heightMm}mm)'),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  checkmarkColor: Colors.transparent,
                                  showCheckmark: false,
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.onSurface,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      cubit.updatePaperSize(PaperSize.custom);
                                      cubit.updateCustomSize(t.widthMm, t.heightMm);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Display dimensions for selected paper size
                          if (state.paperSize != PaperSize.custom)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Text(
                                '${state.paperSize.widthMm}mm × ${state.paperSize.heightMm}mm',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),

                          // Custom size inputs if PaperSize.custom is selected
                          if (state.paperSize == PaperSize.custom) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Rộng (mm)',
                                    controller: _customWidthController,
                                    keyboardType: TextInputType.number,
                                    validator: (val) {
                                      final w = int.tryParse(val ?? '');
                                      if (w == null || w < 20 || w > 220) {
                                        return l10n.errPaperSizeRange;
                                      }
                                      return null;
                                    },
                                    onChanged: (val) {
                                      final w = int.tryParse(val) ?? 100;
                                      final h = int.tryParse(_customHeightController.text) ?? 150;
                                      cubit.updateCustomSize(w, h);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Cao (mm)',
                                    controller: _customHeightController,
                                    keyboardType: TextInputType.number,
                                    validator: (val) {
                                      final h = int.tryParse(val ?? '');
                                      if (h == null || h < 20 || h > 220) {
                                        return l10n.errPaperSizeRange;
                                      }
                                      return null;
                                    },
                                    onChanged: (val) {
                                      final w = int.tryParse(_customWidthController.text) ?? 100;
                                      final h = int.tryParse(val) ?? 150;
                                      cubit.updateCustomSize(w, h);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 2. Loại giấy
                          SectionHeader(title: l10n.paperType.toUpperCase()),
                          Wrap(
                            spacing: 16,
                            children: PaperType.values.map((type) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<PaperType>(
                                    value: type,
                                    groupValue: state.paperType,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => cubit.updatePaperType(val!),
                                  ),
                                  Text(type.name.toUpperCase()),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),

                          // Label gap configuration (only for label paper type)
                          if (state.paperType == PaperType.label) ...[
                            SectionHeader(title: 'KHE GIỮA CÁC LABEL (mm)'),
                            const SizedBox(height: 8),
                            CustomTextField(
                              label: 'Khe hở (mm)',
                              controller: _labelGapController,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                final gap = double.tryParse(val) ?? 0.0;
                                cubit.updateLabelGap(gap);
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 3. Hướng in
                          SectionHeader(title: l10n.orientation.toUpperCase()),
                          const SizedBox(height: 8),
                          SegmentedButton<Orientation>(
                            segments: [
                              ButtonSegment(value: Orientation.portrait, label: Text(l10n.portrait)),
                              ButtonSegment(value: Orientation.landscape, label: Text(l10n.landscape)),
                            ],
                            selected: {state.orientation},
                            onSelectionChanged: (selection) {
                              cubit.updateOrientation(selection.first);
                            },
                          ),
                          const SizedBox(height: 20),

                          // 4. Cài đặt lề
                          SectionHeader(title: 'Cài đặt lề'.toUpperCase()),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: l10n.marginTop,
                                  controller: _marginTopController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    final t = double.tryParse(val) ?? 0.0;
                                    final l = double.tryParse(_marginLeftController.text) ?? 0.0;
                                    final r = double.tryParse(_marginRightController.text) ?? 0.0;
                                    cubit.updateMargins(t, l, r);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  label: l10n.marginLeft,
                                  controller: _marginLeftController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    final t = double.tryParse(_marginTopController.text) ?? 0.0;
                                    final l = double.tryParse(val) ?? 0.0;
                                    final r = double.tryParse(_marginRightController.text) ?? 0.0;
                                    cubit.updateMargins(t, l, r);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  label: l10n.marginRight,
                                  controller: _marginRightController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    final t = double.tryParse(_marginTopController.text) ?? 0.0;
                                    final l = double.tryParse(_marginLeftController.text) ?? 0.0;
                                    final r = double.tryParse(val) ?? 0.0;
                                    cubit.updateMargins(t, l, r);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 5. Độ đậm (Density/Darkness)
                          SectionHeader(title: '${l10n.printDarkness}: ${state.printDarkness}'.toUpperCase()),
                          Slider(
                            value: state.printDarkness.toDouble(),
                            min: 1,
                            max: 15,
                            divisions: 14,
                            activeColor: AppColors.primary,
                            onChanged: (val) => cubit.updateDarkness(val.toInt()),
                          ),
                          const SizedBox(height: 12),

                          // 6. Tốc độ in (Print Speed)
                          SectionHeader(title: l10n.printSpeed.toUpperCase()),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<double>(
                            value: state.printSpeed,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: [2.0, 3.0, 4.0, 5.0, 6.0].map((speed) {
                              return DropdownMenuItem<double>(
                                value: speed,
                                child: Text('$speed ips'),
                              );
                            }).toList(),
                            onChanged: (val) => cubit.updateSpeed(val!),
                          ),
                          const SizedBox(height: 24),

                          // 7. Lưu thành bản mẫu
                          SectionHeader(title: 'LƯU THÀNH BẢN MẪU THIẾT KẾ'.toUpperCase()),
                          const SizedBox(height: 8),
                          CustomTextField(
                            label: l10n.templateName,
                            controller: _templateNameController,
                            hint: 'Ví dụ: Nhãn sản phẩm A',
                            onChanged: (val) => cubit.updateTemplateName(val),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
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
                    child: Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            text: l10n.saveAsTemplate,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                cubit.saveAsTemplate();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            text: l10n.saveConfig,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                cubit.saveConfig();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
