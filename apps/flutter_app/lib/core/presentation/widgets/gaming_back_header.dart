import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'gaming_icon_button.dart';

/// Header with back button and centered title
class GamingBackHeader extends StatelessWidget {
  final VoidCallback onBack;
  final String title;

  const GamingBackHeader({
    super.key,
    required this.onBack,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GamingIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: onBack,
            size: 40,
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }
}
