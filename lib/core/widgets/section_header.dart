import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tiêu đề section đơn giản với trailing widget tùy chọn.
///
/// Sử dụng cho các nhóm nội dung trong form, danh sách, settings.
///
/// Ví dụ:
/// ```dart
/// SectionHeader(
///   title: 'Cấu hình in',
///   trailing: IconButton(
///     icon: Icon(Icons.info_outline),
///     onPressed: () => _showInfo(),
///   ),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  /// Tiêu đề section.
  final String title;

  /// Widget hiển thị ở phía phải (icon button, badge, ...).
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headingSm,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
