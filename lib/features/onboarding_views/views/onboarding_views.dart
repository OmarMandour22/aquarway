import 'package:aquarway/core/helper/my_navigator.dart';
import 'package:aquarway/core/utils/app_colors.dart';
import 'package:aquarway/core/utils/assets.dart';
import 'package:aquarway/features/letsstart/letsstart_views.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": Appassets.image1,
      "title": "Find Best Houses",
      "desc": "Search for the best real estate easily"
    },
    {
      "image": Appassets.image2,
      "title": "Easy Booking",
      "desc": "Book property quickly"
    },
    {
      "image": Appassets.image3,
      "title": "Safe Payment",
      "desc": "Secure payment system"
    },
    {
      "image": Appassets.image4,
      "title": "Trusted Agents",
      "desc": "Deal with trusted real estate agents"
    },
    {
      "image": Appassets.image5,
      "title": "Best Locations",
      "desc": "Find houses in the best locations"
    },
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// Skip
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LetsStart(),
                        ),
                      );
                    },
                    child: const Text("Skip"),
                  ),
                ),

                /// الصفحات
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      bool active = index == currentPage;

                      return buildPage(
                        image: page["image"]!,
                        title: page["title"]!,
                        desc: page["desc"]!,
                        active: active,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// المؤشر
                SmoothPageIndicator(
                  controller: controller,
                  count: pages.length,
                  effect: const WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    activeDotColor: Colors.green,
                  ),
                ),

                const SizedBox(height: 30),

                /// الزرار
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.grenblak,
                    ),
                    onPressed: () {
                      if (currentPage == pages.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LetsStart(),
                          ),
                        );
                      } else {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      currentPage == pages.length - 1
                          ? "Get Started"
                          : "Next",
                      style: const TextStyle(
                        color: Colors.white, // 👈 اتضافت هنا
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String desc,
    required bool active,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          image,
          width: 320,
          height: 320,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 40),

        AnimatedSlide(
          offset: active ? Offset.zero : const Offset(0, 0.3),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        AnimatedSlide(
          offset: active ? Offset.zero : const Offset(0, 0.3),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: const Duration(milliseconds: 700),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}