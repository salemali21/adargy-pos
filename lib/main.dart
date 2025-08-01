import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/blocs/language/language_cubit.dart';
import 'core/theme/app_theme.dart';
import 'app.dart';
import 'core/utils/simple_app_icon.dart';
import 'features/products/bloc/products_cubit.dart';
import 'features/customers/bloc/customers_cubit.dart';
import 'features/sales/bloc/invoices_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إنشاء أيقونة التطبيق
  await SimpleAppIcon.generateIcon();

  await EasyLocalization.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('fr'),
        Locale('tr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return const AdargyApp();
        },
      ),
    ),
  );
}

class AdargyApp extends StatelessWidget {
  const AdargyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => ProductsCubit()..loadProducts()),
        BlocProvider(create: (_) => CustomersCubit()..loadCustomers()),
        BlocProvider(create: (_) => InvoicesCubit()..loadInvoices()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: tr('app_name'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}
