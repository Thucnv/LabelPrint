import 'package:equatable/equatable.dart';

import 'delivery_note_item.dart';
import 'enums/barcode_type.dart';

/// Sealed class đại diện cho dữ liệu preview của các loại tài liệu in.
///
/// Thay thế `Map<String, dynamic>` để đảm bảo type safety tại compile time.
/// Mỗi subclass chứa đúng các trường cần thiết cho loại tài liệu tương ứng.
sealed class PreviewData extends Equatable {
  const PreviewData();
}

/// Dữ liệu preview cho ảnh từ file path hoặc bytes trực tiếp.
class ImagePreviewData extends PreviewData {
  /// Đường dẫn đến file ảnh trên thiết bị.
  final String? imagePath;

  /// Bytes ảnh nếu không dùng file path.
  final List<int>? imageBytes;

  const ImagePreviewData({this.imagePath, this.imageBytes})
      : assert(
          imagePath != null || imageBytes != null,
          'imagePath hoặc imageBytes phải được cung cấp',
        );

  @override
  List<Object?> get props => [imagePath, imageBytes];
}

/// Dữ liệu preview cho tài liệu PDF từ file path.
class PdfPreviewData extends PreviewData {
  /// Đường dẫn đến file PDF trên thiết bị.
  final String pdfPath;

  /// Số trang cần hiển thị (bắt đầu từ 1).
  final int pageNumber;

  const PdfPreviewData({
    required this.pdfPath,
    this.pageNumber = 1,
  });

  /// Tạo bản sao với số trang mới.
  PdfPreviewData copyWithPage(int newPage) =>
      PdfPreviewData(pdfPath: pdfPath, pageNumber: newPage);

  @override
  List<Object?> get props => [pdfPath, pageNumber];
}

/// Dữ liệu preview cho mã vạch (Barcode / QR Code).
class BarcodePreviewData extends PreviewData {
  /// Nội dung mã vạch.
  final String data;

  /// Loại mã vạch.
  final BarcodeType type;

  /// Chiều cao của mã vạch (pixels/dots).
  final double height;

  /// Hiển thị text số bên dưới mã vạch.
  final bool showText;

  const BarcodePreviewData({
    required this.data,
    this.type = BarcodeType.code128,
    this.height = 100.0,
    this.showText = true,
  });

  @override
  List<Object?> get props => [data, type, height, showText];
}

/// Dữ liệu preview cho phiếu giao hàng.
class DeliveryNotePreviewData extends PreviewData {
  /// Số phiếu giao hàng.
  final String code;

  /// Tên người gửi.
  final String sender;

  /// Tên người nhận.
  final String receiver;

  /// Danh sách sản phẩm.
  final List<DeliveryNoteItem> items;

  const DeliveryNotePreviewData({
    this.code = '',
    this.sender = '',
    this.receiver = '',
    this.items = const [],
  });

  @override
  List<Object?> get props => [code, sender, receiver, items];
}

/// Parse `Map<String, dynamic>` (từ GoRouter extra) thành [PreviewData].
///
/// Dùng ở tầng presentation (Screen) để convert dữ liệu từ router thành
/// typed object trước khi truyền vào Cubit/UseCase.
///
/// Throws [ArgumentError] nếu `documentType` không hợp lệ hoặc thiếu dữ liệu.
PreviewData previewDataFromMap(Map<String, dynamic> map) {
  final docType = map['documentType'] as String? ?? '';

  switch (docType) {
    case 'image':
      return ImagePreviewData(
        imagePath: map['imagePath'] as String?,
        imageBytes: map['imageBytes'] as List<int>?,
      );

    case 'pdf':
      final pdfPath = map['pdfPath'] as String?;
      if (pdfPath == null || pdfPath.isEmpty) {
        throw ArgumentError('pdfPath không được để trống cho documentType=pdf');
      }
      return PdfPreviewData(
        pdfPath: pdfPath,
        pageNumber: map['pageNumber'] as int? ?? 1,
      );

    case 'barcode':
      final barcodeData = map['barcodeData'] as Map<String, dynamic>?;
      if (barcodeData == null) {
        throw ArgumentError('barcodeData không được null cho documentType=barcode');
      }
      return BarcodePreviewData(
        data: barcodeData['data'] as String? ?? '',
        type: barcodeData['type'] is BarcodeType
            ? barcodeData['type'] as BarcodeType
            : BarcodeType.code128,
        height: (barcodeData['height'] as num?)?.toDouble() ?? 100.0,
        showText: barcodeData['showText'] as bool? ?? true,
      );

    case 'deliveryNote':
      final dnData = map['deliveryNoteData'] as Map<String, dynamic>?;
      if (dnData == null) {
        throw ArgumentError(
            'deliveryNoteData không được null cho documentType=deliveryNote');
      }
      final rawItems = dnData['items'] as List<dynamic>? ?? [];
      final items = rawItems.map((e) {
        final itemMap = e as Map<String, dynamic>;
        return DeliveryNoteItem(
          name: itemMap['name'] as String? ?? '',
          quantity: (itemMap['quantity'] as num?)?.toInt() ?? 0,
          unit: itemMap['unit'] as String? ?? '',
        );
      }).toList();

      return DeliveryNotePreviewData(
        code: dnData['code'] as String? ?? '',
        sender: dnData['sender'] as String? ?? '',
        receiver: dnData['receiver'] as String? ?? '',
        items: items,
      );

    default:
      throw ArgumentError('Loại tài liệu không hợp lệ: $docType');
  }
}
