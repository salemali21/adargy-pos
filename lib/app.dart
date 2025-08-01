import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';
import 'features/language/language_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/dashboard_screen.dart';
import 'features/customers/screens/customers_screen.dart';
import 'features/products/screens/products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/customers/bloc/customers_cubit.dart';
import 'features/products/bloc/products_cubit.dart';
import 'features/sales/screens/sale_screen.dart';
import 'features/sales/screens/invoices_screen.dart';
import 'features/sales/bloc/invoices_cubit.dart';
import 'features/products/screens/inventory_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/support/support_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/kitchen/kitchen_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/language':
        return MaterialPageRoute(builder: (_) => const LanguageScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/customers':
        return MaterialPageRoute(
            builder: (_) => BlocProvider(
                  create: (_) => CustomersCubit(),
                  child: const CustomersScreen(),
                ));
      case '/products':
        return MaterialPageRoute(
            builder: (_) => BlocProvider(
                  create: (_) => ProductsCubit(),
                  child: const ProductsScreen(),
                ));
      case '/inventory':
        return MaterialPageRoute(
            builder: (_) => BlocProvider(
                  create: (_) => ProductsCubit()..loadProducts(),
                  child: const InventoryScreen(),
                ));
      case '/sale':
        return MaterialPageRoute(builder: (_) => const SaleScreen());
      case '/invoices':
        return MaterialPageRoute(builder: (_) => const InvoicesScreen());
      case '/reports':
        return MaterialPageRoute(
            builder: (_) => BlocProvider(
                  create: (_) => InvoicesCubit()..loadInvoices(),
                  child: const ReportsScreen(),
                ));
      case '/support':
        return MaterialPageRoute(builder: (_) => const SupportScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/kitchen':
        return MaterialPageRoute(builder: (_) => const KitchenScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
