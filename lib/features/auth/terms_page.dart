import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TermsPage extends StatelessWidget {
   TermsPage({super.key});

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
          'Terms of Service',
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
        child: _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _LastUpdated('January 1, 2025'),
        SizedBox(height: 24),

        _Section(
          title: '1. Acceptance of Terms',
          body:
              'By accessing or using EduHub, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our application.',
        ),

        _Section(
          title: '2. Use of the App',
          body:
              'EduHub is an academic companion app for students. You agree to use the app only for lawful purposes and in a manner that does not infringe the rights of others. You must not misuse, disrupt, or attempt to gain unauthorized access to any part of the service.',
        ),

        _Section(
          title: '3. Account & Authentication',
          body:
              'You sign in using your Google account. You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account. Notify us immediately of any unauthorized use.',
        ),

        _Section(
          title: '4. User Content',
          body:
              'Any content you submit or upload remains your responsibility. We do not claim ownership of your content, but by submitting it you grant us a limited license to display and store it for the purpose of providing the service.',
        ),

        _Section(
          title: '5. Intellectual Property',
          body:
              'All content, design, logos, and software in EduHub are the intellectual property of EduHub and its licensors. You may not copy, reproduce, or distribute any part of the app without prior written permission.',
        ),

        _Section(
          title: '6. Limitation of Liability',
          body:
              'EduHub is provided "as is" without warranties of any kind. We are not liable for any indirect, incidental, or consequential damages arising from your use of the app, including loss of data or academic performance.',
        ),

        _Section(
          title: '7. Termination',
          body:
              'We reserve the right to suspend or terminate your access at any time if you violate these terms or engage in conduct we determine to be harmful to other users or the service.',
        ),

        _Section(
          title: '8. Changes to Terms',
          body:
              'We may update these terms from time to time. Continued use of EduHub after changes means you accept the revised terms. We will notify users of significant changes via the app.',
        ),

        _Section(
          title: '9. Contact',
          body:
              'For questions about these Terms, contact us at support@eduhub.app.',
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
