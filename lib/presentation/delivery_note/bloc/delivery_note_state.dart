import 'package:equatable/equatable.dart';
import '../../../domain/entities/delivery_note_item.dart';

class DeliveryNoteState extends Equatable {
  final String code;
  final String sender;
  final String receiver;
  final List<DeliveryNoteItem> items;
  final String? validationError;
  final bool isPrinting;
  final bool success;
  final String? errorMessage;

  const DeliveryNoteState({
    required this.code,
    required this.sender,
    required this.receiver,
    required this.items,
    this.validationError,
    this.isPrinting = false,
    this.success = false,
    this.errorMessage,
  });

  factory DeliveryNoteState.initial() {
    return DeliveryNoteState(
      // Tự sinh mã phiếu mặc định theo timestamp
      code: 'DN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      sender: '',
      receiver: '',
      items: const [
        DeliveryNoteItem(name: 'Sản phẩm mẫu A', quantity: 1, unit: 'Cái'),
      ],
    );
  }

  DeliveryNoteState copyWith({
    String? code,
    String? sender,
    String? receiver,
    List<DeliveryNoteItem>? items,
    String? Function()? validationError,
    bool? isPrinting,
    bool? success,
    String? Function()? errorMessage,
  }) {
    return DeliveryNoteState(
      code: code ?? this.code,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      items: items ?? this.items,
      validationError: validationError != null ? validationError() : this.validationError,
      isPrinting: isPrinting ?? this.isPrinting,
      success: success ?? this.success,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        code,
        sender,
        receiver,
        items,
        validationError,
        isPrinting,
        success,
        errorMessage,
      ];
}
