import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/helper/my_navigator.dart';
import '../../core/translation/translation_key.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/assets.dart';
import '../../core/widgets/Custm_btn.dart';
import '../optional_views/optional_views.dart';

class LetsStart extends StatefulWidget {
  const LetsStart({super.key});

  @override
  State<LetsStart> createState() => _LetsStartState();
}

class _LetsStartState extends State<LetsStart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Whit,
      body: Center( // 👈 يخلي كل المحتوى في منتصف الشاشة عموديًا
        child: SingleChildScrollView( // 👈 لو الشاشة صغيرة يكون Scrollable
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Appassets.logo,
                width: 300, // أصغر حجم عشان يناسب كل الشاشات
                height: 250,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 20),

              Text(
                'Welcome AQUARWAY !',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 15),

              Text(
                'Ready to find your perfect place?\nLet’s do it together.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              CustmBtn(
                text: TranslationKeys.LetsStart,
                width: 180,   // 👈 عرض الزرار
                height: 45,   // 👈 ارتفاع الزرار
                fontSize: 18, // 👈 حجم الخط
                onPressed: () => goto(context, const OptionalViews()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
