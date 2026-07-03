import 'package:equatable/equatable.dart';

import '../../../domain/entities/enums/barcode_type.dart';

abstract class BarcodeEvent extends Equatable {
  const BarcodeEvent();

  @override
  List<Object?> get props => [];
}

class BarcodeDataChanged extends BarcodeEvent {
  final String data;

  const BarcodeDataChanged(this.data);

  @override
  List<Object?> get props => [data];
}

class BarcodeTypeChanged extends BarcodeEvent {
  final BarcodeType type;

  const BarcodeTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class BarcodeHeightChanged extends BarcodeEvent {
  final double height;

  const BarcodeHeightChanged(this.height);

  @override
  List<Object?> get props => [height];
}

class BarcodeShowTextChanged extends BarcodeEvent {
  final bool showText;

  const BarcodeShowTextChanged(this.showText);

  @override
  List<Object?> get props => [showText];
}

class PrintBarcodeRequested extends BarcodeEvent {}
