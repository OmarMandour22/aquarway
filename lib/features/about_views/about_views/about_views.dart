import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const Color customTeal = Color(0xFF4C807E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "شروط الاستخدام",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: customTeal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Text(
                    "شروط الاستخدام - تطبيق AQUARWAY",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: customTeal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "الإصدار 1.0 | 2026",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            sectionText(
              "في Aquarway نؤمن بأن إيجاد العقار المناسب يجب أن يكون تجربة سهلة وممتعة للجميع...",
            ),

            sectionTitle("اقرأ الشروط بعناية"),
            sectionText(
              "يرجى قراءة شروط الاستخدام هذه بعناية قبل استخدام التطبيق...",
            ),

            sectionTitle("الخدمات الرئيسية"),
            sectionText(
              "1. البحث عن العقارات...\n2. عرض التفاصيل...\n3. الخرائط...",
            ),

            sectionTitle("ما يحظر عليك فعله"),
            sectionText(
              "1. الاستخدام غير القانوني...\n2. الاختراق...\n3. النسخ...",
            ),

            sectionTitle("النقاط القانونية المهمة"),
            sectionText(
              "التطبيق يعمل كوسيط فقط ولا يتحمل مسؤولية أي معاملات...",
            ),

            const SizedBox(height: 30),
            const Divider(color: customTeal),

            const Center(
              child: Column(
                children: [
                  Text(
                    "شكراً لاستخدامك AQUARWAY",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: customTeal,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "جميع الحقوق محفوظة © 2026",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: customTeal,
        ),
      ),
    );
  }

  static Widget sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: Colors.black87,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}