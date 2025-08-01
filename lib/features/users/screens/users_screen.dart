import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/users_cubit.dart';
import '../models/user.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final usersState = context.watch<UsersCubit>().state;
    final users = usersState is UsersLoaded ? usersState.users : <User>[];
    final filtered = _search.isEmpty
        ? users
        : users.where((u) => u.name.contains(_search)).toList();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المستخدمون والصلاحيات'),
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
                        pw.Text('تقرير المستخدمين',
                            style: const pw.TextStyle(fontSize: 20)),
                        pw.SizedBox(height: 8),
                        pw.Table(
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(children: [
                              pw.Text('الاسم'),
                              pw.Text('الهاتف'),
                              pw.Text('الصلاحية'),
                            ]),
                            ...filtered.map((u) => pw.TableRow(children: [
                                  pw.Text(u.name),
                                  pw.Text(u.phone),
                                  pw.Text(u.role == 'admin'
                                      ? 'مدير'
                                      : u.role == 'cashier'
                                          ? 'كاشير'
                                          : 'موظف'),
                                ])),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
                await Printing.layoutPdf(
                    onLayout: (format) async => pdf.save());
              },
            ),
            IconButton(
              icon: const Icon(Icons.table_chart),
              tooltip: 'تصدير Excel',
              onPressed: () async {
                final excel = Excel.createExcel();
                final sheet = excel['Sheet1'];
                sheet.appendRow([
                  TextCellValue('الاسم'),
                  TextCellValue('الهاتف'),
                  TextCellValue('الصلاحية')
                ]);
                for (final u in filtered) {
                  sheet.appendRow([
                    TextCellValue(u.name),
                    TextCellValue(u.phone),
                    TextCellValue(u.role == 'admin'
                        ? 'مدير'
                        : u.role == 'cashier'
                            ? 'كاشير'
                            : 'موظف'),
                  ]);
                }
                final bytes = excel.encode() as Uint8List;
                final dir = await getTemporaryDirectory();
                final file = File('${dir.path}/users.xlsx');
                await file.writeAsBytes(bytes);
                await SharePlus.instance.share(
                  ShareParams(
                      files: [XFile(file.path)], text: 'تقرير المستخدمين'),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'إضافة مستخدم',
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => const AddUserDialog(),
                );
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
                  final data = <String, int>{'مدير': 0, 'كاشير': 0, 'موظف': 0};
                  for (final u in filtered) {
                    if (u.role == 'admin') {
                      data['مدير'] = data['مدير']! + 1;
                    } else if (u.role == 'cashier') {
                      data['كاشير'] = data['كاشير']! + 1;
                    } else {
                      data['موظف'] = data['موظف']! + 1;
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
                                  color: i == 0
                                      ? Colors.indigo
                                      : i == 1
                                          ? Colors.green
                                          : Colors.orange)
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
                message: 'بحث عن مستخدم',
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث عن مستخدم...',
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
                  ? const Center(child: Text('لا يوجد مستخدمون'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final u = filtered[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: u.role == 'admin'
                                  ? Colors.indigo
                                  : u.role == 'cashier'
                                      ? Colors.green
                                      : Colors.orange,
                              child: Icon(
                                u.role == 'admin'
                                    ? Icons.security
                                    : u.role == 'cashier'
                                        ? Icons.point_of_sale
                                        : Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(u.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${u.role == 'admin' ? 'مدير' : u.role == 'cashier' ? 'كاشير' : 'موظف'} - ${u.phone}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) async {
                                if (action == 'edit') {
                                  await showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AddUserDialog(editUser: u),
                                  );
                                } else if (action == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: Text(
                                          'هل أنت متأكد من حذف ${u.name}؟'),
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
                                  if (confirm == true) {
                                    context.read<UsersCubit>().deleteUser(u.id);
                                  }
                                } else if (action == 'permissions') {
                                  final selected =
                                      await showDialog<List<String>>(
                                    context: context,
                                    builder: (context) =>
                                        PermissionsDialog(user: u),
                                  );
                                  if (!mounted) return;
                                  if (selected != null) {
                                    context
                                        .read<UsersCubit>()
                                        .updatePermissions(u.id, selected);
                                  }
                                  Navigator.of(context).pop();
                                } else if (action == 'activity') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('سجل نشاط ${u.name}'),
                                      content: SizedBox(
                                        width: 300,
                                        child: u.activityLog.isEmpty
                                            ? const Text('لا يوجد نشاطات بعد')
                                            : ListView(
                                                shrinkWrap: true,
                                                children: u.activityLog
                                                    .map((a) => Text(a))
                                                    .toList(),
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
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('تعديل')),
                                const PopupMenuItem(
                                    value: 'permissions',
                                    child: Text('الصلاحيات')),
                                const PopupMenuItem(
                                    value: 'activity',
                                    child: Text('سجل النشاط')),
                                const PopupMenuItem(
                                    value: 'delete', child: Text('حذف')),
                              ],
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

class AddUserDialog extends StatefulWidget {
  final User? editUser;
  const AddUserDialog({super.key, this.editUser});
  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameController;
  TextEditingController? _phoneController;
  TextEditingController? _passwordController;
  String? _role = 'staff';

  @override
  void initState() {
    super.initState();
    final u = widget.editUser;
    _nameController = TextEditingController(text: u?.name ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _passwordController = TextEditingController(text: u?.password ?? '');
    _role = u?.role ?? 'staff';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.editUser == null ? 'إضافة مستخدم جديد' : 'تعديل مستخدم'),
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
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('مدير')),
                  DropdownMenuItem(value: 'cashier', child: Text('كاشير')),
                  DropdownMenuItem(value: 'staff', child: Text('موظف')),
                ],
                onChanged: (v) => setState(() => _role = v),
                decoration: const InputDecoration(labelText: 'الدور'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
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
              final user = User(
                id: widget.editUser?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController!.text,
                role: _role!,
                phone: _phoneController!.text,
                permissions: widget.editUser?.permissions ?? [],
                activityLog: widget.editUser?.activityLog ?? [],
                password: _passwordController!.text,
              );
              if (widget.editUser == null) {
                context.read<UsersCubit>().addUser(user);
              } else {
                context.read<UsersCubit>().updateUser(user);
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

class PermissionsDialog extends StatefulWidget {
  final User user;
  const PermissionsDialog({super.key, required this.user});
  @override
  State<PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<PermissionsDialog> {
  List<String>? _selected;
  final List<String> _all = [
    'العملاء',
    'المنتجات',
    'المبيعات',
    'الفواتير',
    'المخزون',
    'التقارير',
    'المستخدمين',
    'الدعم',
  ];

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.user.permissions);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('صلاحيات ${widget.user.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _all
              .map((perm) => CheckboxListTile(
                    value: _selected!.contains(perm),
                    title: Text(perm),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selected!.add(perm);
                        } else {
                          _selected!.remove(perm);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selected);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
