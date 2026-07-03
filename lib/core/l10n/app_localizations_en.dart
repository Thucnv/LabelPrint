// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Label Print';

  @override
  String get homeTitle => 'Home';

  @override
  String get printerManagement => 'Printer Management';

  @override
  String get printConfig => 'Print Configuration';

  @override
  String get saveTemplate => 'Save Template';

  @override
  String get barcodePrinting => 'Barcode Printing';

  @override
  String get featureBarcode => 'Barcode';

  @override
  String get featureQr => 'QR Code';

  @override
  String get featureLabel => 'Label';

  @override
  String get featureShipping => 'Shipping';

  @override
  String get featureReceipt => 'Receipt';

  @override
  String get featurePdf => 'Print PDF';

  @override
  String get featureImage => 'Print Image';

  @override
  String get featureDelivery => 'Delivery Note';

  @override
  String get printerStatusReady => 'Ready';

  @override
  String get printerStatusIdle => 'Idle';

  @override
  String get printerStatusError => 'Error';

  @override
  String get printerNotConfigured => 'Not Configured';

  @override
  String get addPrinter => 'Add Printer';

  @override
  String get editPrinter => 'Edit Printer';

  @override
  String get deletePrinter => 'Delete Printer';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get scanDevices => 'Scan Devices';

  @override
  String get printerName => 'Printer Name';

  @override
  String get printerType => 'Printer Type';

  @override
  String get connectionMethod => 'Connection Method';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get port => 'Port';

  @override
  String get setDefault => 'Set as Default';

  @override
  String get paperSize => 'Paper Size';

  @override
  String get paperType => 'Paper Type';

  @override
  String get orientation => 'Orientation';

  @override
  String get portrait => 'Portrait';

  @override
  String get landscape => 'Landscape';

  @override
  String get marginTop => 'Top Margin';

  @override
  String get marginLeft => 'Left Margin';

  @override
  String get marginRight => 'Right Margin';

  @override
  String get printDarkness => 'Print Darkness';

  @override
  String get printSpeed => 'Print Speed';

  @override
  String get scalingMode => 'Scaling Mode';

  @override
  String get fitWidth => 'Fit Width';

  @override
  String get fitHeight => 'Fit Height';

  @override
  String get customScale => 'Custom';

  @override
  String get templateName => 'Template Name';

  @override
  String get saveConfig => 'Save Configuration';

  @override
  String get saveAsTemplate => 'Save as Template';

  @override
  String get barcodeData => 'Barcode Data';

  @override
  String get barcodeType => 'Barcode Type';

  @override
  String get barcodeHeight => 'Barcode Height';

  @override
  String get showReadableText => 'Show Readable Text';

  @override
  String get continuePrint => 'Continue Print';

  @override
  String get printNow => 'Print Now';

  @override
  String get errPrinterNameEmpty => 'Please enter a printer name';

  @override
  String get errIpInvalid => 'Invalid IP address';

  @override
  String get errDuplicateAddress => 'This address is already in use';

  @override
  String get errConnectionFailed => 'Unable to connect to the printer';

  @override
  String get errPaperSizeRange => 'Paper size must be between 20mm and 220mm';

  @override
  String get errScaleRange => 'Scale must be between 50% and 200%';

  @override
  String get errEan13Format => 'EAN-13 code must contain exactly 13 digits';

  @override
  String get errCode128Ascii => 'Code128 only supports ASCII characters';

  @override
  String get successPrinterAdded => 'Printer added successfully';

  @override
  String get successTestPrint => 'Test print successful';

  @override
  String get successConfigSaved => 'Configuration saved';

  @override
  String get successTemplateSaved => 'Template saved';

  @override
  String get successPrintSent => 'Print job sent';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'Wi-Fi';

  @override
  String get labelPrinterTspl => 'Label Printer (TSPL)';

  @override
  String get receiptPrinterEscpos => 'Receipt Printer (ESC/POS)';

  @override
  String get printerTypeLabel => 'Label Printer';

  @override
  String get printerTypeReceipt => 'Receipt Printer';

  @override
  String get defaultPrinter => 'Default Printer';

  @override
  String get noPrintersFound => 'No printers found';

  @override
  String get deleteConfirmTitle => 'Confirm Delete';

  @override
  String get deleteConfirmMessage =>
      'Are you sure you want to delete this printer?';

  @override
  String get paperSizeA5 => 'A5 (148 × 210 mm)';

  @override
  String get paperSizeA6 => 'A6 (105 × 148 mm)';

  @override
  String get paperSizeA7 => 'A7 (74 × 105 mm)';

  @override
  String get paperSizeA8 => 'A8 (52 × 74 mm)';

  @override
  String get paperSizeCustom => 'Custom';

  @override
  String get paperTypeLabel => 'Label';

  @override
  String get paperTypeContinuous => 'Continuous';

  @override
  String get paperTypeBlackMark => 'Black Mark';

  @override
  String get scalingFitWidth => 'Fit Width';

  @override
  String get scalingFitHeight => 'Fit Height';

  @override
  String get scalingCustom => 'Custom';

  @override
  String get customWidth => 'Custom Width';

  @override
  String get customHeight => 'Custom Height';

  @override
  String get printHistory => 'Print History';

  @override
  String get templates => 'Templates';

  @override
  String darknessSetting(int value) {
    return 'Darkness: $value';
  }

  @override
  String speedSetting(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return 'Speed: $valueString in/s';
  }

  @override
  String get printPreview => 'Print Preview';

  @override
  String get configInfo => 'Configuration Info';

  @override
  String marginInfo(double top, double left, double right) {
    return 'Margins: $top/$left/${right}mm';
  }

  @override
  String darknessInfo(int value) {
    return 'Darkness: $value';
  }

  @override
  String get previewLoading => 'Loading preview...';

  @override
  String get previewError => 'Preview error';

  @override
  String get copies => 'Copies';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get fitScreen => 'Fit to screen';
}
