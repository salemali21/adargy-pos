import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:typed_data';

class AppIconGenerator {
  static Future<Uint8List> generateAppIcon() async {
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

    // الأيقونة الرئيسية
    final iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // رسم أيقونة المتجر
    final iconPath = Path();
    final iconSize = size.width * 0.4;
    final iconX = (size.width - iconSize) / 2;
    final iconY = (size.height - iconSize) / 2;

    // رسم شكل المتجر
    iconPath.moveTo(iconX + iconSize * 0.2, iconY + iconSize * 0.3);
    iconPath.lineTo(iconX + iconSize * 0.2, iconY + iconSize * 0.8);
    iconPath.lineTo(iconX + iconSize * 0.8, iconY + iconSize * 0.8);
    iconPath.lineTo(iconX + iconSize * 0.8, iconY + iconSize * 0.3);
    iconPath.close();

    // السقف
    iconPath.moveTo(iconX + iconSize * 0.1, iconY + iconSize * 0.3);
    iconPath.lineTo(iconX + iconSize * 0.5, iconY + iconSize * 0.1);
    iconPath.lineTo(iconX + iconSize * 0.9, iconY + iconSize * 0.3);
    iconPath.close();

    canvas.drawPath(iconPath, iconPaint);

    // الباب
    final doorPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        iconX + iconSize * 0.35,
        iconY + iconSize * 0.5,
        iconSize * 0.3,
        iconSize * 0.3,
      ),
      doorPaint,
    );

    // النافذة
    final windowPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(iconX + iconSize * 0.3, iconY + iconSize * 0.4),
      iconSize * 0.08,
      windowPaint,
    );

    canvas.drawCircle(
      Offset(iconX + iconSize * 0.7, iconY + iconSize * 0.4),
      iconSize * 0.08,
      windowPaint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
