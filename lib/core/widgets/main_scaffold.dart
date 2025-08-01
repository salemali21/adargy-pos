import 'package:flutter/material.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String title;
  final Widget? floatingActionButton;
  final List<Widget>? appBarActions;

  const MainScaffold({
    required this.child,
    required this.currentIndex,
    required this.onTap,
    required this.title,
    this.floatingActionButton,
    this.appBarActions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: appBarActions,
      ),
      body: Center(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'العملاء'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: 'المنتجات'),
          BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale), label: 'البيع'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'الفواتير'),
          BottomNavigationBarItem(
              icon: Icon(Icons.warehouse), label: 'المخزون'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'التقارير'),
          BottomNavigationBarItem(
              icon: Icon(Icons.help_outline), label: 'الدعم'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
