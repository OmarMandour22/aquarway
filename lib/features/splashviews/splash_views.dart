import 'package:aquarway/features/auth/views/login_views.dart';
import 'package:aquarway/features/letsstart/letsstart_views.dart';
import 'package:aquarway/features/onboarding_views/views/onboarding_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/helper/my_navigator.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/assets.dart';
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}
class _SplashViewState extends State<SplashView> {
  void initState()
  {
    super.initState();
    Future.delayed(
        Duration(seconds: 4),
            (){
          goto(context, OnBoardingScreen());
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Whit,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Appassets.logo,
            width: 400,
            height: 400,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
