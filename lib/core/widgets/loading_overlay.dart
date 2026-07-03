import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Overlay toàn màn hình bán trong suốt với loading indicator.
///
/// Sử dụng Stack để đặt overlay lên trên nội dung hiện tại.
/// Có animation fade in/out mượt mà.
///
/// Ví dụ:
/// ```dart
/// Stack(
///   children: [
///     // Nội dung chính
///     Scaffold(...),
///
///     // Loading overlay
///     LoadingOverlay(isLoading: _isProcessing),
///   ],
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Hiển thị overlay hay không.
  final bool isLoading;

  /// Màu nền overlay (mặc định đen 40% opacity).
  final Color? backgroundColor;

  /// Widget loading tùy chỉnh (mặc định CircularProgressIndicator).
  final Widget? loadingWidget;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.backgroundColor,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Chặn tương tác khi đang loading
      ignoring: !isLoading,
      child: AnimatedOpacity(
        opacity: isLoading ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          color: backgroundColor ??
              AppColors.onSurface.withValues(alpha: 0.4),
          child: Center(
            child: loadingWidget ??
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
