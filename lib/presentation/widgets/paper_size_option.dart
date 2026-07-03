import '../../domain/entities/enums/print_enums.dart';

/// Lớp helper đại diện cho một tùy chọn trong Dropdown chọn khổ giấy.
/// Có thể đại diện cho khổ giấy tiêu chuẩn hoặc bản mẫu tự lưu.
class PaperSizeOption {
  /// Khổ giấy tiêu chuẩn (null nếu là bản mẫu tự lưu)
  final PaperSize? paperSize;

  /// ID của bản mẫu (null nếu là khổ giấy tiêu chuẩn)
  final int? templateId;

  /// Tên hiển thị trên Dropdown
  final String displayName;

  /// Chiều rộng (mm) của bản mẫu
  final int? widthMm;

  /// Chiều cao (mm) của bản mẫu
  final int? heightMm;

  PaperSizeOption({
    this.paperSize,
    this.templateId,
    required this.displayName,
    this.widthMm,
    this.heightMm,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaperSizeOption &&
          runtimeType == other.runtimeType &&
          paperSize == other.paperSize &&
          templateId == other.templateId &&
          widthMm == other.widthMm &&
          heightMm == other.heightMm;

  @override
  int get hashCode =>
      paperSize.hashCode ^
      templateId.hashCode ^
      widthMm.hashCode ^
      heightMm.hashCode;
}
