import 'package:aquarway/core/helper/my_navigator.dart';
import 'package:aquarway/core/translation/translation_key.dart';
import 'package:aquarway/core/widgets/Custm_btn.dart';
import 'package:aquarway/features/auth/views/login_views.dart';
import 'package:aquarway/features/auth/views/register_views.dart';
import 'package:flutter/material.dart';

class OptionalViews extends StatelessWidget {
  const OptionalViews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CustmBtn(
                text: TranslationKeys.Loging,
                width: 300,
                height: 55,
                fontSize: 18,
                onPressed: () => goto(context, LoginViews())
            ),

            const SizedBox(height: 30,),

            CustmBtn(
                text: TranslationKeys.Register,
                width: 300,
                height: 55,
                fontSize: 18,
                onPressed: () => goto(context, RegisterViews())
            ),

            const SizedBox(height: 30,),

            Text(
              'Let’s get started!\n Login or Register to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,                 // حجم الخط
                fontWeight: FontWeight.w500,  // سمك الخط
                color: Colors.grey[800],      // لون الخط
              ),
            ),
          ],
        ),
      ),
    );
  }
}
