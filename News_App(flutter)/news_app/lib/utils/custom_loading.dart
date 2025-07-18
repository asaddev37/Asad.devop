import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/colors.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.midnightBlack.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Lottie.asset(
          'assets/loading.json',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            print('Loading animation loaded: assets/loading.json');
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading animation: $error');
            return const CircularProgressIndicator(color: AppColors.neonPink);
          },
        ),
      ),
    );
  }
}