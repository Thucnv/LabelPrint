import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/delivery_note_item.dart';
import 'delivery_note_state.dart';

class DeliveryNoteCubit extends Cubit<DeliveryNoteState> {
  DeliveryNoteCubit() : super(DeliveryNoteState.initial()) {
    validate();
  }

  void updateCode(String code) {
    emit(state.copyWith(code: code));
    validate();
  }

  void updateSender(String sender) {
    emit(state.copyWith(sender: sender));
    validate();
  }

  void updateReceiver(String receiver) {
    emit(state.copyWith(receiver: receiver));
    validate();
  }

  void addItem() {
    final updatedItems = List<DeliveryNoteItem>.from(state.items)
      ..add(const DeliveryNoteItem(name: '', quantity: 1, unit: 'Cái'));
    emit(state.copyWith(items: updatedItems));
    validate();
  }

  void removeItem(int index) {
    if (index >= 0 && index < state.items.length) {
      final updatedItems = List<DeliveryNoteItem>.from(state.items)..removeAt(index);
      emit(state.copyWith(items: updatedItems));
      validate();
    }
  }

  void updateItemName(int index, String name) {
    if (index >= 0 && index < state.items.length) {
      final updatedItems = List<DeliveryNoteItem>.from(state.items);
      updatedItems[index] = updatedItems[index].copyWith(name: name);
      emit(state.copyWith(items: updatedItems));
      validate();
    }
  }

  void updateItemQuantity(int index, int quantity) {
    if (index >= 0 && index < state.items.length) {
      final updatedItems = List<DeliveryNoteItem>.from(state.items);
      updatedItems[index] = updatedItems[index].copyWith(quantity: quantity);
      emit(state.copyWith(items: updatedItems));
      validate();
    }
  }

  void updateItemUnit(int index, String unit) {
    if (index >= 0 && index < state.items.length) {
      final updatedItems = List<DeliveryNoteItem>.from(state.items);
      updatedItems[index] = updatedItems[index].copyWith(unit: unit);
      emit(state.copyWith(items: updatedItems));
      validate();
    }
  }

  void validate() {
    if (state.code.trim().isEmpty) {
      emit(state.copyWith(validationError: () => 'Mã phiếu giao hàng không được để trống'));
      return;
    }
    if (state.sender.trim().isEmpty) {
      emit(state.copyWith(validationError: () => 'Tên người gửi không được để trống'));
      return;
    }
    if (state.receiver.trim().isEmpty) {
      emit(state.copyWith(validationError: () => 'Tên người nhận không được để trống'));
      return;
    }
    if (state.items.isEmpty) {
      emit(state.copyWith(validationError: () => 'Phiếu giao hàng phải có ít nhất 1 sản phẩm'));
      return;
    }

    // Kiểm tra xem có sản phẩm nào trống tên không
    for (int i = 0; i < state.items.length; i++) {
      if (state.items[i].name.trim().isEmpty) {
        emit(state.copyWith(validationError: () => 'Tên sản phẩm ở dòng ${i + 1} không được để trống'));
        return;
      }
      if (state.items[i].quantity <= 0) {
        emit(state.copyWith(validationError: () => 'Số lượng ở dòng ${i + 1} phải lớn hơn 0'));
        return;
      }
      if (state.items[i].unit.trim().isEmpty) {
        emit(state.copyWith(validationError: () => 'Đơn vị tính ở dòng ${i + 1} không được để trống'));
        return;
      }
    }

    emit(state.copyWith(validationError: () => null));
  }
}
