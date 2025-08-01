import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/invoices_cubit.dart';
import '../models/invoice.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import '../../customers/bloc/customers_cubit.dart';
import '../../customers/models/customer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/widgets/main_scaffold.dart';
import 'add_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String _search = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final invoicesState = context.read<InvoicesCubit>().state;
    if (invoicesState is InvoicesLoaded && invoicesState.invoices.isEmpty) {
      context.read<InvoicesCubit>().addDummyInvoices();
    }
  }

  void _onNavTap(int index) {
    // ترتيب العناصر: العملاء، المنتجات، البيع، الفواتير، المخزون، التقارير، الدعم، الإعدادات
    const routes = [
      '/customers',
      '/products',
      '/sale',
      '/invoices',
      '/inventory',
      '/reports',
      '/support',
      '/settings',
    ];
    if (index != 3) {
      Navigator.of(context).pushReplacementNamed(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesState = context.watch<InvoicesCubit>().state;
    final invoices =
        invoicesState is InvoicesLoaded ? invoicesState.invoices : <Invoice>[];
    final filtered = _search.isEmpty
        ? invoices
        : invoices
            .where((i) =>
                i.customerName!.contains(_search) || i.id.contains(_search))
            .toList();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: MainScaffold(
        title: 'الفواتير والمدفوعات',
        appBarActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث الفواتير',
            onPressed: () {
              context.read<InvoicesCubit>().loadInvoices();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة فاتورة جديدة',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddInvoiceScreen()),
              );
            },
          ),
        ],
        currentIndex: 3,
        onTap: _onNavTap,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddInvoiceScreen()),
            );
          },
          tooltip: 'إضافة فاتورة جديدة',
          child: const Icon(Icons.add),
        ),
        child: filtered.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    const Icon(Icons.receipt_long,
                        size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'لا يوجد فواتير بعد',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('إدخال فواتير تجريبية'),
                      onPressed: () {
                        context.read<InvoicesCubit>().addDummyInvoices();
                      },
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text('مسح كل الفواتير'),
                            onPressed: () {
                              context.read<InvoicesCubit>().clearAllInvoices();
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('إدخال فواتير تجريبية'),
                            onPressed: () {
                              context.read<InvoicesCubit>().addDummyInvoices();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // فلتر الفترة
                            Tooltip(
                              message: 'تحديد الفترة الزمنية',
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.date_range),
                                label: Text(context.select<InvoicesCubit,
                                                DateTimeRange?>(
                                            (c) => c.filterDateRange) ==
                                        null
                                    ? 'كل الفترات'
                                    : '${context.select<InvoicesCubit, DateTimeRange?>((c) => c.filterDateRange)!.start.toString().substring(0, 10)} - ${context.select<InvoicesCubit, DateTimeRange?>((c) => c.filterDateRange)!.end.toString().substring(0, 10)}'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                    initialDateRange: context
                                        .read<InvoicesCubit>()
                                        .filterDateRange,
                                  );
                                  if (!mounted) return;
                                  if (picked != null) {
                                    context
                                        .read<InvoicesCubit>()
                                        .setFilterDateRange(picked);
                                  }
                                },
                              ),
                            ),
                            Tooltip(
                              message: 'إلغاء الفلترة الزمنية',
                              child: IconButton(
                                icon: const Icon(Icons.clear),
                                color: Colors.red,
                                onPressed: () => context
                                    .read<InvoicesCubit>()
                                    .setFilterDateRange(null),
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
                                    value:
                                        context.select<InvoicesCubit, String?>(
                                            (c) => c.filterCustomerId),
                                    hint: const Text('كل العملاء'),
                                    items: [
                                      const DropdownMenuItem(
                                          value: null,
                                          child: Text('كل العملاء')),
                                      ...customers.map((c) => DropdownMenuItem(
                                          value: c.id, child: Text(c.name)))
                                    ],
                                    onChanged: (v) => context
                                        .read<InvoicesCubit>()
                                        .setFilterCustomerId(v),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            // فلتر نوع الدفع
                            Tooltip(
                              message: 'فلترة حسب نوع الدفع',
                              child: DropdownButton<String?>(
                                value: context.select<InvoicesCubit, String?>(
                                    (c) => c.filterPaymentMethod),
                                hint: const Text('كل طرق الدفع'),
                                items: const [
                                  DropdownMenuItem(
                                      value: null, child: Text('كل طرق الدفع')),
                                  DropdownMenuItem(
                                      value: 'cash', child: Text('نقدي')),
                                  DropdownMenuItem(
                                      value: 'visa', child: Text('فيزا')),
                                  DropdownMenuItem(
                                      value: 'transfer', child: Text('تحويل')),
                                  DropdownMenuItem(
                                      value: 'online', child: Text('أونلاين')),
                                ],
                                onChanged: (v) => context
                                    .read<InvoicesCubit>()
                                    .setFilterPaymentMethod(v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // البحث مع زر مسح
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText:
                                      'بحث برقم الفاتورة أو اسم العميل...',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _search.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          tooltip: 'مسح البحث',
                                          onPressed: () {
                                            setState(() => _search = '');
                                            context
                                                .read<InvoicesCubit>()
                                                .searchInvoices('');
                                          },
                                        )
                                      : null,
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (val) {
                                  setState(() => _search = val);
                                  context
                                      .read<InvoicesCubit>()
                                      .searchInvoices(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // رسم بياني أعلى القائمة
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: BlocBuilder<InvoicesCubit, InvoicesState>(
                        builder: (context, state) {
                          if (state is! InvoicesLoaded ||
                              state.invoices.isEmpty) {
                            return Container();
                          }
                          final data = <String, double>{};
                          for (final i in state.invoices) {
                            final day = i.date.toString().substring(0, 10);
                            data[day] = (data[day] ?? 0) + i.total;
                          }
                          final days = data.keys.toList();
                          final vals = data.values.toList();
                          return SizedBox(
                            height: 180,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                barGroups: [
                                  for (int i = 0; i < vals.length; i++)
                                    BarChartGroupData(x: i, barRods: [
                                      BarChartRodData(
                                          toY: vals[i], color: Colors.blue)
                                    ])
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: true)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() < days.length) {
                                          return Text(days[value.toInt()],
                                              style: const TextStyle(
                                                  fontSize: 10));
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
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('لا يوجد فواتير'))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final inv = filtered[i];
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                        'فاتورة #${inv.id} - ${inv.customerName ?? 'بدون عميل'}'),
                                    subtitle: Text(
                                        'التاريخ: ${inv.date.toString().substring(0, 16)} | الإجمالي: ${inv.total.toStringAsFixed(2)}'),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (action) async {
                                        if (action == 'delete') {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('تأكيد الحذف'),
                                              content: Text(
                                                  'هل أنت متأكد من حذف الفاتورة #${inv.id}؟'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('إلغاء'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text('حذف'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (!mounted) return;
                                          if (confirm == true) {
                                            context
                                                .read<InvoicesCubit>()
                                                .deleteInvoice(inv.id);
                                          }
                                        } else if (action == 'share') {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('مشاركة'),
                                              content: const Text(
                                                  'سيتم دعم المشاركة لاحقًا (واتساب/SMS).'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('حسناً'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else if (action == 'export') {
                                          final pdf = pw.Document();
                                          pdf.addPage(
                                            pw.Page(
                                              build: (pw.Context context) =>
                                                  pw.Column(
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('فاتورة #${inv.id}',
                                                      style: const pw.TextStyle(
                                                          fontSize: 20)),
                                                  pw.SizedBox(height: 8),
                                                  pw.Text(
                                                      'العميل: ${inv.customerName ?? 'بدون عميل'}'),
                                                  pw.Text(
                                                      'التاريخ: ${inv.date.toString().substring(0, 16)}'),
                                                  pw.Text(
                                                      'طريقة الدفع: ${inv.paymentMethod}'),
                                                  pw.Divider(),
                                                  ...inv.items.map((item) =>
                                                      pw.Text(
                                                          '${item.name} × ${item.quantity} = ${(item.price * item.quantity).toStringAsFixed(2)}')),
                                                  pw.Divider(),
                                                  pw.Text(
                                                      'الإجمالي: ${inv.total.toStringAsFixed(2)}'),
                                                  pw.Text(
                                                      'خصم: ${inv.discount.toStringAsFixed(2)}'),
                                                  pw.Text(
                                                      'ضريبة: ${inv.tax.toStringAsFixed(2)}'),
                                                  pw.Text(
                                                      'الصافي: ${(inv.total).toStringAsFixed(2)}'),
                                                  if (inv.notes != null &&
                                                      inv.notes!
                                                          .isNotEmpty) ...[
                                                    pw.Divider(),
                                                    pw.Text(
                                                        'ملاحظات: ${inv.notes}'),
                                                  ]
                                                ],
                                              ),
                                            ),
                                          );
                                          await Printing.layoutPdf(
                                              onLayout: (format) async =>
                                                  pdf.save());
                                          if (!mounted) return;
                                        } else if (action == 'remind') {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('تذكير'),
                                              content: const Text(
                                                  'سيتم دعم التذكير التلقائي لاحقًا.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('حسناً'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else if (action == 'print') {
                                          final pdf = pw.Document();
                                          pdf.addPage(
                                            pw.Page(
                                              build: (pw.Context context) =>
                                                  pw.Column(
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: [
                                                  pw.Text('فاتورة #${inv.id}',
                                                      style: const pw.TextStyle(
                                                          fontSize: 20)),
                                                  pw.SizedBox(height: 8),
                                                  pw.Text(
                                                      'العميل: ${inv.customerName ?? 'بدون عميل'}'),
                                                  pw.Text(
                                                      'التاريخ: ${inv.date.toString().substring(0, 16)}'),
                                                  pw.Text(
                                                      'طريقة الدفع: ${inv.paymentMethod}'),
                                                  pw.Divider(),
                                                  ...inv.items.map((item) =>
                                                      pw.Text(
                                                          '${item.name} × ${item.quantity} = ${(item.price * item.quantity).toStringAsFixed(2)}')),
                                                  pw.Divider(),
                                                  pw.Text(
                                                      'الإجمالي: ${inv.total.toStringAsFixed(2)}'),
                                                  pw.Text(
                                                      'خصم: ${inv.discount.toStringAsFixed(2)}'),
                                                  pw.Text(
                                                      'ضريبة: ${inv.tax.toStringAsFixed(2)}'),
                                                  pw.Text(
                                                      'الصافي: ${(inv.total).toStringAsFixed(2)}'),
                                                  if (inv.notes != null &&
                                                      inv.notes!
                                                          .isNotEmpty) ...[
                                                    pw.Divider(),
                                                    pw.Text(
                                                        'ملاحظات: ${inv.notes}'),
                                                  ]
                                                ],
                                              ),
                                            ),
                                          );
                                          await Printing.layoutPdf(
                                            onLayout: (format) async =>
                                                pdf.save(),
                                          );
                                          if (!mounted) return;
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                            value: 'export',
                                            child: Text('تصدير PDF/Excel')),
                                        const PopupMenuItem(
                                            value: 'share',
                                            child: Text('مشاركة')),
                                        const PopupMenuItem(
                                            value: 'remind',
                                            child: Text('تذكير')),
                                        const PopupMenuItem(
                                            value: 'print',
                                            child: Text('طباعة')),
                                        const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('حذف')),
                                      ],
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                              'تفاصيل الفاتورة #${inv.id}'),
                                          content: SizedBox(
                                            width: 300,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'العميل: ${inv.customerName ?? 'بدون عميل'}'),
                                                Text(
                                                    'التاريخ: ${inv.date.toString().substring(0, 16)}'),
                                                Text(
                                                    'طريقة الدفع: ${inv.paymentMethod}'),
                                                const Divider(),
                                                ...inv.items.map((item) => Text(
                                                    '${item.name} × ${item.quantity} = ${(item.price * item.quantity).toStringAsFixed(2)}')),
                                                const Divider(),
                                                Text(
                                                    'الإجمالي: ${inv.total.toStringAsFixed(2)}'),
                                                Text(
                                                    'خصم: ${inv.discount.toStringAsFixed(2)}'),
                                                Text(
                                                    'ضريبة: ${inv.tax.toStringAsFixed(2)}'),
                                                Text(
                                                    'الصافي: ${(inv.total).toStringAsFixed(2)}'),
                                                if (inv.notes != null &&
                                                    inv.notes!.isNotEmpty) ...[
                                                  const Divider(),
                                                  Text('ملاحظات: ${inv.notes}'),
                                                ]
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('إغلاق'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
