import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../core/di/injection_container.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/preview_data.dart';
import '../../domain/entities/printer_config.dart';
import '../../domain/entities/enums/print_enums.dart' as print_enums;
import 'bloc/print_preview_cubit.dart';
import 'bloc/print_preview_state.dart';
import 'widgets/preview_canvas.dart';
import '../widgets/paper_size_option.dart';

class PrintPreviewScreen extends StatefulWidget {
  final PrinterConfig? initialConfig;
  final print_enums.DocumentType? documentType;
  final Uint8List? initialPreviewImage;
  final Map<String, dynamic>? extraData;

  const PrintPreviewScreen({
    super.key,
    this.initialConfig,
    this.documentType,
    this.initialPreviewImage,
    this.extraData,
  });

  @override
  State<PrintPreviewScreen> createState() => _PrintPreviewScreenState();
}

class _PrintPreviewScreenState extends State<PrintPreviewScreen> {
  Timer? _debounceTimer;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _marginTopController;
  late final TextEditingController _marginLeftController;
  late final TextEditingController _marginRightController;
  late final PrintPreviewCubit _cubit;
  PreviewData? _previewData;

  @override
  void initState() {
    super.initState();
    // Cấu hình mặc định
    final initialWidth = widget.initialConfig?.customWidthMm ?? 74;
    final initialHeight = widget.initialConfig?.customHeightMm ?? 105;
    final initialMarginTop = widget.initialConfig?.marginTop ?? 0.0;
    final initialMarginLeft = widget.initialConfig?.marginLeft ?? 0.0;
    final initialMarginRight = widget.initialConfig?.marginRight ?? 0.0;

    _widthController = TextEditingController(text: '$initialWidth');
    _heightController = TextEditingController(text: '$initialHeight');
    _marginTopController = TextEditingController(text: '$initialMarginTop');
    _marginLeftController = TextEditingController(text: '$initialMarginLeft');
    _marginRightController = TextEditingController(text: '$initialMarginRight');

    final defaultConfig = PrinterConfig(
      printerId: 0,
      paperSize: print_enums.PaperSize.A7, // Default to A7 matching dimensions (74x105mm)
      paperType: print_enums.PaperType.label,
      orientation: print_enums.Orientation.portrait,
      marginTop: 0.0,
      marginLeft: 0.0,
      marginRight: 0.0,
      printDarkness: 8,
      printSpeed: 4.0,
      scalingMode: print_enums.ScalingMode.fitWidth,
      scalingValue: 100,
      customWidthMm: 74,
      customHeightMm: 105,
    );

    final resolvedDocumentType = widget.documentType ?? () {
      if (widget.extraData != null && widget.extraData!.containsKey('documentType')) {
        final docTypeStr = widget.extraData!['documentType'] as String;
        return print_enums.DocumentType.values.firstWhere(
          (e) => e.name == docTypeStr,
          orElse: () => print_enums.DocumentType.receipt,
        );
      }
      return print_enums.DocumentType.receipt;
    }();

    if (widget.extraData != null) {
      try {
        _previewData = previewDataFromMap(widget.extraData!);
      } catch (e) {
        debugPrint('PrintPreviewScreen: Không thể parse extraData: $e');
      }
    }

    _cubit = PrintPreviewCubit(
      generatePreviewUsecase: sl(),
      getDefaultPrinterUsecase: sl(),
      getConfigUsecase: sl(),
      getAllTemplatesUsecase: sl(),
      printDocumentUsecase: sl(),
      initialConfig: widget.initialConfig ?? defaultConfig,
      documentType: resolvedDocumentType,
    );

    if (widget.initialPreviewImage != null) {
      _cubit.updatePreviewImage(widget.initialPreviewImage!);
    }

    // Load default printer config and generate preview immediately if extra data is provided
    if (_previewData != null) {
      _cubit.loadPrinterDefaultConfig(_previewData!);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _widthController.dispose();
    _heightController.dispose();
    _marginTopController.dispose();
    _marginLeftController.dispose();
    _marginRightController.dispose();
    super.dispose();
  }

  void _debouncedGeneratePreview(PrintPreviewCubit cubit) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_previewData != null) {
        cubit.generatePreview(_previewData!);
      }
    });
  }

  void _syncControllersWithConfig(PrinterConfig config) {
    final wVal = int.tryParse(_widthController.text);
    if (_widthController.text.isEmpty) {
      // Keep empty while typing
    } else if (wVal == null || wVal != config.customWidthMm) {
      _widthController.text = (config.customWidthMm ?? 74).toString();
    }

    final hVal = int.tryParse(_heightController.text);
    if (_heightController.text.isEmpty) {
      // Keep empty while typing
    } else if (hVal == null || hVal != config.customHeightMm) {
      _heightController.text = (config.customHeightMm ?? 105).toString();
    }

    final mtVal = double.tryParse(_marginTopController.text);
    if (_marginTopController.text.isEmpty) {
      // Keep empty while typing
    } else if (mtVal == null || mtVal != config.marginTop) {
      _marginTopController.text = config.marginTop.toString();
    }

    final mlVal = double.tryParse(_marginLeftController.text);
    if (_marginLeftController.text.isEmpty) {
      // Keep empty while typing
    } else if (mlVal == null || mlVal != config.marginLeft) {
      _marginLeftController.text = config.marginLeft.toString();
    }

    final mrVal = double.tryParse(_marginRightController.text);
    if (_marginRightController.text.isEmpty) {
      // Keep empty while typing
    } else if (mrVal == null || mrVal != config.marginRight) {
      _marginRightController.text = config.marginRight.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<PrintPreviewCubit>(
      create: (context) => _cubit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundSecondary,
        appBar: AppBar(
          title: const Text(
            'Xem trước & in tem',
            style: TextStyle(
              color: AppColors.onAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          elevation: 0,
          backgroundColor: AppColors.accent,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onAccent),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocConsumer<PrintPreviewCubit, PrintPreviewState>(
          listener: (context, state) {
            if (state.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.successPrintSent),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.read<PrintPreviewCubit>().resetSuccess();
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
            final cubit = context.read<PrintPreviewCubit>();
            final config = state.config;

            _syncControllersWithConfig(config);

            // Tính toán kích thước giấy theo cấu hình
            double paperWidthMm = config.paperSize.widthMm.toDouble();
            double paperHeightMm = config.paperSize.heightMm.toDouble();

            if (config.paperSize == print_enums.PaperSize.custom) {
              paperWidthMm = (config.customWidthMm ?? 74).toDouble();
              paperHeightMm = (config.customHeightMm ?? 105).toDouble();
            }

            if (config.paperType == print_enums.PaperType.continuous) {
              if (state.imageWidth > 0 && state.imageHeight > 0) {
                paperHeightMm = paperWidthMm * (state.imageHeight / state.imageWidth);
              }
            }


            // Đánh giá preset hiện tại
            final isCustom = config.paperSize == print_enums.PaperSize.custom;

            // Build paper size options including templates
            final List<PaperSizeOption> dropdownOptions = [
              PaperSizeOption(
                paperSize: print_enums.PaperSize.A5,
                displayName: 'A5 (148×210mm)',
              ),
              PaperSizeOption(
                paperSize: print_enums.PaperSize.A6,
                displayName: 'A6 (105×148mm)',
              ),
              PaperSizeOption(
                paperSize: print_enums.PaperSize.A7,
                displayName: 'A7 (74×105mm)',
              ),
              PaperSizeOption(
                paperSize: print_enums.PaperSize.A8,
                displayName: 'A8 (52×74mm)',
              ),
              PaperSizeOption(
                paperSize: print_enums.PaperSize.custom,
                displayName: 'Tùy chọn',
              ),
              ...state.templates.map((t) => PaperSizeOption(
                    templateId: t.id,
                    displayName: '${t.name} (${t.widthMm}×${t.heightMm}mm)',
                    widthMm: t.widthMm,
                    heightMm: t.heightMm,
                  )),
            ];

            // Find current selected option
            PaperSizeOption selectedOption;
            if (config.paperSize != print_enums.PaperSize.custom) {
              selectedOption = dropdownOptions.firstWhere(
                (opt) => opt.paperSize == config.paperSize,
                orElse: () => dropdownOptions[2], // fallback to A7
              );
            } else {
              // Custom size: check if matches any template dimensions
              selectedOption = dropdownOptions.firstWhere(
                (opt) =>
                    opt.templateId != null &&
                    opt.widthMm == config.customWidthMm &&
                    opt.heightMm == config.customHeightMm,
                orElse: () => dropdownOptions.firstWhere(
                  (opt) => opt.paperSize == print_enums.PaperSize.custom,
                ),
              );
            }

            return Stack(
              children: [
                Column(
                  children: [
                    // Canvas preview
                    Expanded(
                      child: Stack(
                        children: [
                          PreviewCanvas(
                            previewImage: state.previewImage,
                            marginTop: config.marginTop,
                            marginLeft: config.marginLeft,
                            marginRight: config.marginRight,
                            paperWidthMm: paperWidthMm,
                            paperHeightMm: paperHeightMm,
                            rotation: state.rotation,
                          ),
                          if (state.documentType == print_enums.DocumentType.pdf)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  color: AppColors.surface,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.navigate_before, color: AppColors.accent),
                                          onPressed: state.currentPage > 1 && _previewData is PdfPreviewData
                                              ? () => cubit.updatePdfPage(
                                                  state.currentPage - 1,
                                                  _previewData! as PdfPreviewData,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Trang ${state.currentPage} / ${state.totalPages}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.navigate_next, color: AppColors.accent),
                                          onPressed: state.currentPage < state.totalPages && _previewData is PdfPreviewData
                                              ? () => cubit.updatePdfPage(
                                                  state.currentPage + 1,
                                                  _previewData! as PdfPreviewData,
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                // Cấu hình in
                Flexible(
                  child: SingleChildScrollView(
                    child: Container(
                      color: AppColors.backgroundSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      // Khổ giấy Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Khổ giấy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 180,
                              child: DropdownButtonFormField<PaperSizeOption>(
                                value: selectedOption,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.background,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.divider),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.divider),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                                  ),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.onSurfaceVariant),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: [
                                  // Khổ tiêu chuẩn
                                  ...dropdownOptions
                                      .where((opt) => opt.templateId == null)
                                      .map((opt) => DropdownMenuItem<PaperSizeOption>(
                                            value: opt,
                                            child: Text(
                                              opt.displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )),
                                  // Section Header nếu có bản mẫu
                                  if (state.templates.isNotEmpty)
                                    const DropdownMenuItem<PaperSizeOption>(
                                      enabled: false,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Divider(height: 1, color: AppColors.shimmer),
                                          SizedBox(height: 4),
                                          Text(
                                            'BẢN MẪU CỦA TÔI',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Danh sách các bản mẫu
                                  ...dropdownOptions
                                      .where((opt) => opt.templateId != null)
                                      .map((opt) => DropdownMenuItem<PaperSizeOption>(
                                            value: opt,
                                            child: Text(
                                              opt.displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    if (val.paperSize != null) {
                                      cubit.updatePaperSize(val.paperSize!);
                                    } else if (val.templateId != null) {
                                      cubit.updatePaperSizeAndCustomDimensions(
                                        print_enums.PaperSize.custom,
                                        width: val.widthMm,
                                        height: val.heightMm,
                                      );
                                    }
                                    _debouncedGeneratePreview(cubit);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Custom inputs (only shown if Custom is selected)
                      if (isCustom) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _widthController,
                                  decoration: InputDecoration(
                                    labelText: 'Rộng (mm)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    final w = int.tryParse(val);
                                    if (w != null) {
                                      cubit.updatePaperSizeAndCustomDimensions(
                                        print_enums.PaperSize.custom,
                                        width: w,
                                      );
                                      _debouncedGeneratePreview(cubit);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _heightController,
                                  decoration: InputDecoration(
                                    labelText: 'Cao (mm)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    final h = int.tryParse(val);
                                    if (h != null) {
                                      cubit.updatePaperSizeAndCustomDimensions(
                                        print_enums.PaperSize.custom,
                                        height: h,
                                      );
                                      _debouncedGeneratePreview(cubit);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Loại giấy Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Loại giấy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 180,
                              child: DropdownButtonFormField<print_enums.PaperType>(
                                value: config.paperType,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.background,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.divider),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.divider),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                                  ),
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.onSurfaceVariant),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: print_enums.PaperType.label,
                                    child: Text('Giấy nhãn (Label)'),
                                  ),
                                  DropdownMenuItem(
                                    value: print_enums.PaperType.continuous,
                                    child: Text('Giấy liên tục (Continuous)'),
                                  ),
                                  DropdownMenuItem(
                                    value: print_enums.PaperType.blackMark,
                                    child: Text('Giấy có vạch đen (Black Mark)'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    cubit.updatePaperType(val);
                                    _debouncedGeneratePreview(cubit);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Hướng in Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              l10n.orientation,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                _buildOrientationButton(
                                  rotation: 0,
                                  activeRotation: state.rotation,
                                  icon: Icons.text_rotation_none,
                                  onTap: () {
                                    cubit.updateRotation(0);
                                    _debouncedGeneratePreview(cubit);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildOrientationButton(
                                  rotation: 90,
                                  activeRotation: state.rotation,
                                  icon: Icons.text_rotation_down,
                                  onTap: () {
                                    cubit.updateRotation(90);
                                    _debouncedGeneratePreview(cubit);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildOrientationButton(
                                  rotation: 180,
                                  activeRotation: state.rotation,
                                  icon: Icons.text_rotation_none,
                                  rotated: true,
                                  onTap: () {
                                    cubit.updateRotation(180);
                                    _debouncedGeneratePreview(cubit);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildOrientationButton(
                                  rotation: 270,
                                  activeRotation: state.rotation,
                                  icon: Icons.text_rotation_down,
                                  rotated: true,
                                  onTap: () {
                                    cubit.updateRotation(270);
                                    _debouncedGeneratePreview(cubit);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Cài đặt lề Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cài đặt lề (mm)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _marginTopController,
                                    decoration: InputDecoration(
                                      labelText: l10n.marginTop,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (val) {
                                      final t = double.tryParse(val);
                                      if (t != null) {
                                        cubit.updateMargins(top: t);
                                        _debouncedGeneratePreview(cubit);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _marginLeftController,
                                    decoration: InputDecoration(
                                      labelText: l10n.marginLeft,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (val) {
                                      final l = double.tryParse(val);
                                      if (l != null) {
                                        cubit.updateMargins(left: l);
                                        _debouncedGeneratePreview(cubit);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _marginRightController,
                                    decoration: InputDecoration(
                                      labelText: l10n.marginRight,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (val) {
                                      final r = double.tryParse(val);
                                      if (r != null) {
                                        cubit.updateMargins(right: r);
                                        _debouncedGeneratePreview(cubit);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Độ đậm Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Độ đậm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.accent,
                                  inactiveTrackColor: AppColors.backgroundSecondary,
                                  thumbColor: AppColors.accent,
                                  overlayColor: AppColors.accent.withValues(alpha: 0.12),
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                ),
                                child: Slider(
                                  value: config.printDarkness.toDouble(),
                                  min: 1,
                                  max: 15,
                                  divisions: 14,
                                  onChanged: (val) {
                                    cubit.updateDarkness(val.toInt());
                                    _debouncedGeneratePreview(cubit);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildDarknessButton(
                                    icon: Icons.remove,
                                    onTap: config.printDarkness > 1
                                        ? () {
                                            cubit.updateDarkness(config.printDarkness - 1);
                                            _debouncedGeneratePreview(cubit);
                                          }
                                        : null,
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${config.printDarkness}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  _buildDarknessButton(
                                    icon: Icons.add,
                                    onTap: config.printDarkness < 15
                                        ? () {
                                            cubit.updateDarkness(config.printDarkness + 1);
                                            _debouncedGeneratePreview(cubit);
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Số bản sao Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Số bản sao',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildDarknessButton(
                                    icon: Icons.remove,
                                    onTap: state.copies > 1
                                        ? () {
                                            cubit.updateCopies(state.copies - 1);
                                          }
                                        : null,
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${state.copies}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  _buildDarknessButton(
                                    icon: Icons.add,
                                    onTap: () {
                                      cubit.updateCopies(state.copies + 1);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom bar
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
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (state.previewImage == null || state.isPrinting)
                          ? null
                          : () {
                              cubit.printCurrentDocument();
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.print, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'In ngay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (state.isPrinting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Đang in tài liệu...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
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


  Widget _buildOrientationButton({
    required int rotation,
    required int activeRotation,
    required IconData icon,
    bool rotated = false,
    required VoidCallback onTap,
  }) {
    final isSelected = rotation == activeRotation;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: rotated
              ? RotatedBox(
                  quarterTurns: 2,
                  child: Icon(
                    icon,
                    color: isSelected ? AppColors.onAccent : AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                )
              : Icon(
                  icon,
                  color: isSelected ? AppColors.onAccent : AppColors.onSurfaceVariant,
                  size: 20,
                ),
        ),
      ),
    );
  }

  Widget _buildDarknessButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.surfaceVariant.withValues(alpha: 0.5) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDisabled ? AppColors.shimmer : AppColors.onSurface,
          size: 20,
        ),
      ),
    );
  }
}
