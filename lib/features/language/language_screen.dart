import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _setLanguage(BuildContext context, Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', locale.languageCode);
    await context.setLocale(locale);
    // لا حاجة لتغيير اتجاه النص يدويًا هنا، EasyLocalization وDirectionality كافيان.
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('choose_language'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _setLanguage(context, const Locale('ar')),
              child: Text(tr('arabic')),
            ),
            ElevatedButton(
              onPressed: () => _setLanguage(context, const Locale('en')),
              child: Text(tr('english')),
            ),
            ElevatedButton(
              onPressed: () => _setLanguage(context, const Locale('fr')),
              child: Text(tr('french')),
            ),
            ElevatedButton(
              onPressed: () => _setLanguage(context, const Locale('tr')),
              child: Text(tr('turkish')),
            ),
          ],
        ),
      ),
    );
  }
}
