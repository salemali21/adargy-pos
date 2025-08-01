// ملاحظة: يجب إضافة الحزم التالية في pubspec.yaml:
// esc_pos_bluetooth: ^0.4.0
// esc_pos_utils: ^1.1.0
//
// نفذ الأمر التالي في التيرمنال:
// flutter pub add esc_pos_bluetooth esc_pos_utils
//
// إذا لم تكن الحزم مثبتة ستظهر أخطاء في الاستيراد.
import 'package:flutter/material.dart';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class CashDrawerButton extends StatefulWidget {
  const CashDrawerButton({super.key});

  @override
  State<CashDrawerButton> createState() => _CashDrawerButtonState();
}

class _CashDrawerButtonState extends State<CashDrawerButton> {
  // final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  // List<BluetoothDevice> _devices = [];
  // BluetoothDevice? _selectedDevice;
  final String _status = '';

  @override
  void initState() {
    super.initState();
    // _getDevices();
  }

  // void _getDevices() async {
  //   final devices = await bluetooth.getBondedDevices();
  //   setState(() {
  //     _devices = devices;
  //   });
  // }

  // void _openCashDrawer() async {
  //   if (_selectedDevice == null) {
  //     setState(() => _status = 'اختر طابعة أولاً');
  //     return;
  //   }
  //   await bluetooth.connect(_selectedDevice!);
  //   // أمر فتح درج الكاش ESC/POS
  //   await bluetooth
  //       .writeBytes(Uint8List.fromList([0x1B, 0x70, 0x00, 0x19, 0xFA]));
  //   setState(() => _status = 'تم إرسال أمر فتح الدرج');
  //   await bluetooth.disconnect();
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DropdownButton<BluetoothDevice>(
        //   hint: const Text('اختر الطابعة'),
        //   value: _selectedDevice,
        //   items: _devices
        //       .map((d) => DropdownMenuItem(
        //             value: d,
        //             child: Text(d.name ?? d.address ?? ''),
        //           ))
        //       .toList(),
        //   onChanged: (device) {
        //     setState(() => _selectedDevice = device);
        //   },
        // ),
        // ElevatedButton(
        //   onPressed: _openCashDrawer,
        //   child: const Text('فتح درج الكاش'),
        // ),
        Text(_status, style: const TextStyle(color: Colors.blue)),
      ],
    );
  }
}
