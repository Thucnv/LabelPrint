import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Nút bấm chính với gradient background từ primaryLight đến primary.
///
/// Hỗ trợ:
/// - Full-width hoặc flexible (wrap content)
/// - Icon phía trước text
/// - Trạng thái loading với CircularProgressIndicator
/// - Micro-animation scale 0.97 khi nhấn
/// - Trạng thái disabled
///
/// Ví dụ:
/// ```dart
/// PrimaryButton(
///   text: 'In ngay',
///   icon: Icons.print,
///   onPressed: () => _handlePrint(),
///   isLoading: _isPrinting,
/// )
/// ```
class PrimaryButton extends StatefulWidget {
  /// Text hiển thị trên nút.
  final String text;

  /// Callback khi nút được nhấn.
  final VoidCallback? onPressed;

  /// Hiển thị loading indicator thay vì text.
  final bool isLoading;

  /// Icon hiển thị phía trước text.
  final IconData? icon;

  /// Nếu true, nút chiếm toàn bộ chiều rộng.
  final bool isFullWidth;

  /// Nếu true, nút ở trạng thái disabled.
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.isDisabled = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  /// Xác định nút có đang active (có thể nhấn) hay không.
  bool get _isActive =>
      !widget.isLoading && !widget.isDisabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: SizedBox(
        width: widget.isFullWidth ? double.infinity : null,
        height: 48,
        child: GestureDetector(
          onTapDown: _isActive ? (_) => _setPressed(true) : null,
          onTapUp: _isActive ? (_) => _setPressed(false) : null,
          onTapCancel: _isActive ? () => _setPressed(false) : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: _isActive
                  ? const LinearGradient(
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _isActive ? null : AppColors.divider,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isActive ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(12),
                splashColor: AppColors.onPrimary.withValues(alpha: 0.12),
                highlightColor: AppColors.onPrimary.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Trạng thái loading
    if (widget.isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
        ),
      );
    }

    // Nội dung text + icon
    final textColor =
        _isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant;

    if (widget.icon != null) {
      return Row(
        mainAxisSize:
            widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: AppTextStyles.button.copyWith(color: textColor),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: AppTextStyles.button.copyWith(color: textColor),
    );
  }

  void _setPressed(bool pressed) {
    setState(() => _isPressed = pressed);
  }
}
