import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/products_cubit.dart';
import '../models/product.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final productsState = context.watch<ProductsCubit>().state;
    final products =
        productsState is ProductsLoaded ? productsState.products : <Product>[];
    final filtered = _search.isEmpty
        ? products
        : products.where((p) => p.name.contains(_search)).toList();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المخزون'),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'تصدير PDF',
              onPressed: () async {
                final pdf = pw.Document();
                pdf.addPage(
                  pw.Page(
                    build: (pw.Context context) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('تقرير المخزون',
                            style: const pw.TextStyle(fontSize: 20)),
                        pw.SizedBox(height: 8),
                        pw.Table(
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(children: [
                              pw.Text('المنتج'),
                              pw.Text('الكمية'),
                              pw.Text('حد التنبيه'),
                              pw.Text('ناقص؟'),
                            ]),
                            ...filtered.map((p) => pw.TableRow(children: [
                                  pw.Text(p.name),
                                  pw.Text(p.quantity.toString()),
                                  pw.Text(p.alertThreshold.toString()),
                                  pw.Text(p.quantity <= p.alertThreshold
                                      ? 'نعم'
                                      : 'لا'),
                                ])),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
                await Printing.layoutPdf(
                    onLayout: (format) async => pdf.save());
                if (!mounted) return;
              },
            ),
            IconButton(
              icon: const Icon(Icons.table_chart),
              tooltip: 'تصدير Excel',
              onPressed: () async {
                final excel = Excel.createExcel();
                final sheet = excel['Sheet1'];
                sheet.appendRow([
                  TextCellValue('المنتج'),
                  TextCellValue('الكمية'),
                  TextCellValue('حد التنبيه'),
                  TextCellValue('ناقص؟')
                ]);
                for (final p in filtered) {
                  sheet.appendRow([
                    TextCellValue(p.name),
                    TextCellValue(p.quantity.toString()),
                    TextCellValue(p.alertThreshold.toString()),
                    TextCellValue(
                        p.quantity <= p.alertThreshold ? 'نعم' : 'لا'),
                  ]);
                }
                final bytes = excel.encode() as Uint8List;
                final dir = await getTemporaryDirectory();
                final file = File('${dir.path}/inventory.xlsx');
                await file.writeAsBytes(bytes);
                await SharePlus.instance.share(
                  ShareParams(files: [XFile(file.path)], text: 'تقرير الجرد'),
                );
                if (!mounted) return;
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // رسم بياني أعلى الشاشة
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Builder(
                builder: (context) {
                  if (filtered.isEmpty) return Container();
                  final data = <String, int>{'ناقص': 0, 'كافٍ': 0};
                  for (final p in filtered) {
                    if (p.quantity <= p.alertThreshold) {
                      data['ناقص'] = data['ناقص']! + 1;
                    } else {
                      data['كافٍ'] = data['كافٍ']! + 1;
                    }
                  }
                  final cats = data.keys.toList();
                  final vals = data.values.toList();
                  return SizedBox(
                    height: 120,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: [
                          for (int i = 0; i < vals.length; i++)
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                  toY: vals[i].toDouble(),
                                  color: i == 0 ? Colors.red : Colors.green)
                            ])
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < cats.length) {
                                  return Text(cats[value.toInt()],
                                      style: const TextStyle(fontSize: 12));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message: 'بحث عن منتج',
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث عن منتج...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'مسح البحث',
                            onPressed: () => setState(() => _search = ''),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _search = val),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('لا يوجد منتجات'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final p = filtered[i];
                        final isLow = p.quantity <= p.alertThreshold;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isLow ? Colors.red : Colors.green,
                              child: const Icon(Icons.inventory,
                                  color: Colors.white),
                            ),
                            title: Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Row(
                              children: [
                                const Text('الكمية: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                Text(p.quantity.toString(),
                                    style: TextStyle(
                                        color:
                                            isLow ? Colors.red : Colors.green)),
                                const SizedBox(width: 16),
                                Text('حد التنبيه: ${p.alertThreshold}',
                                    style: const TextStyle(fontSize: 12)),
                                if (isLow)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('ناقص',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'تعديل الكمية',
                              onPressed: () async {
                                final controller = TextEditingController(
                                    text: p.quantity.toString());
                                final result = await showDialog<int>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('تعديل كمية ${p.name}'),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          labelText: 'الكمية الجديدة'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context,
                                            int.tryParse(controller.text)),
                                        child: const Text('حفظ'),
                                      ),
                                    ],
                                  ),
                                );
                                if (!mounted) return;
                                if (result != null) {
                                  context.read<ProductsCubit>().updateProduct(
                                        p.copyWith(quantity: result),
                                      );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
