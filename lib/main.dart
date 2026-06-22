import 'package:aquarway/features/splashviews/splash_views.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'features/language/cubit/language_cubit.dart';

/// =======================
/// THEME
/// =======================

ValueNotifier<ThemeMode> themeNotifier =
ValueNotifier(ThemeMode.light);

Future<void> loadTheme() async {

  final prefs = await SharedPreferences.getInstance();

  bool isDark =
      prefs.getBool("isDark") ?? false;

  themeNotifier.value =
  isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> saveTheme(bool isDark) async {

  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool("isDark", isDark);
}

/// =======================
/// MAIN
/// =======================

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await loadTheme();

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(

      providers: [

        BlocProvider(
          create: (_) => LanguageCubit(),
        ),

      ],

      child: Builder(

        builder: (context) {

          return ValueListenableBuilder(

            valueListenable: themeNotifier,

            builder: (context,
                ThemeMode currentMode,
                child) {

              return BlocBuilder<LanguageCubit, Locale>(

                builder: (context, locale) {

                  return MaterialApp(

                    debugShowCheckedModeBanner: false,

                    /// =======================
                    /// LANGUAGE
                    /// =======================

                    locale: locale,

                    supportedLocales: const [

                      Locale('en'),
                      Locale('ar'),

                    ],

                    localizationsDelegates: const [

                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,

                    ],

                    /// =======================
                    /// THEME
                    /// =======================

                    themeMode: currentMode,

                    theme: ThemeData.light(),

                    darkTheme: ThemeData.dark(),

                    /// =======================
                    /// HOME
                    /// =======================

                    home: SplashView(),

                  );

                },

              );

            },

          );

        },

      ),

    );

  }

}