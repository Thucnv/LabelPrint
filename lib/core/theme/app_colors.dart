import 'package:flutter/material.dart';

/// Bảng màu "Industrial Precision" cho ứng dụng Label Print.
///
/// Thiết kế chuyên dụng cho môi trường thương mại, giao vận.
/// Sử dụng tông màu Indigo làm điểm nhấn trên nền Slate nhẹ nhàng.
///
/// KHÔNG sử dụng mã màu Hex trực tiếp trong Widget.
/// Luôn gọi qua [AppColors.primary], [AppColors.background], v.v.
abstract final class AppColors {
  // ─── PRIMARY (Indigo) ─────────────────────────────────────
  /// Indigo 600 - Nút hành động chính, link, active tab
  static const Color primary = Color(0xFF4F46E5);

  /// Indigo 400 - Hover state, gradient start
  static const Color primaryLight = Color(0xFF818CF8);

  /// Indigo 800 - Pressed state, darker accent
  static const Color primaryDark = Color(0xFF3730A3);

  /// White - Text trên nền primary
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ─── SURFACE & BACKGROUND (Slate) ─────────────────────────
  /// Slate 50 - Nền sáng chính của toàn app
  static const Color background = Color(0xFFF8FAFC);

  /// White - Nền Card, Dialog, BottomSheet
  static const Color surface = Color(0xFFFFFFFF);

  /// Slate 100 - Nền phụ, section background
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // ─── TEXT (Slate) ─────────────────────────────────────────
  /// Slate 800 - Text chính (tiêu đề, body text)
  static const Color onSurface = Color(0xFF1E293B);

  /// Slate 500 - Text phụ (caption, hint, placeholder)
  static const Color onSurfaceVariant = Color(0xFF64748B);

  // ─── DIVIDER & BORDER ─────────────────────────────────────
  /// Slate 200 - Đường kẻ phân cách, border input
  static const Color divider = Color(0xFFE2E8F0);

  /// Slate 300 - Shimmer loading, disabled state
  static const Color shimmer = Color(0xFFCBD5E1);

  // ─── SEMANTIC COLORS ──────────────────────────────────────
  /// Green 600 - Trạng thái thành công, máy in Sẵn sàng
  static const Color success = Color(0xFF16A34A);

  /// Amber 500 - Cảnh báo, trạng thái Chưa cấu hình
  static const Color warning = Color(0xFFF59E0B);

  /// Red 600 - Lỗi, trạng thái mất kết nối
  static const Color error = Color(0xFFDC2626);

  /// Slate 400 - Trạng thái Chờ (Idle)
  static const Color statusIdle = Color(0xFF94A3B8);

  // ─── GRADIENT ─────────────────────────────────────────────
  /// Gradient cho nút bấm chính (PrimaryButton)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
