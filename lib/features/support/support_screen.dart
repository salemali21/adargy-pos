import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('support')),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.question_answer), text: 'FAQ'),
              Tab(icon: Icon(Icons.contact_mail), text: 'تواصل'),
              Tab(icon: Icon(Icons.chat), text: 'واتساب'),
              Tab(icon: Icon(Icons.ondemand_video), text: 'فيديوهات'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FaqTab(),
            _ContactTab(),
            _WhatsappTab(),
            _VideosTab(),
          ],
        ),
      ),
    );
  }
}

class _FaqTab extends StatelessWidget {
  const _FaqTab();
  @override
  Widget build(BuildContext context) {
    // Placeholder للأسئلة الشائعة
    final faqs = [
      {
        'q': 'كيف أضيف عميل جديد؟',
        'a': 'من شاشة العملاء، اضغط زر الإضافة وأدخل البيانات.'
      },
      {
        'q': 'كيف أستعيد نسخة احتياطية؟',
        'a': 'من الإعدادات، اختر النسخ الاحتياطي ثم استعادة.'
      },
      {
        'q': 'كيف أضيف منتج جديد؟',
        'a': 'من شاشة المنتجات، اضغط زر الإضافة وأدخل تفاصيل المنتج.'
      },
      {
        'q': 'كيف أرسل فاتورة للعميل؟',
        'a': 'من شاشة الفواتير، اختر الفاتورة واضغط زر المشاركة.'
      },
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, i) {
        final q = faqs[i]['q']!;
        final a = faqs[i]['a']!;
        return Card(
          child: ListTile(
            title: Text(q),
            subtitle: Text(a),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'مشاركة',
                  child: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () async {
                      await SharePlus.instance.share(
                        ShareParams(text: 'سؤال: $q\nالإجابة: $a'),
                      );
                    },
                  ),
                ),
                Tooltip(
                  message: 'نسخ',
                  child: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: 'سؤال: $q\nالإجابة: $a'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ السؤال والإجابة')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContactTab extends StatelessWidget {
  const _ContactTab();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('راسلنا عبر البريد الإلكتروني:'),
          const SelectableText('support@adargy.com'),
          Tooltip(
            message: 'إرسال بريد إلكتروني',
            child: IconButton(
              icon: const Icon(Icons.email),
              onPressed: () async {
                final uri = Uri(
                  scheme: 'mailto',
                  path: 'support@adargy.com',
                  query: 'subject=دعم تطبيق إدارجي',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(Uri.parse(uri.toString()));
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('اتصل بنا هاتفياً:'),
          const SelectableText('+966500000000'),
          const SizedBox(height: 16),
          const Text('تواصل عبر تيليجرام:'),
          const SelectableText('t.me/adargy_support'),
        ],
      ),
    );
  }
}

class _WhatsappTab extends StatelessWidget {
  const _WhatsappTab();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('تواصل معنا عبر واتساب:'),
          const SelectableText('+966500000000'),
          Tooltip(
            message: 'فتح واتساب',
            child: IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () async {
                final url = Uri.parse('https://wa.me/966500000000');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VideosTab extends StatelessWidget {
  const _VideosTab();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('فيديوهات الشرح ستتوفر قريبًا.'),
    );
  }
}
