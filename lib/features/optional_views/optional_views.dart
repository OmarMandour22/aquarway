import 'package:aquarway/core/helper/my_navigator.dart';
import 'package:aquarway/core/translation/translation_key.dart';
import 'package:aquarway/core/widgets/Custm_btn.dart';
import 'package:aquarway/features/auth/views/login_views.dart';
import 'package:aquarway/features/auth/views/register_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../language/cubit/language_cubit.dart';
import '../language/views/app_language.dart';

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
              '${AppLanguage.translations[
              context.watch<LanguageCubit>().state.languageCode
              ]?["lets_get_started"] ?? "Let\'s get started!"}\n'
                  '${AppLanguage.translations[
              context.watch<LanguageCubit>().state.languageCode
              ]?["login_or_register_to_continue"] ?? "Login or Register to continue"}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
