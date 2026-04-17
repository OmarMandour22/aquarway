import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustmBtn extends StatelessWidget {
  const CustmBtn({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,    // 👈 عرض اختياري
    this.height,   // 👈 ارتفاع اختياري
    this.fontSize, // 👈 حجم الخط اختياري
  });

  final String text;
  final void Function()? onPressed;
  final double? width;
  final double? height;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,   // Full width افتراضي
      height: height ?? 50,              // ارتفاع افتراضي
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.grenblak,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: AppColors.primary,
          elevation: 10,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? 25,   // حجم الخط الافتراضي
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
