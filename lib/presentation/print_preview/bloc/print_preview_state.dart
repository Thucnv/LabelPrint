import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/enums/print_enums.dart';
import '../../../domain/entities/printer_config.dart';
import '../../../domain/entities/template.dart';

/// State cho màn hình Xem trước bản in (Print Preview).
class PrintPreviewState extends Equatable {
  /// Cấu hình in hiện tại
  final PrinterConfig config;

  /// Loại tài liệu đang xem trước
  final DocumentType documentType;

  /// Ảnh preview (Uint8List từ bitmap)
  final Uint8List? previewImage;

  /// Đang tải preview
  final bool isLoading;

  /// Đang in
  final bool isPrinting;

  /// Thông báo lỗi
  final String? errorMessage;

  /// Thông báo thành công
  final bool success;

  /// Số bản sao
  final int copies;

  /// Hướng xoay (0, 90, 180, 270 độ)
  final int rotation;

  /// Danh sách các bản mẫu đã lưu
  final List<Template> templates;

  /// Trang hiện tại (chỉ dùng khi documentType là PDF)
  final int currentPage;

  /// Tổng số trang (chỉ dùng khi documentType là PDF)
  final int totalPages;

  /// Chiều rộng thực tế của hình ảnh xem trước kết xuất được (pixels)
  final int imageWidth;

  /// Chiều cao thực tế của hình ảnh xem trước kết xuất được (pixels)
  final int imageHeight;

  const PrintPreviewState({
    required this.config,
    this.documentType = DocumentType.barcode,
    this.previewImage,
    this.isLoading = false,
    this.isPrinting = false,
    this.errorMessage,
    this.success = false,
    this.copies = 1,
    this.rotation = 0,
    this.templates = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  PrintPreviewState copyWith({
    PrinterConfig? config,
    DocumentType? documentType,
    Uint8List? previewImage,
    bool? isLoading,
    bool? isPrinting,
    String? errorMessage,
    bool? success,
    int? copies,
    int? rotation,
    List<Template>? templates,
    int? currentPage,
    int? totalPages,
    int? imageWidth,
    int? imageHeight,
  }) {
    return PrintPreviewState(
      config: config ?? this.config,
      documentType: documentType ?? this.documentType,
      previewImage: previewImage ?? this.previewImage,
      isLoading: isLoading ?? this.isLoading,
      isPrinting: isPrinting ?? this.isPrinting,
      errorMessage: errorMessage,
      success: success ?? this.success,
      copies: copies ?? this.copies,
      rotation: rotation ?? this.rotation,
      templates: templates ?? this.templates,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
    );
  }

  @override
  List<Object?> get props => [
        config,
        documentType,
        previewImage,
        isLoading,
        isPrinting,
        errorMessage,
        success,
        copies,
        rotation,
        templates,
        currentPage,
        totalPages,
        imageWidth,
        imageHeight,
      ];
}
