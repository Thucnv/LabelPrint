import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Nút bấm phụ với viền outlined và background trong suốt.
///
/// Phong cách đồng bộ với [PrimaryButton] nhưng ở mức nhấn mạnh thấp hơn.
/// Sử dụng cho các hành động phụ: hủy, quay lại, tùy chọn phụ.
///
/// Ví dụ:
/// ```dart
/// SecondaryButton(
///   text: 'Hủy',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class SecondaryButton extends StatefulWidget {
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

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isPressed = false;

  /// Xác định nút có đang active (có thể nhấn) hay không.
  bool get _isActive => !widget.isLoading && widget.onPressed != null;

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
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isActive
                    ? AppColors.primary
                    : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isActive ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(12),
                splashColor: AppColors.primary.withValues(alpha: 0.08),
                highlightColor: AppColors.primary.withValues(alpha: 0.04),
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
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    // Nội dung text + icon
    final textColor =
        _isActive ? AppColors.primary : AppColors.onSurfaceVariant;

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
