import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.elasticOut,
    ));

    _animationController!.forward();
    _navigateNext();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('lang');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (lang == null) {
      Navigator.of(context).pushReplacementNamed('/language');
      return;
    } else if (!isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    } else {
      Navigator.of(context).pushReplacementNamed('/dashboard');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // لون أزرق غامق
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار مع التأثيرات
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation!.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation!,
                      child: Container(
                        width: 150.w,
                        height: 150.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20.r,
                              offset: Offset(0, 10.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.store,
                          size: 80.sp,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 40.h),

              // اسم التطبيق
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation!,
                    child: Text(
                      tr('app_name'),
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 10.h),

              // وصف التطبيق
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation!,
                    child: Text(
                      tr('app_description'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 60.h),

              // مؤشر التحميل
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation!,
                    child: CircularProgressIndicator(
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3.w,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
