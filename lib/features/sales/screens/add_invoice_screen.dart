import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/invoices_cubit.dart';
import '../models/invoice.dart';
import '../../../core/widgets/main_scaffold.dart';

class AddInvoiceScreen extends StatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
    if (index != 3) {
      Navigator.of(context).pushReplacementNamed(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'إضافة فاتورة جديدة',
      currentIndex: 3,
      onTap: _onNavTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اسم العميل'),
            TextField(
              controller: _customerController,
              decoration: const InputDecoration(hintText: 'مثال: أحمد علي'),
            ),
            const SizedBox(height: 16),
            const Text('اسم المنتج'),
            TextField(
              controller: _productController,
              decoration: const InputDecoration(hintText: 'مثال: تيشيرت رجالي'),
            ),
            const SizedBox(height: 16),
            const Text('المبلغ الإجمالي'),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'مثال: 500'),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('حفظ الفاتورة'),
                onPressed: () async {
                  final customerName = _customerController.text.trim();
                  final productName = _productController.text.trim();
                  final amount =
                      double.tryParse(_amountController.text.trim()) ?? 0;
                  if (customerName.isEmpty ||
                      productName.isEmpty ||
                      amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('يرجى إدخال جميع البيانات بشكل صحيح')),
                    );
                    return;
                  }
                  final invoice = Invoice(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: DateTime.now(),
                    items: [
                      InvoiceItem(
                        productId: '',
                        name: productName,
                        price: amount,
                        quantity: 1,
                      ),
                    ],
                    customerId: null,
                    customerName: customerName,
                    total: amount,
                    discount: 0,
                    tax: 0,
                    paymentMethod: 'cash',
                    notes: '',
                  );
                  await context.read<InvoicesCubit>().addInvoice(invoice);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ الفاتورة بنجاح!')),
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
