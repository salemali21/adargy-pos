import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _lastBackup;
  final _pointsController = TextEditingController();
  String? _lastBackupPath;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadLoyaltyRule();
    _loadStats();
  }

  Future<void> _loadLoyaltyRule() async {
    final prefs = await SharedPreferences.getInstance();
    final rule = prefs.getInt('loyalty_rule') ?? 1;
    _pointsController.text = rule.toString();
  }

  Future<void> _saveLoyaltyRule() async {
    final val = int.tryParse(_pointsController.text) ?? 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loyalty_rule', val);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم حفظ قاعدة النقاط')));
  }

  Future<void> _backupData() async {
    final prefs = await SharedPreferences.getInstance();
    final customers = prefs.getString('customers') ?? '[]';
    final products = prefs.getString('products') ?? '[]';
    final invoices = prefs.getString('invoices') ?? '[]';
    final users = prefs.getString('users') ?? '[]';
    final data = jsonEncode({
      'customers': customers,
      'products': products,
      'invoices': invoices,
      'users': users,
      'timestamp': DateTime.now().toIso8601String(),
    });
    // تشفير البيانات بمفتاح ثابت
    final key = encrypt.Key.fromUtf8('adargyappkey1234'); // 16 chars
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/adargy_backup_${DateTime.now().millisecondsSinceEpoch}.bak');
    await file.writeAsBytes(encrypted.bytes);
    setState(() {
      _lastBackup = DateTime.now().toString();
      _lastBackupPath = file.path;
    });
    _loadStats();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ النسخة الاحتياطية بنجاح')));
  }

  Future<void> _restoreData() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final key = encrypt.Key.fromUtf8('adargyappkey1234');
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      try {
        final decrypted = encrypter.decrypt(encrypt.Encrypted(bytes), iv: iv);
        final data = jsonDecode(decrypted);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('customers', data['customers'] ?? '[]');
        await prefs.setString('products', data['products'] ?? '[]');
        await prefs.setString('invoices', data['invoices'] ?? '[]');
        await prefs.setString('users', data['users'] ?? '[]');
        setState(() {
          _lastBackup = data['timestamp'] ?? DateTime.now().toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت الاستعادة بنجاح!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل في فك التشفير أو قراءة الملف')));
      }
    }
  }

  // Placeholder: مزامنة سحابية (للتنفيذ لاحقًا مع Django backend)
  Future<void> syncToCloud() async {
    // TODO: ربط مع API Django لرفع النسخة الاحتياطية
  }
  Future<void> syncFromCloud() async {
    // TODO: ربط مع API Django لاسترجاع النسخة الاحتياطية
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final customers = prefs.getString('customers') ?? '[]';
    final products = prefs.getString('products') ?? '[]';
    final invoices = prefs.getString('invoices') ?? '[]';
    final users = prefs.getString('users') ?? '[]';
    setState(() {
      _stats = {
        'العملاء': (customers == '[]') ? 0 : (customers.split('},').length),
        'المنتجات': (products == '[]') ? 0 : (products.split('},').length),
        'الفواتير': (invoices == '[]') ? 0 : (invoices.split('},').length),
        'المستخدمون': (users == '[]') ? 0 : (users.split('},').length),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_backup')),
        actions: [
          if (_lastBackupPath != null)
            Tooltip(
              message: 'مشاركة النسخة الاحتياطية الأخيرة',
              child: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  await SharePlus.instance
                      .share(
                    ShareParams(
                        files: [XFile(_lastBackupPath!)],
                        text: 'نسخة احتياطية'),
                  )
                      .then((_) {
                    if (!mounted) return;
                    // استخدم context هنا إذا لزم
                  });
                },
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // رسم بياني صغير لملخص البيانات
            if (_stats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  height: 120,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: [
                        for (int i = 0; i < _stats.length; i++)
                          BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                                toY: _stats.values.elementAt(i).toDouble(),
                                color: Colors.blue)
                          ])
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < _stats.length) {
                                return Text(
                                    _stats.keys.elementAt(value.toInt()),
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
                ),
              ),
            Text(tr('backup_and_restore'),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('كل '),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '1'),
                  ),
                ),
                const Text(' ريال = 1 نقطة'),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveLoyaltyRule,
                  child: const Text('حفظ القاعدة'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.backup),
              label: const Text('نسخ احتياطي الآن'),
              onPressed: _backupData,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text('استعادة نسخة احتياطية'),
              onPressed: _restoreData,
            ),
            const SizedBox(height: 16),
            Text('آخر نسخة احتياطية: ${_lastBackup ?? 'لم يتم بعد'}'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_sync),
              label: const Text('مزامنة سحابية (قريبًا)'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('مزامنة سحابية'),
                    content: const Text(
                        'سيتم دعم المزامنة السحابية مع السيرفر قريبًا. يمكنك تفعيل التنبيه عند توفرها.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('حسناً'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
