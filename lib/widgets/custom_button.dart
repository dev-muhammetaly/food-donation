import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Full-width primary action button with a built-in loading state.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: style.copyWith(
          foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.border),
          ),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: style.copyWith(
        backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        elevation: const WidgetStatePropertyAll(0),
      ),
      child: child,
    );
  }
}
