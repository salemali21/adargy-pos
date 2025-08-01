import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/customers_cubit.dart';
import '../models/customer.dart';
import 'dart:ui' as ui;
import '../../../core/widgets/main_scaffold.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

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
    if (index != 0) {
      Navigator.of(context).pushReplacementNamed(routes[index]);
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<CustomersCubit>().loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'العملاء والموردين',
      currentIndex: 0,
      onTap: _onNavTap,
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const AddCustomerDialog(),
              );
            },
            child: const Icon(Icons.add),
            tooltip: 'إضافة عميل/مورد جديد',
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Tooltip(
                        message: 'فلترة حسب النوع',
                        child: DropdownButton<String>(
                          value: context.select<CustomersCubit, String>(
                              (c) => c.filterType),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('الكل')),
                            DropdownMenuItem(
                                value: 'customer', child: Text('عملاء')),
                            DropdownMenuItem(
                                value: 'supplier', child: Text('موردين')),
                          ],
                          onChanged: (v) => context
                              .read<CustomersCubit>()
                              .setFilterType(v ?? ''),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'فلترة حسب التصنيف',
                        child: DropdownButton<String>(
                          value: context.select<CustomersCubit, String>(
                              (c) => c.filterCategory),
                          items: const [
                            DropdownMenuItem(
                                value: 'all', child: Text('كل التصنيفات')),
                            DropdownMenuItem(
                                value: 'منتظم', child: Text('منتظم')),
                            DropdownMenuItem(
                                value: 'متأخر', child: Text('متأخر')),
                            DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                          ],
                          onChanged: (v) => context
                              .read<CustomersCubit>()
                              .setFilterCategory(v ?? ''),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'بحث...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<CustomersCubit>()
                                        .searchCustomers('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) =>
                            context.read<CustomersCubit>().searchCustomers(val),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<CustomersCubit, CustomersState>(
                  builder: (context, state) {
                    if (state is CustomersLoaded) {
                      print('Customers loaded: ${state.customers.length}');
                      final filtered = state.customers.where((c) {
                        final matchesType =
                            context.select<CustomersCubit, String>(
                                        (c) => c.filterType) ==
                                    'all' ||
                                c.type ==
                                    context.select<CustomersCubit, String>(
                                        (c) => c.filterType);
                        final matchesCategory =
                            context.select<CustomersCubit, String>(
                                        (c) => c.filterCategory) ==
                                    'all' ||
                                c.category ==
                                    context.select<CustomersCubit, String>(
                                        (c) => c.filterCategory);
                        final matchesSearch = _searchController.text.isEmpty ||
                            c.name.toLowerCase().contains(
                                _searchController.text.toLowerCase()) ||
                            (c.phone.toLowerCase().contains(
                                    _searchController.text.toLowerCase()) ??
                                false) ||
                            (c.notes?.toLowerCase().contains(
                                    _searchController.text.toLowerCase()) ??
                                false);
                        return matchesType && matchesCategory && matchesSearch;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                            child: Text('لا يوجد عملاء أو موردين'));
                      }
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final c = filtered[i];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: c.type == 'customer'
                                    ? Colors.blue
                                    : Colors.orange,
                                child: Icon(
                                  c.type == 'customer'
                                      ? Icons.person
                                      : Icons.local_shipping,
                                  color: Colors.white,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.stars,
                                        color: Colors.amber),
                                    tooltip: 'إدارة النقاط',
                                    onPressed: () async {
                                      final result = await showDialog<int>(
                                        context: context,
                                        builder: (context) =>
                                            LoyaltyPointsDialog(customer: c),
                                      );
                                      // ignore: use_build_context_synchronously
                                      if (!mounted) return;
                                      if (result != null) {
                                        if (result > 0) {
                                          context
                                              .read<CustomersCubit>()
                                              .addPoints(c.id, result);
                                        } else if (result < 0) {
                                          context
                                              .read<CustomersCubit>()
                                              .deductPoints(c.id, -result);
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.history,
                                        color: Colors.blueGrey),
                                    tooltip: 'سجل النقاط',
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            LoyaltyLogDialog(customer: c),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.card_giftcard,
                                        color: Colors.deepOrange),
                                    tooltip: 'استبدال النقاط',
                                    onPressed: () async {
                                      final result = await showDialog<
                                          Map<String, dynamic>>(
                                        context: context,
                                        builder: (context) =>
                                            RedeemPointsDialog(customer: c),
                                      );
                                      // ignore: use_build_context_synchronously
                                      if (!mounted) return;
                                      if (result != null &&
                                          result['points'] > 0) {
                                        context
                                            .read<CustomersCubit>()
                                            .deductPoints(
                                                c.id, result['points']);
                                        await context
                                            .read<CustomersCubit>()
                                            .addLoyaltyLog(
                                              c.id,
                                              'redeem',
                                              result['points'],
                                              note:
                                                  'مكافأة: ${result['reward']}',
                                            );
                                      }
                                    },
                                  ),
                                  if (c.category != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: c.category == 'VIP'
                                            ? Colors.purple
                                            : c.category == 'منتظم'
                                                ? Colors.green
                                                : Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        c.category!,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  const Text(
                                    'الرصيد: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    c.balance.toStringAsFixed(2),
                                    style: TextStyle(
                                      color: c.balance > 0
                                          ? Colors.green
                                          : c.balance < 0
                                              ? Colors.red
                                              : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text('النقاط: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  Text('${c.loyaltyPoints}',
                                      style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.message),
                                tooltip: 'إرسال تذكير',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('تذكير'),
                                      content: Text(
                                          'تم إرسال التذكير إلى ${c.name} بنجاح!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('حسناً'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              onLongPress: () async {
                                final action =
                                    await showModalBottomSheet<String>(
                                  context: context,
                                  builder: (context) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.edit),
                                        title: const Text('تعديل'),
                                        onTap: () =>
                                            Navigator.pop(context, 'edit'),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: const Text('حذف'),
                                        onTap: () =>
                                            Navigator.pop(context, 'delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (action == 'edit') {
                                  await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AddCustomerDialog(editCustomer: c),
                                  );
                                } else if (action == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: Text(
                                          'هل أنت متأكد من حذف ${c.name}؟'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('إلغاء'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                  // ignore: use_build_context_synchronously
                                  if (!mounted) return;
                                  if (confirm == true) {
                                    context
                                        .read<CustomersCubit>()
                                        .deleteCustomer(c.id);
                                  }
                                }
                              },
                            ),
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
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

class AddCustomerDialog extends StatefulWidget {
  final Customer? editCustomer;
  const AddCustomerDialog({super.key, this.editCustomer});
  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameController;
  TextEditingController? _phoneController;
  TextEditingController? _balanceController;
  TextEditingController? _notesController;
  String _type = 'customer';
  String? _category;

  @override
  void initState() {
    super.initState();
    final c = widget.editCustomer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _balanceController =
        TextEditingController(text: c?.balance.toString() ?? '0');
    _notesController = TextEditingController(text: c?.notes ?? '');
    _type = c?.type ?? 'customer';
    _category = c?.category;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editCustomer == null
          ? 'إضافة عميل/مورد جديد'
          : 'تعديل عميل/مورد'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('عميل')),
                  DropdownMenuItem(value: 'supplier', child: Text('مورد')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'customer'),
                decoration: const InputDecoration(labelText: 'النوع'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(labelText: 'الرصيد'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'منتظم', child: Text('منتظم')),
                  DropdownMenuItem(value: 'متأخر', child: Text('متأخر')),
                  DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                ],
                onChanged: (v) => setState(() => _category = v),
                decoration: const InputDecoration(labelText: 'تصنيف'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final customer = Customer(
                id: widget.editCustomer?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController!.text,
                type: _type,
                balance: double.tryParse(_balanceController!.text) ?? 0,
                phone: _phoneController!.text,
                notes: _notesController!.text,
                category: _category,
              );
              if (widget.editCustomer == null) {
                context.read<CustomersCubit>().addCustomer(customer);
              } else {
                context.read<CustomersCubit>().updateCustomer(customer);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class LoyaltyPointsDialog extends StatefulWidget {
  final Customer customer;
  const LoyaltyPointsDialog({super.key, required this.customer});
  @override
  State<LoyaltyPointsDialog> createState() => _LoyaltyPointsDialogState();
}

class _LoyaltyPointsDialogState extends State<LoyaltyPointsDialog> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('إدارة نقاط ${widget.customer.name}'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
            hintText: 'أدخل عدد النقاط (+ لإضافة، - لخصم)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = int.tryParse(_controller.text) ?? 0;
            Navigator.pop(context, val);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class LoyaltyLogDialog extends StatelessWidget {
  final Customer customer;
  const LoyaltyLogDialog({super.key, required this.customer});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('سجل نقاط ${customer.name}'),
      content: FutureBuilder<List<Map<String, dynamic>>>(
        future: context.read<CustomersCubit>().getLoyaltyLog(customer.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final logs = snapshot.data!;
          if (logs.isEmpty) return const Text('لا يوجد سجل نقاط بعد.');
          return SizedBox(
            width: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: logs.length,
              itemBuilder: (context, i) {
                final log = logs[i];
                return ListTile(
                  leading: Icon(
                    log['action'] == 'add'
                        ? Icons.add_circle
                        : log['action'] == 'deduct'
                            ? Icons.remove_circle
                            : Icons.card_giftcard,
                    color: log['action'] == 'add'
                        ? Colors.green
                        : log['action'] == 'deduct'
                            ? Colors.red
                            : Colors.amber,
                  ),
                  title: Text(
                      '${log['action'] == 'add' ? 'إضافة' : log['action'] == 'deduct' ? 'خصم' : 'استبدال'}: ${log['points']} نقطة'),
                  subtitle: Text(
                      '${log['date'].toString().substring(0, 16)}${log['note'] != null && log['note'].toString().isNotEmpty ? '\n${log['note']}' : ''}'),
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}

class RedeemPointsDialog extends StatefulWidget {
  final Customer customer;
  const RedeemPointsDialog({super.key, required this.customer});
  @override
  State<RedeemPointsDialog> createState() => _RedeemPointsDialogState();
}

class _RedeemPointsDialogState extends State<RedeemPointsDialog> {
  String? _selectedReward;
  final _rewards = const [
    {'label': 'خصم فاتورة', 'points': 100},
    {'label': 'هدية مجانية', 'points': 200},
    {'label': 'قسيمة شراء', 'points': 300},
  ];
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('استبدال نقاط ${widget.customer.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._rewards.map((r) => RadioListTile<String>(
                value: r['label'] as String,
                groupValue: _selectedReward,
                title: Text('${r['label']} (${r['points']} نقطة)'),
                onChanged: (v) => setState(() => _selectedReward = v),
                secondary: const Icon(Icons.card_giftcard),
              )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _selectedReward == null
              ? null
              : () {
                  final reward =
                      _rewards.firstWhere((r) => r['label'] == _selectedReward);
                  final rewardPoints = (reward['points'] as num).toInt();
                  if (widget.customer.loyaltyPoints >= rewardPoints) {
                    Navigator.pop(context,
                        {'reward': reward['label'], 'points': rewardPoints});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('النقاط غير كافية')));
                  }
                },
          child: const Text('استبدال'),
        ),
      ],
    );
  }
}
