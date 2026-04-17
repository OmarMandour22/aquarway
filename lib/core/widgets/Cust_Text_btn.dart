import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_tutorial/core/utils/app_colors.dart';
// import 'package:flutter_tutorial/core/utils/app_text_styles.dart';

import '../utils/app_colors.dart';

class CustomTextBtn extends StatelessWidget {
  const CustomTextBtn({super.key, required this.text, required this.onPressed});

  final String text;
  final  void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.black
          ),
        ));
  }
}