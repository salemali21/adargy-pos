import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../products/bloc/products_cubit.dart';
import '../../products/models/product.dart';
import '../../customers/bloc/customers_cubit.dart';
import '../../customers/models/customer.dart';
import '../bloc/invoices_cubit.dart';
import '../models/invoice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import '../../../core/widgets/main_scaffold.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final Map<String, InvoiceItem> _cart = {};
  String? _selectedCustomerId;
  String _paymentMethod = 'cash';
  double _discount = 0;
  double _tax = 0;
  final String _search = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final invoicesState = context.read<InvoicesCubit>().state;
    if (invoicesState is InvoicesLoaded && invoicesState.invoices.isEmpty) {
      context.read<InvoicesCubit>().addDummyInvoices();
    }
  }

  void _onNavTap(int index) {
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
    if (index != 2) {
      Navigator.of(context).pushReplacementNamed(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = context.watch<ProductsCubit>().state;
    final customersState = context.watch<CustomersCubit>().state;
    final products =
        productsState is ProductsLoaded ? productsState.products : <Product>[];
    final customers = customersState is CustomersLoaded
        ? customersState.customers
        : <Customer>[];
    final cartItems = _cart.values.toList();
    double subtotal =
        cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
    double total = subtotal - _discount + _tax;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: MainScaffold(
        title: 'شاشة البيع',
        currentIndex: 2,
        onTap: _onNavTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            if (isWide) {
              return Row(
                children: [
                  // قائمة المنتجات
                  Expanded(
                    flex: 2,
                    child: buildProductsList(products),
                  ),
                  // سلة البيع
                  Expanded(
                    flex: 3,
                    child:
                        buildCartSection(cartItems, customers, subtotal, total),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  // قائمة المنتجات
                  Expanded(
                    flex: 2,
                    child: buildProductsList(products),
                  ),
                  // سلة البيع
                  Expanded(
                    flex: 3,
                    child:
                        buildCartSection(cartItems, customers, subtotal, total),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildProductsList(List<Product> products) {
    return ListView(
      children: products
          .where((p) => p.name.contains(_search))
          .map((p) => ListTile(
                title: Text(p.name),
                subtitle: Text('السعر: ${p.price} | الكمية: ${p.quantity}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: p.quantity > 0
                      ? () {
                          setState(() {
                            if (_cart.containsKey(p.id)) {
                              _cart[p.id] = _cart[p.id]!.copyWith(
                                  quantity: _cart[p.id]!.quantity + 1);
                            } else {
                              _cart[p.id] = InvoiceItem(
                                productId: p.id,
                                name: p.name,
                                price: p.price,
                                quantity: 1,
                              );
                            }
                          });
                        }
                      : null,
                ),
              ))
          .toList(),
    );
  }

  Widget buildCartSection(List<InvoiceItem> cartItems, List<Customer> customers,
      double subtotal, double total) {
    return Column(
      children: [
        const Text('سلة البيع', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: ListView(
            children: cartItems
                .map((item) => ListTile(
                      title: Text(item.name),
                      subtitle: Text('سعر: ${item.price} × ${item.quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: item.quantity > 1
                                ? () {
                                    setState(() {
                                      _cart[item.productId] = item.copyWith(
                                          quantity: item.quantity - 1);
                                    });
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _cart[item.productId] =
                                    item.copyWith(quantity: item.quantity + 1);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _cart.remove(item.productId);
                              });
                            },
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        // ملخص الفاتورة
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الإجمالي: $subtotal'),
              Row(
                children: [
                  const Text('خصم: '),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '0'),
                      onChanged: (v) =>
                          setState(() => _discount = double.tryParse(v) ?? 0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('ضريبة: '),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '0'),
                      onChanged: (v) =>
                          setState(() => _tax = double.tryParse(v) ?? 0),
                    ),
                  ),
                ],
              ),
              Text('الصافي: $total',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButton<String?>(
                value: _selectedCustomerId,
                hint: const Text('اختر عميل (اختياري)'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('بدون عميل')),
                  ...customers.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                ],
                onChanged: (v) => setState(() => _selectedCustomerId = v),
              ),
              DropdownButton<String>(
                value: _paymentMethod,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('كاش')),
                  DropdownMenuItem(value: 'visa', child: Text('فيزا')),
                  DropdownMenuItem(value: 'transfer', child: Text('تحويل')),
                  DropdownMenuItem(value: 'online', child: Text('دفع أونلاين')),
                ],
                onChanged: (v) => setState(() => _paymentMethod = v ?? 'cash'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.money),
                label: const Text('فتح درج الكاش'),
                onPressed: openCashDrawer,
              ),
              ElevatedButton(
                onPressed: cartItems.isEmpty
                    ? null
                    : () async {
                        final customer = customers.firstWhere(
                            (c) => c.id == _selectedCustomerId,
                            orElse: () => Customer(
                                id: '',
                                name: '',
                                type: '',
                                balance: 0,
                                phone: ''));
                        final invoice = Invoice(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          date: DateTime.now(),
                          items: cartItems,
                          customerId: _selectedCustomerId,
                          customerName:
                              customer.name.isEmpty ? null : customer.name,
                          total: total,
                          discount: _discount,
                          tax: _tax,
                          paymentMethod: _paymentMethod,
                          notes: '',
                        );
                        context.read<InvoicesCubit>().addInvoice(invoice);
                        if (_selectedCustomerId != null) {
                          final prefs = await SharedPreferences.getInstance();
                          if (!mounted) return;
                          final rule = prefs.getInt('loyalty_rule') ?? 1;
                          final points =
                              rule > 0 ? (total ~/ rule) : total.floor();
                          context
                              .read<CustomersCubit>()
                              .addPoints(_selectedCustomerId!, points);
                        }
                        setState(() {
                          _cart.clear();
                          _discount = 0;
                          _tax = 0;
                          _selectedCustomerId = null;
                        });
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تم إصدار الفاتورة'),
                            content: const Text('تم حفظ الفاتورة بنجاح!'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('حسناً'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final pdf = pw.Document();
                                  pdf.addPage(
                                    pw.Page(
                                      build: (pw.Context context) => pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text('فاتورة',
                                              style: const pw.TextStyle(
                                                  fontSize: 20)),
                                          pw.SizedBox(height: 8),
                                          pw.Text(
                                              'العميل: ${customer.name.isEmpty ? 'بدون عميل' : customer.name}'),
                                          pw.Text(
                                              'التاريخ: ${DateTime.now().toString().substring(0, 16)}'),
                                          pw.Text(
                                              'طريقة الدفع: $_paymentMethod'),
                                          pw.Divider(),
                                          ...cartItems.map((item) => pw.Text(
                                              '${item.name} × ${item.quantity} = ${(item.price * item.quantity).toStringAsFixed(2)}')),
                                          pw.Divider(),
                                          pw.Text('الإجمالي: $subtotal'),
                                          pw.Text('خصم: $_discount'),
                                          pw.Text('ضريبة: $_tax'),
                                          pw.Text('الصافي: $total'),
                                        ],
                                      ),
                                    ),
                                  );
                                  await Printing.layoutPdf(
                                      onLayout: (format) async => pdf.save());
                                },
                                child: const Text('طباعة/تصدير PDF'),
                              ),
                            ],
                          ),
                        );
                      },
                child: const Text('إصدار الفاتورة'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void openCashDrawer() {
    // TODO: ربط مع ESC/POS أو Bluetooth لفتح درج الكاش فعليًا
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('درج الكاش'),
        content: const Text('سيتم دعم فتح درج الكاش تلقائيًا لاحقًا.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
