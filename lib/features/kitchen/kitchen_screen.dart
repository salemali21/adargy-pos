import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('شاشة المطبخ'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.kitchen, size: 80, color: Colors.orange),
              SizedBox(height: 24),
              Text('سيتم عرض الطلبات هنا (قريبًا).'),
            ],
          ),
        ),
      ),
    );
  }
}
