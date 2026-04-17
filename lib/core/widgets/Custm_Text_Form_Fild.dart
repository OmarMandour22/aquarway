import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustmTextFormFild extends StatelessWidget {
  const CustmTextFormFild({
    super.key,
    required this.controller,
    required this.prefixIcon,
    this.suffixIcon,
    required this.hintText,
    required this.obscureText,
    this.validator,
    this.height,      // ارتفاع اختياري
    this.width,       // عرض اختياري
    this.fontSize,    // حجم الخط اختياري
    this.contentPadding, // padding داخلي اختياري
  });

  final TextEditingController controller;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final String hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final double? height;
  final double? width;
  final double? fontSize;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,  // 👈 عرض افتراضي كامل
      height: height ?? 40,             // 👈 ارتفاع افتراضي أصغر
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          color: AppColors.black,
          fontSize: fontSize ?? 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: hintText, // 👈 بدل hintText
          floatingLabelBehavior: FloatingLabelBehavior.auto, // 👈 يخلي النص يطلع فوق
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: borderBuilder(),
          enabledBorder: borderBuilder(),
          focusedBorder: borderBuilder(color: AppColors.primary),
          focusedErrorBorder: borderBuilder(color: AppColors.primary),
          errorBorder: borderBuilder(color: AppColors.red),
        ),
      ),
    );
  }

  InputBorder borderBuilder({Color color = AppColors.lightGrey}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(
      color: color,
    ),
  );
}
