import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_expense/page/auth/login/login.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Color _primary = Color(0xFF3D2C8D);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3D2C8D),
                  Color(0xFF7F5AF0),
                  Color(0xFFB57BFF),
                ],
              ),
            ),
          ),

          // 2. Decorative circles
          Positioned(
            top: -60,
            right: -40,
            child: _circle(200, Colors.white.withAlpha(25)),
          ),
          Positioned(
            top: size.height * 0.25,
            left: -70,
            child: _circle(160, Colors.white.withAlpha(18)),
          ),

          // 3. Skip button (top right)
          Positioned(
            top: 0,
            right: 12,
            child: SafeArea(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigator.pushReplacement to LoginPage
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // 4. Lottie animation
          Positioned(
            top: size.height * 0.08,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Lottie.asset(
              'assets/lottie/expense.json',
              fit: BoxFit.contain,
              repeat: true,
              // Shown if the file is missing, so the page never crashes
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.account_balance_wallet_rounded,
                size: 120,
                color: Colors.white.withAlpha(230),
              ),
            ),
          ),

          // 5. Bottom sheet with text + button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Take Control of\nYour Money',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B1B2F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Track your daily expenses, organize them by category '
                      'and see where every rupee goes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: _primary.withAlpha(120),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}
