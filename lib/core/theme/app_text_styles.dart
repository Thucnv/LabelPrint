import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens cho ứng dụng Label Print.
///
/// Sử dụng Google Font **Inter** - hỗ trợ tiếng Việt sắc nét,
/// phù hợp với giao diện công nghiệp/thương mại.
///
/// KHÔNG sử dụng TextStyle trực tiếp trong Widget.
/// Luôn gọi qua [AppTextStyles.headingLg], [AppTextStyles.bodyMd], v.v.
abstract final class AppTextStyles {
  // ─── HEADINGS ─────────────────────────────────────────────

  /// 24sp, Bold - Tiêu đề màn hình chính
  static TextStyle headingLg = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    height: 1.3,
  );

  /// 20sp, SemiBold - Tiêu đề phân mục, dialog
  static TextStyle headingMd = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.3,
  );

  /// 16sp, SemiBold - Tiêu đề card, section header
  static TextStyle headingSm = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.4,
  );

  // ─── BODY ─────────────────────────────────────────────────

  /// 16sp, Regular - Nội dung chính
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  /// 14sp, Regular - Nội dung phụ, mô tả
  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  /// 12sp, Regular - Caption, ghi chú, metadata
  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
    height: 1.4,
  );

  // ─── INTERACTIVE ──────────────────────────────────────────

  /// 14sp, SemiBold - Text nút bấm (Button)
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// 12sp, Medium - Nhãn trường nhập liệu (Label)
  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
    height: 1.3,
    letterSpacing: 0.3,
  );
}
