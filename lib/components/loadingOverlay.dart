import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay extends StatelessWidget {
  final bool loading;
  final bool isDark;

  const LoadingOverlay({
    super.key,
    required this.loading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      bottom: loading ? 0 : -screenHeight,
      left: 0,
      right: 0,
      height: screenHeight,
      child: Container(
        color: isDark
            ? const Color.fromARGB(255, 54, 54, 54)
            : const Color.fromARGB(255, 253, 235, 215),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: Lottie.asset(
                'assets/animations/driving.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
