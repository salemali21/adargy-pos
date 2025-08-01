import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../sales/bloc/invoices_cubit.dart';
import '../../sales/models/invoice.dart';
import '../../customers/bloc/customers_cubit.dart';
import '../../customers/models/customer.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../products/bloc/products_cubit.dart';
import '../../products/models/product.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  DateTimeRange? _dateRange;
  String? _selectedCustomerId;
  String? _selectedProductId;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // تحميل المنتجات والعملاء عند فتح الشاشة
    context.read<CustomersCubit>().loadCustomers();
    context.read<ProductsCubit>().loadProducts();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoicesState = context.watch<InvoicesCubit>().state;
    final invoices =
        invoicesState is InvoicesLoaded ? invoicesState.invoices : <Invoice>[];
    List<Invoice> filtered = _dateRange == null
        ? invoices
        : invoices
            .where((i) =>
                i.date.isAfter(
                    _dateRange!.start.subtract(const Duration(days: 1))) &&
                i.date.isBefore(_dateRange!.end.add(const Duration(days: 1))))
            .toList();
    // تطبيق فلاتر العميل
    if (_selectedCustomerId != null) {
      filtered =
          filtered.where((i) => i.customerId == _selectedCustomerId).toList();
    }
    // تطبيق فلاتر نوع العملية
    if (_selectedPaymentMethod != null) {
      filtered = filtered
          .where((i) => i.paymentMethod == _selectedPaymentMethod)
          .toList();
    }
    // تطبيق فلتر المنتج (على مستوى العناصر)
    if (_selectedProductId != null) {
      filtered = filtered
          .where((i) =>
              i.items.any((item) => item.productId == _selectedProductId))
          .toList();
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير والتحليلات'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'المبيعات'),
              Tab(text: 'الأرباح'),
              Tab(text: 'العملاء'),
              Tab(text: 'المخزون'),
              Tab(text: 'الولاء'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'تصدير PDF',
              onPressed: () async {
                final tab = _tabController?.index;
                if (tab == 4) {
                  // تصدير تقرير الولاء (تم سابقًا)
                  final customersState = context.read<CustomersCubit>().state;
                  if (customersState is! CustomersLoaded) return;
                  final customers = customersState.customers;
                  final totalPoints =
                      customers.fold<int>(0, (sum, c) => sum + c.loyaltyPoints);
                  final pdf = pw.Document();
                  pdf.addPage(
                    pw.Page(
                      build: (pw.Context context) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('تقرير الولاء والمكافآت',
                              style: const pw.TextStyle(fontSize: 20)),
                          pw.SizedBox(height: 8),
                          pw.Text('إجمالي النقاط لجميع العملاء: $totalPoints'),
                          pw.SizedBox(height: 16),
                          pw.Table(
                            border: pw.TableBorder.all(),
                            children: [
                              pw.TableRow(children: [
                                pw.Text('العميل',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                                pw.Text('النقاط',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ]),
                              ...customers.map((c) => pw.TableRow(children: [
                                    pw.Text(c.name),
                                    pw.Text('${c.loyaltyPoints}'),
                                  ])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  await Printing.layoutPdf(
                      onLayout: (format) async => pdf.save());
                } else {
                  // تصدير باقي التقارير
                  final invoicesState = context.read<InvoicesCubit>().state;
                  if (invoicesState is! InvoicesLoaded) return;
                  final invoices = invoicesState.invoices;
                  final filtered = _dateRange == null
                      ? invoices
                      : invoices
                          .where((i) =>
                              i.date.isAfter(_dateRange!.start
                                  .subtract(const Duration(days: 1))) &&
                              i.date.isBefore(
                                  _dateRange!.end.add(const Duration(days: 1))))
                          .toList();
                  final pdf = pw.Document();
                  String title = '';
                  List<List<String>> tableRows = [];
                  if (tab == 0) {
                    // المبيعات
                    title = 'تقرير المبيعات';
                    tableRows = [
                      ['رقم الفاتورة', 'التاريخ', 'العميل', 'الإجمالي'],
                      ...filtered.map((i) => [
                            i.id,
                            i.date.toString().substring(0, 16),
                            i.customerName ?? '-',
                            i.total.toStringAsFixed(2)
                          ])
                    ];
                  } else if (tab == 1) {
                    // الأرباح
                    title = 'تقرير الأرباح (تقديري)';
                    tableRows = [
                      ['رقم الفاتورة', 'التاريخ', 'العميل', 'الأرباح'],
                      ...filtered.map((i) => [
                            i.id,
                            i.date.toString().substring(0, 16),
                            i.customerName ?? '-',
                            (i.total * 0.2).toStringAsFixed(2)
                          ])
                    ];
                  } else if (tab == 2) {
                    // العملاء
                    title = 'تقرير العملاء في الفواتير';
                    final uniqueCustomers = filtered
                        .map((i) => i.customerName ?? '-')
                        .toSet()
                        .toList();
                    tableRows = [
                      ['العميل', 'عدد الفواتير'],
                      ...uniqueCustomers.map((name) => [
                            name,
                            filtered
                                .where((i) => (i.customerName ?? '-') == name)
                                .length
                                .toString()
                          ])
                    ];
                  } else if (tab == 3) {
                    // المخزون (placeholder)
                    title = 'تقرير المخزون (عدد الفواتير المرتبطة)';
                    tableRows = [
                      ['رقم الفاتورة', 'التاريخ'],
                      ...filtered.map(
                          (i) => [i.id, i.date.toString().substring(0, 16)])
                    ];
                  }
                  pdf.addPage(
                    pw.Page(
                      build: (pw.Context context) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(title,
                              style: const pw.TextStyle(fontSize: 20)),
                          pw.SizedBox(height: 8),
                          if (_dateRange != null)
                            pw.Text(
                                'الفترة: ${_dateRange!.start.toString().substring(0, 10)} - ${_dateRange!.end.toString().substring(0, 10)}'),
                          pw.SizedBox(height: 16),
                          pw.Table(
                            border: pw.TableBorder.all(),
                            children: [
                              for (final row in tableRows)
                                pw.TableRow(children: [
                                  for (final cell in row) pw.Text(cell)
                                ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  await Printing.layoutPdf(
                      onLayout: (format) async => pdf.save());
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.table_chart),
              tooltip: 'تصدير Excel',
              onPressed: () async {
                final tab = _tabController?.index;
                String title = '';
                List<List<String>> tableRows = [];
                if (tab == 4) {
                  // الولاء
                  final customersState = context.read<CustomersCubit>().state;
                  if (customersState is! CustomersLoaded) return;
                  final customers = customersState.customers;
                  title = 'تقرير الولاء والمكافآت';
                  tableRows = [
                    ['العميل', 'النقاط'],
                    ...customers.map((c) => [c.name, '${c.loyaltyPoints}'])
                  ];
                } else {
                  final invoicesState = context.read<InvoicesCubit>().state;
                  if (invoicesState is! InvoicesLoaded) return;
                  final invoices = invoicesState.invoices;
                  final filtered = _dateRange == null
                      ? invoices
                      : invoices
                          .where((i) =>
                              i.date.isAfter(_dateRange!.start
                                  .subtract(const Duration(days: 1))) &&
                              i.date.isBefore(
                                  _dateRange!.end.add(const Duration(days: 1))))
                          .toList();
                  if (tab == 0) {
                    title = 'تقرير المبيعات';
                    tableRows = [
                      ['رقم الفاتورة', 'التاريخ', 'العميل', 'الإجمالي'],
                      ...filtered.map((i) => [
                            i.id,
                            i.date.toString().substring(0, 16),
                            i.customerName ?? '-',
                            i.total.toStringAsFixed(2)
                          ])
                    ];
                  } else if (tab == 1) {
                    title = 'تقرير الأرباح (تقديري)';
                    tableRows = [
                      ['رقم الفاتورة', 'التاريخ', 'العميل', 'الأرباح'],
                      ...filtered.map((i) => [
                            i.id,
                            i.date.toString().substring(0, 16),
                            i.customerName ?? '-',
                            (i.total * 0.2).toStringAsFixed(2)
                          ])
                    ];
                  } else if (tab == 2) {
                    title = 'تقرير العملاء في الفواتير';
                    final uniqueCustomers = filtered
                        .map((i) => i.customerName ?? '-')
                        .toSet()
                        .toList();
                    tableRows = [
                      ['العميل', 'عدد الفواتير'],
                      ...uniqueCustomers.map((name) => [
                            name,
                            filtered
                                .where((i) => (i.customerName ?? '-') == name)
                                .length
                                .toString()
                          ])
                    ];
                  } else if (tab == 3) {
                    title = 'تقرير المخزون (عدد الفواتير المرتبطة)';
                    tableRows = [
                      ['رقم الفاتورة', 'التاريخ'],
                      ...filtered.map(
                          (i) => [i.id, i.date.toString().substring(0, 16)])
                    ];
                  }
                }
                // توليد ملف Excel
                final excel = Excel.createExcel();
                final sheet = excel['Sheet1'];
                for (final row in tableRows) {
                  sheet.appendRow(row.map((e) => TextCellValue(e)).toList());
                }
                final bytes = excel.encode() as Uint8List;
                final dir = await getTemporaryDirectory();
                final file = File('${dir.path}/$title.xlsx');
                await file.writeAsBytes(bytes);
                await SharePlus.instance.share(
                  ShareParams(files: [XFile(file.path)], text: title),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Tooltip(
                      message: 'تحديد الفترة الزمنية',
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(_dateRange == null
                            ? 'كل الفترات'
                            : '${_dateRange!.start.toString().substring(0, 10)} - ${_dateRange!.end.toString().substring(0, 10)}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                            initialDateRange: _dateRange,
                          );
                          if (!mounted) return;
                          if (picked != null) {
                            setState(() => _dateRange = picked);
                          }
                        },
                      ),
                    ),
                    if (_dateRange != null)
                      Tooltip(
                        message: 'إلغاء الفلترة الزمنية',
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          color: Colors.red,
                          onPressed: () => setState(() => _dateRange = null),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // فلتر العميل
                    BlocBuilder<CustomersCubit, CustomersState>(
                      builder: (context, state) {
                        final customers = state is CustomersLoaded
                            ? state.customers
                            : <Customer>[];
                        return Tooltip(
                          message: 'فلترة حسب العميل',
                          child: DropdownButton<String?>(
                            value: _selectedCustomerId,
                            hint: const Text('كل العملاء'),
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('كل العملاء')),
                              ...customers.map((c) => DropdownMenuItem(
                                  value: c.id, child: Text(c.name)))
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedCustomerId = v),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // فلتر المنتج
                    BlocBuilder<ProductsCubit, ProductsState>(
                      builder: (context, state) {
                        final products = state is ProductsLoaded
                            ? state.products
                            : <Product>[];
                        return Tooltip(
                          message: 'فلترة حسب المنتج',
                          child: DropdownButton<String?>(
                            value: _selectedProductId,
                            hint: const Text('كل المنتجات'),
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text('كل المنتجات')),
                              ...products.map((p) => DropdownMenuItem(
                                  value: p.id, child: Text(p.name)))
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedProductId = v),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // فلتر نوع العملية
                    Tooltip(
                      message: 'فلترة حسب نوع الدفع',
                      child: DropdownButton<String?>(
                        value: _selectedPaymentMethod,
                        hint: const Text('كل طرق الدفع'),
                        items: const [
                          DropdownMenuItem(
                              value: null, child: Text('كل طرق الدفع')),
                          DropdownMenuItem(value: 'cash', child: Text('نقدي')),
                          DropdownMenuItem(value: 'visa', child: Text('فيزا')),
                          DropdownMenuItem(
                              value: 'transfer', child: Text('تحويل')),
                          DropdownMenuItem(
                              value: 'online', child: Text('أونلاين')),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedPaymentMethod = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // مبيعات
                  _ReportTable(
                    title: 'إجمالي المبيعات',
                    value: filtered.fold(0.0, (sum, i) => sum + i.total),
                    count: filtered.length,
                    chartLabel: 'المبيعات',
                    chartData: filtered.map((i) => i.total).toList(),
                    chartCategories: filtered
                        .map((i) => i.date.toString().substring(0, 10))
                        .toList(),
                  ),
                  // أرباح (هنا placeholder: الربح = 20% من المبيعات)
                  _ReportTable(
                    title: 'إجمالي الأرباح (تقديري)',
                    value: filtered.fold(0.0, (sum, i) => sum + i.total) * 0.2,
                    count: filtered.length,
                    chartLabel: 'الأرباح',
                    chartData: filtered.map((i) => (i.total * 0.2)).toList(),
                    chartCategories: filtered
                        .map((i) => i.date.toString().substring(0, 10))
                        .toList(),
                  ),
                  // العملاء
                  _ReportTable(
                    title: 'عدد العملاء في الفواتير',
                    value: filtered
                        .map((i) => i.customerId)
                        .toSet()
                        .length
                        .toDouble(),
                    count: filtered.length,
                    chartLabel: 'العملاء',
                    chartData: [filtered.length.toDouble()],
                    chartCategories: const ['عدد العملاء'],
                  ),
                  // المخزون (placeholder)
                  _ReportTable(
                    title: 'عدد الفواتير المرتبطة بالمخزون',
                    value: filtered.length.toDouble(),
                    count: filtered.length,
                    chartLabel: 'المخزون',
                    chartData: [filtered.length.toDouble()],
                    chartCategories: const ['عدد الفواتير'],
                  ),
                  // الولاء
                  _LoyaltyReportTab(dateRange: _dateRange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTable extends StatelessWidget {
  final String title;
  final double value;
  final int count;
  final String chartLabel;
  final List<double>? chartData;
  final List<String>? chartCategories;
  const _ReportTable({
    required this.title,
    required this.value,
    required this.count,
    required this.chartLabel,
    this.chartData,
    this.chartCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text('القيمة: ${value.toStringAsFixed(2)}'),
          Text('عدد العمليات: $count'),
          const SizedBox(height: 24),
          if (chartData != null && chartData!.isNotEmpty)
            SizedBox(
              height: 180,
              width: double.infinity,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    for (int i = 0; i < chartData!.length; i++)
                      BarChartGroupData(x: i, barRods: [
                        BarChartRodData(toY: chartData![i], color: Colors.blue)
                      ])
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (chartCategories != null &&
                              value.toInt() < chartCategories!.length) {
                            return Text(chartCategories![value.toInt()],
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            )
          else
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(
                  child: Text(
                      'لا توجد بيانات كافية للرسم البياني')), // Placeholder
            ),
        ],
      ),
    );
  }
}

class _LoyaltyReportTab extends StatelessWidget {
  final DateTimeRange? dateRange;
  const _LoyaltyReportTab({this.dateRange});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        if (state is! CustomersLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final customers = state.customers;
        final totalPoints =
            customers.fold<int>(0, (sum, c) => sum + c.loyaltyPoints);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تقرير الولاء والمكافآت',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text('إجمالي النقاط لجميع العملاء: $totalPoints'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, i) {
                    final c = customers[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(c.name),
                      subtitle: Text('النقاط: ${c.loyaltyPoints}'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
