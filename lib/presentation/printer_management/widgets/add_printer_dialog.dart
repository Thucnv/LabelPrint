import 'package:flutter/material.dart';
import 'package:label_print/core/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../domain/entities/enums/printer_enums.dart';
import '../../../domain/entities/printer.dart';

class AddPrinterDialog extends StatefulWidget {
  final Printer? printerToEdit;

  const AddPrinterDialog({
    super.key,
    this.printerToEdit,
  });

  @override
  State<AddPrinterDialog> createState() => _AddPrinterDialogState();
}

class _AddPrinterDialogState extends State<AddPrinterDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late final TextEditingController _macController;

  late ConnectionMethod _connectionMethod;
  late PrinterProtocol _protocol;
  late PrinterType _type;

  @override
  void initState() {
    super.initState();
    final p = widget.printerToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _ipController = TextEditingController(text: p?.wifiIp ?? '');
    _portController = TextEditingController(text: p?.wifiPort.toString() ?? '9100');
    _macController = TextEditingController(text: p?.btMacAddress ?? '');

    _connectionMethod = p?.connectionMethod ?? ConnectionMethod.wifi;
    _protocol = p?.protocol ?? PrinterProtocol.tspl;
    _type = p?.type ?? PrinterType.label;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _macController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.printerToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  isEdit ? l10n.editPrinter : l10n.addPrinter,
                  style: AppTextStyles.headingMd.copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: 16),

                // Name
                CustomTextField(
                  label: l10n.printerName,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.errPrinterNameEmpty;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Radio: Connection Method
                Text(l10n.connectionMethod, style: AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant)),
                Row(
                  children: [
                    Radio<ConnectionMethod>(
                      value: ConnectionMethod.wifi,
                      groupValue: _connectionMethod,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _connectionMethod = value!;
                        });
                      },
                    ),
                    Text(l10n.wifi, style: AppTextStyles.bodyMd),
                    const SizedBox(width: 16),
                    Radio<ConnectionMethod>(
                      value: ConnectionMethod.bluetooth,
                      groupValue: _connectionMethod,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _connectionMethod = value!;
                        });
                      },
                    ),
                    Text(l10n.bluetooth, style: AppTextStyles.bodyMd),
                  ],
                ),
                const SizedBox(height: 12),

                // Dynamic inputs based on connection method
                if (_connectionMethod == ConnectionMethod.wifi) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          label: l10n.ipAddress,
                          hint: '192.168.1.100',
                          controller: _ipController,
                          keyboardType: TextInputType.values[2], // raw inputs or values
                          validator: (value) {
                            if (_connectionMethod == ConnectionMethod.wifi) {
                              if (value == null || !Validators.isValidIp(value)) {
                                return l10n.errIpInvalid;
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: CustomTextField(
                          label: l10n.port,
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_connectionMethod == ConnectionMethod.wifi) {
                              if (value == null || !Validators.isValidPort(value)) {
                                return 'Lỗi Port';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  CustomTextField(
                    label: 'Địa chỉ MAC Bluetooth',
                    hint: '00:11:22:33:AA:BB',
                    controller: _macController,
                    validator: (value) {
                      if (_connectionMethod == ConnectionMethod.bluetooth) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng điền địa chỉ MAC';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Protocol Select
                Text('Giao thức máy in', style: AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant)),
                Row(
                  children: [
                    Radio<PrinterProtocol>(
                      value: PrinterProtocol.tspl,
                      groupValue: _protocol,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _protocol = value!;
                          _type = PrinterType.label; // TSPL chỉ in nhãn
                        });
                      },
                    ),
                    Text(PrinterProtocol.tspl.displayName, style: AppTextStyles.bodyMd),
                    const SizedBox(width: 16),
                    Radio<PrinterProtocol>(
                      value: PrinterProtocol.escPos,
                      groupValue: _protocol,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _protocol = value!;
                          _type = PrinterType.receipt; // ESC/POS chỉ in hóa đơn
                        });
                      },
                    ),
                    Text(PrinterProtocol.escPos.displayName, style: AppTextStyles.bodyMd),
                  ],
                ),
                const SizedBox(height: 24),

                // Buttons action
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: l10n.cancel,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        text: l10n.save,
                        onPressed: _saveForm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final p = Printer(
        id: widget.printerToEdit?.id,
        name: _nameController.text.trim(),
        type: _type,
        protocol: _protocol,
        connectionMethod: _connectionMethod,
        wifiIp: _connectionMethod == ConnectionMethod.wifi ? _ipController.text.trim() : null,
        wifiPort: _connectionMethod == ConnectionMethod.wifi ? int.parse(_portController.text) : 9100,
        btMacAddress: _connectionMethod == ConnectionMethod.bluetooth ? _macController.text.trim() : null,
        isDefault: widget.printerToEdit?.isDefault ?? false,
      );
      Navigator.pop(context, p);
    }
  }
}
