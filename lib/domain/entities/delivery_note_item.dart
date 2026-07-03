import 'package:equatable/equatable.dart';

/// Thực thể đại diện cho một sản phẩm trong Phiếu giao hàng.
class DeliveryNoteItem extends Equatable {
  final String name;
  final int quantity;
  final String unit;

  const DeliveryNoteItem({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  DeliveryNoteItem copyWith({
    String? name,
    int? quantity,
    String? unit,
  }) {
    return DeliveryNoteItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  List<Object?> get props => [name, quantity, unit];
}
