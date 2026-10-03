import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/send_money/send_money_screen.dart';
import 'screens/transactions/transaction_history_screen.dart';
import 'screens/security/customer_security_center_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UpayApp());
}

class UpayApp extends StatelessWidget {
  const UpayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'upay Trust & Risk Intelligence',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.sendMoney: (_) => const SendMoneyScreen(),
          AppRoutes.transactions: (_) => const TransactionHistoryScreen(),
          AppRoutes.security: (_) => const CustomerSecurityCenterScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
          AppRoutes.admin: (_) => const AdminDashboardScreen(),
          AppRoutes.adminLogin: (_) => const AdminLoginScreen(),
        },
      ),
    );
  }
}

