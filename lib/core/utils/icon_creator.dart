import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class IconCreator {
  static Future<void> createAppIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(1024, 1024);

    // خلفية التدرج
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E3A8A),
          Color(0xFF3B82F6),
          Color(0xFF60A5FA),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(200),
      ),
      paint,
    );

    // أيقونة المتجر
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // جسم المتجر
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(312, 412, 400, 300),
        const Radius.circular(20),
      ),
      iconPaint,
    );

    // السقف
    final roofPath = Path();
    roofPath.moveTo(262, 412);
    roofPath.lineTo(512, 312);
    roofPath.lineTo(762, 412);
    roofPath.close();
    canvas.drawPath(roofPath, iconPaint);

    // الباب
    final doorPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(462, 512, 100, 200),
        const Radius.circular(10),
      ),
      doorPaint,
    );

    // النوافذ
    canvas.drawCircle(
      const Offset(412, 462),
      30,
      doorPaint,
    );

    canvas.drawCircle(
      const Offset(612, 462),
      30,
      doorPaint,
    );

    // تفاصيل الباب
    final doorHandlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      const Offset(512, 612),
      8,
      doorHandlePaint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/app_icon.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      debugPrint('App icon created at: ${file.path}');
    }
  }
}
