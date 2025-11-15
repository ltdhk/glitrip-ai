import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/core/database/database_helper.dart';
import 'package:glitrip/core/providers/locale_provider.dart';
import 'package:glitrip/features/destinations/presentation/pages/destinations_page.dart';
import 'package:glitrip/features/todos/presentation/pages/todos_page.dart';
import 'package:glitrip/features/packing/presentation/pages/packing_page.dart';
import 'package:glitrip/features/profile/presentation/pages/profile_page.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import 'package:glitrip/features/auth/presentation/pages/login_page.dart';
import 'package:glitrip/features/auth/presentation/providers/auth_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'splash_screen.dart';

void main() async {
  //确保初始化
  WidgetsFlutterBinding.ensureInitialized();

  //初始化Google Mobile Ads
  await MobileAds.instance.initialize();

  // 初始化数据库
  await DatabaseHelper.instance.database;

  //运行应用
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Glitrip AI',
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BCD4),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00BCD4),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MyHomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// 认证包装器 - 检查用户登录状态
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // 显示加载状态
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 根据认证状态显示不同页面
    if (authState.user != null) {
      return const MyHomePage();
    } else {
      return const LoginPage();
    }
  }
}

// 导出MyHomePage供启动页使用
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DestinationsPage(),
    const TodosPage(),
    const PackingPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF00BCD4),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.flight_takeoff),
            label: l10n.destinations,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checklist),
            label: l10n.todos,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.luggage),
            label: l10n.packing,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
