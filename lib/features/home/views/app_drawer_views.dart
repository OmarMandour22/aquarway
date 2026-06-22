import 'package:aquarway/core/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../main.dart';
import '../../about_views/about_views/about_views.dart';
import '../../auth/data/model/user_model.dart';
import '../../auth/data/repo/auth_repo.dart';
import '../../auth/views/login_views.dart';
import '../../change_password/views/change_password_views.dart';
import '../../language/cubit/language_cubit.dart';
import '../../language/views/app_language.dart';
import '../../location/views/location-views.dart';
import '../../profile/views/profile_views.dart';
import 'favorites_view.dart';

class AppDrawer extends StatefulWidget {
  final UserModel userModel;

  const AppDrawer({super.key, required this.userModel});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _address;

  @override
  void initState() {
    super.initState();
    _address = widget.userModel.address;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: AppColors.grenblak,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage: widget.userModel.image != null &&
                        widget.userModel.image!.isNotEmpty
                        ? NetworkImage(widget.userModel.image!)
                        : null,
                    child: (widget.userModel.image == null ||
                        widget.userModel.image!.isEmpty)
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userModel.username ?? "No Name",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    widget.userModel.email ?? "",
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            /// LOCATION (افتح الخريطة)
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: Text(
                _address ??
                    AppLanguage.translations[
                    context.watch<LanguageCubit>().state.languageCode
                    ]?["no_location"] ??
                    "No Location",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocationView(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _address = result["address"];
                    // ممكن تحدث الـ userModel لو محتاج
                    widget.userModel.address = _address;
                  });
                }
              },
            ),

            /// PROFILE
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                AppLanguage.translations[
                context.watch<LanguageCubit>().state.languageCode
                ]?["profile"] ??
                    "Profile",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileView(
                      uid: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                "${AppLanguage.translations[
                context.watch<LanguageCubit>().state.languageCode
                ]?["language"] ?? "Language"} : "
                    "${context.watch<LanguageCubit>().state.languageCode == "ar" ? "العربية" : "English"}",
              ),
              onTap: () {
                context.read<LanguageCubit>().changeLanguage();
              },
            ),


            ListTile(
              leading: const Icon(Icons.star),
              title: Text(
                AppLanguage.translations[
                context.watch<LanguageCubit>().state.languageCode
                ]?["favorites"] ??
                    "Favorites",
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FavoritesView(),
                  ),
                );
              },
            ),


            ListTile(
              leading: const Icon(Icons.dark_mode),
                title: Text(
                  AppLanguage.translations[
                  context.watch<LanguageCubit>().state.languageCode
                  ]?["dark_mode"] ??
                      "Dark Mode",
                ),
                onTap: () async {
                  bool isDark = themeNotifier.value == ThemeMode.dark;

                  themeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark;

                  await saveTheme(!isDark);
                }

                ),

            ListTile(
              leading: const Icon(Icons.lock),
              title: Text(
                AppLanguage.translations[
                context.watch<LanguageCubit>().state.languageCode
                ]?["change_password"] ??
                    "Change Password",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordView()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.description),
              title: Text(
                AppLanguage.translations[
                context.watch<LanguageCubit>().state.languageCode
                ]?["about_us"] ??
                    "About us",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
                title: Text(
                  AppLanguage.translations[
                  context.watch<LanguageCubit>().state.languageCode
                  ]?["logout"] ??
                      "Log out",
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginViews()),
                        (route) => false,
                  );
                }            ),

            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  AppLanguage.translations[
                  context.watch<LanguageCubit>().state.languageCode
                  ]?["delete_account"] ??
                      "Delete Account",
                ),
                onTap: () async {
                  var error = await AuthRepo().deleteAccount();

                  if (error == null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginViews()),
                          (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error)));
                  }
                }            ),
          ],
        ),
      ),
    );
  }
}