import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Widget text field tái sử dụng với thiết kế nhất quán.
///
/// Tuân theo Design System của app:
/// - Viền bo tròn 12px
/// - Màu viền [AppColors.divider], focus [AppColors.primary]
/// - Label sử dụng [AppTextStyles.label]
///
/// Ví dụ:
/// ```dart
/// CustomTextField(
///   label: 'Tên máy in',
///   hint: 'Nhập tên máy in...',
///   controller: _nameController,
///   validator: (value) => value?.isEmpty == true ? 'Bắt buộc' : null,
/// )
/// ```
class CustomTextField extends StatelessWidget {
  /// Nhãn hiển thị phía trên text field.
  final String? label;

  /// Gợi ý hiển thị khi field trống.
  final String? hint;

  /// Text lỗi hiển thị bên dưới field.
  final String? errorText;

  /// Loại bàn phím (text, number, email, ...).
  final TextInputType? keyboardType;

  /// Icon hiển thị ở cuối field.
  final Widget? suffixIcon;

  /// Icon hiển thị ở đầu field.
  final Widget? prefixIcon;

  /// Controller để quản lý text.
  final TextEditingController? controller;

  /// Hàm validate giá trị nhập.
  final String? Function(String?)? validator;

  /// Cho phép chỉnh sửa hay không.
  final bool enabled;

  /// Số ký tự tối đa.
  final int? maxLength;

  /// Callback khi giá trị thay đổi.
  final ValueChanged<String>? onChanged;

  /// Ẩn nội dung nhập (cho password).
  final bool obscureText;

  /// Danh sách input formatters tùy chỉnh.
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node để quản lý focus.
  final FocusNode? focusNode;

  /// Số dòng tối đa hiển thị.
  final int maxLines;

  /// Text hành động trên bàn phím (done, next, ...).
  final TextInputAction? textInputAction;

  /// Callback khi nhấn nút submit trên bàn phím.
  final ValueChanged<String>? onFieldSubmitted;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
    this.validator,
    this.enabled = true,
    this.maxLength,
    this.onChanged,
    this.obscureText = false,
    this.inputFormatters,
    this.focusNode,
    this.maxLines = 1,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label phía trên field
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.label.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
        ],

        // Text field chính
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          maxLength: maxLength,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.bodySm.copyWith(
              color: AppColors.error,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            counterText: '', // Ẩn counter mặc định
            filled: true,
            fillColor: enabled
                ? AppColors.surface
                : AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
