import 'package:flutter/material.dart';
import '../theme/ios_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: IOSTheme.tertiaryLabel),
            const SizedBox(height: 16),
            Text(title, style: IOSTheme.headline, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle ?? '',
                style: IOSTheme.body.copyWith(color: IOSTheme.secondaryLabel),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action ?? const SizedBox.shrink(),
            ],
          ],
        ),
      ),
    );
  }
}
