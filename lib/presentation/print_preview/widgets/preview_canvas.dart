import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Widget Canvas hiển thị preview bản in với hỗ trợ zoom và pan.
///
/// Theo BRD 4.3:
/// - Hiển thị đường viền nét đứt đại diện lề không thể in
/// - Hỗ trợ pinch-to-zoom lên tới 300%
/// - Hỗ trợ pan để di chuyển khu vực hiển thị
class PreviewCanvas extends StatefulWidget {
  /// Ảnh preview (Uint8List từ bitmap)
  final Uint8List? previewImage;

  /// Lề trên (mm)
  final double marginTop;

  /// Lề trái (mm)
  final double marginLeft;

  /// Lề phải (mm)
  final double marginRight;

  /// Chiều rộng giấy (mm)
  final double paperWidthMm;

  /// Chiều cao giấy (mm)
  final double paperHeightMm;

  /// Hướng xoay (0, 90, 180, 270)
  final int rotation;

  const PreviewCanvas({
    super.key,
    required this.previewImage,
    required this.marginTop,
    required this.marginLeft,
    required this.marginRight,
    required this.paperWidthMm,
    required this.paperHeightMm,
    this.rotation = 0,
  });

  @override
  State<PreviewCanvas> createState() => _PreviewCanvasState();
}

class _PreviewCanvasState extends State<PreviewCanvas> {
  final TransformationController _transformationController =
      TransformationController();

  String _fmtMmToInch(double mm) {
    final val = mm / 25.4;
    final rounded = (val * 10).round() / 10;
    if (rounded == rounded.toInt()) {
      return rounded.toInt().toString();
    }
    return rounded.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF3F8), // Match design light grey-blue background
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate dynamic scale factor to make the preview card auto-scale
          // and fit the screen available bounds.
          final availableWidth = constraints.maxWidth - 80;
          final availableHeight = constraints.maxHeight - 70;
          
          final double scale = math.min(
            availableWidth / widget.paperWidthMm,
            availableHeight / widget.paperHeightMm,
          ).clamp(0.1, 10.0);

          return InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 3.0, // Tối đa 300% theo BRD
            onInteractionEnd: (details) {
              // Reset scale về 1.0 khi zoom quá nhỏ
              if (_transformationController.value.getMaxScaleOnAxis() < 0.5) {
                _transformationController.value = Matrix4.identity();
              }
            },
            child: Center(
              child: Stack(
                clipBehavior: Clip.none, // Allow labels to draw outside card bounds without clipping
                children: [
                  // The centered paper card itself
                  Container(
                    width: widget.paperWidthMm * scale,
                    height: widget.paperHeightMm * scale,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0), // Soft grey border (Slate 300)
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Ảnh preview nội dung
                        if (widget.previewImage != null && widget.previewImage!.isNotEmpty)
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: widget.marginTop * scale,
                                left: widget.marginLeft * scale,
                                right: widget.marginRight * scale,
                              ),
                              child: RotatedBox(
                                quarterTurns: widget.rotation ~/ 90,
                                child: Image.memory(
                                  widget.previewImage!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          )
                        else
                          const Center(
                            child: Text(
                              'Chưa có preview',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        // Đường viền nét đứt đại diện lề không thể in (chỉ vẽ nếu lề > 0)
                        if (widget.marginTop > 0 || widget.marginLeft > 0 || widget.marginRight > 0)
                          Positioned(
                            top: widget.marginTop * scale,
                            left: widget.marginLeft * scale,
                            right: widget.marginRight * scale,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.3),
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Top Label: positioned above the card
                  Positioned(
                    top: -24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        '${_fmtMmToInch(widget.paperWidthMm)} in',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  // Right Label: positioned to the right of the card
                  Positioned(
                    right: -32, // Positioned outside the right border within the gap
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          '${_fmtMmToInch(widget.paperHeightMm)} in',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
