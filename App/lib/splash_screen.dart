import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'generated/l10n/app_localizations.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _navigated = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _initAnimations();
    _waitForAdThenNavigate();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );

    _bannerAd?.load();
  }

  // 等待广告：最多10秒。广告加载成功后再等3秒进入主页；若10秒仍未加载，则直接进入
  void _waitForAdThenNavigate() async {
    final start = DateTime.now();
    const maxWait = Duration(seconds: 10);

    // 轮询等待广告加载完成或超时
    while (!_isAdLoaded && DateTime.now().difference(start) < maxWait) {
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // 再额外等待3秒，保证广告有展示时间
    await Future.delayed(const Duration(seconds: 23));

    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00BCD4),
              const Color(0xFF00BCD4).withOpacity(0.8),
              const Color(0xFF0097A7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo图标
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/icons/app_icon.png',
                                    width: 100, // 图标放大
                                    height: 100, // 图标放大
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // 应用名称（国际化）
                              Text(
                                AppLocalizations.of(context).appTitle,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // 广告语（国际化）
                              Text(
                                AppLocalizations.of(context).tagline,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              // const SizedBox(height: 16),
                              // // 品牌文案
                              // const Text(
                              //   '合理规划，轻松出发',
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //     color: Colors.white,
                              //     letterSpacing: 1.2,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              const SizedBox(height: 6),
                              const Text(
                                'Travel, Light.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 28),
                              const SizedBox(height: 20),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 8),
                              const SizedBox(height: 28),
                              // 加载指示器
                              const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // 底部横幅广告 - 半透明背景，不影响主体
              if (_isAdLoaded && _bannerAd != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 横幅广告左右留白并圆角
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
