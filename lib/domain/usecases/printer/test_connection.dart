import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/printer_sender.dart';
import '../../entities/enums/printer_enums.dart';
import '../../entities/printer.dart';
import '../usecase.dart';

/// Usecase thực hiện kết nối thử nghiệm tới máy in và in thử một trang nhãn/hóa đơn mẫu.
class TestConnection implements UseCase<void, Printer> {
  @override
  Future<Either<Failure, void>> call(Printer printer) async {
    try {
      final Uint8List testBytes;

      // Sinh tập lệnh in thử dựa trên giao thức của máy in
      if (printer.protocol == PrinterProtocol.tspl) {
        final testCommand = 'SIZE 50 mm, 30 mm\r\n'
            'GAP 3 mm, 0 mm\r\n'
            'CLS\r\n'
            'TEXT 40,40,"3",0,1,1,"Label Print"\r\n'
            'TEXT 40,90,"2",0,1,1,"Test Connection OK!"\r\n'
            'PRINT 1,1\r\n'
            'SOUND 1,30\r\n';
        testBytes = Uint8List.fromList(utf8.encode(testCommand));
      } else {
        // ESC/POS test command
        final List<int> escposCmd = [];
        escposCmd.addAll([0x1B, 0x40]); // Initialize
        escposCmd.addAll(utf8.encode('--------------------------------\n'));
        escposCmd.addAll(utf8.encode('         LABEL PRINT APP        \n'));
        escposCmd.addAll(utf8.encode('     Test Connection Success!   \n'));
        escposCmd.addAll(utf8.encode('--------------------------------\n\n\n'));
        escposCmd.addAll([0x1D, 0x56, 0x42, 0x00]); // Feed & Cut
        testBytes = Uint8List.fromList(escposCmd);
      }

      // Gửi lệnh in thử qua PrinterSender
      await PrinterSender.send(printer: printer, bytes: testBytes);

      return const Right(null);
    } catch (e) {
      return Left(PrinterFailure(message: e.toString()));
    }
  }
}
