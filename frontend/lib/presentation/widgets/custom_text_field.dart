import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:guidetar/config/theme.dart';
import 'package:guidetar/utils/app_constants.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.controller,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Gap(8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: AppColors.borderDark,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: _isObscured,
            validator: widget.validator,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: AppColors.textSecondary,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                      child: Icon(
                        _isObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
