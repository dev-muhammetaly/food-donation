import 'package:flutter/material.dart';

import '../utils/app_colors.dart';


class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _hidden,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            hintText: widget.hint ?? widget.label,
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, size: 20, color: AppColors.textSecondary),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                    tooltip: _hidden ? 'Show password' : 'Hide password',
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
