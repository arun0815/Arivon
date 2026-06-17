import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPage extends StatelessWidget {
   PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: _PrivacyContent(),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _LastUpdated('January 1, 2025'),
        SizedBox(height: 24),

        _Section(
          title: '1. Information We Collect',
          body:
              'When you sign in with Google, we collect your name, email address, and profile photo provided by your Google account. We also collect academic information you voluntarily provide such as institute, department, and semester.',
        ),

        _Section(
          title: '2. How We Use Your Information',
          body:
              'We use your information solely to provide and improve EduHub\'s features — including personalizing your academic dashboard, saving your profile, and displaying relevant content. We do not sell your data to third parties.',
        ),

        _Section(
          title: '3. Google Sign-In',
          body:
              'EduHub uses Google Sign-In for authentication. By signing in, you authorize us to access your basic Google profile (name, email, profile photo). We do not access your Google Drive, Gmail, or any other Google services.',
        ),

        _Section(
          title: '4. Data Storage',
          body:
              'Your data is stored securely on our servers hosted on Vercel and MongoDB Atlas. We use industry-standard encryption and security practices to protect your information from unauthorized access.',
        ),

        _Section(
          title: '5. Data Sharing',
          body:
              'We do not share, sell, rent, or trade your personal information with any third parties for their commercial purposes. We may share data with service providers who assist us in operating the app under strict confidentiality agreements.',
        ),

        _Section(
          title: '6. Data Retention',
          body:
              'We retain your data as long as your account is active. If you delete your account, we will permanently remove your personal information from our servers within 30 days, except where retention is required by law.',
        ),

        _Section(
          title: '7. Your Rights',
          body:
              'You have the right to access, correct, or delete your personal data at any time through the app\'s profile settings. You may also request a copy of the data we hold about you by contacting us.',
        ),

        _Section(
          title: '8. Children\'s Privacy',
          body:
              'EduHub is intended for users aged 13 and above. We do not knowingly collect personal information from children under 13. If we become aware that a child under 13 has provided us data, we will delete it promptly.',
        ),

        _Section(
          title: '9. Changes to This Policy',
          body:
              'We may update this Privacy Policy from time to time. We will notify you of any significant changes via in-app notification. Your continued use of EduHub after changes constitutes acceptance of the updated policy.',
        ),

        _Section(
          title: '10. Contact Us',
          body:
              'If you have any questions or concerns about this Privacy Policy or how we handle your data, please contact us at privacy@eduhub.app.',
        ),
      ],
    );
  }
}

class _LastUpdated extends StatelessWidget {
  final String date;
  const _LastUpdated(this.date);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Last updated: $date',
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textTert,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSec,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
