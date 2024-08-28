import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Use',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Welcome to EduKid, the educational application for kids!\n\n'
                    'By using EduKid, you agree to the following terms and conditions:\n\n'
                    '1. Content: EduKid provides educational content designed for children to learn and have fun. '
                    'The content includes interactive games, quizzes, videos, and other educational materials.\n\n'
                    '2. Parental Supervision: Parents or guardians are responsible for supervising their children '
                    'while using EduKid to ensure appropriate usage and safety.\n\n'
                    '3. Privacy: EduKid respects your privacy and does not collect any personal information '
                    'from children without parental consent. Please review our Privacy Policy for more information.\n\n'
                    '4. Prohibited Activities: Users are prohibited from engaging in any activities that may '
                    'disrupt or harm the functionality of EduKid or violate the rights of others.\n\n'
                    '5. Feedback: We welcome feedback and suggestions to improve EduKid. Please contact us '
                    'if you have any questions, concerns, or feedback.\n\n'
                    'By using EduKid, you acknowledge that you have read, understood, and agreed to these terms '
                    'and conditions. If you do not agree with any part of these terms, please do not use EduKid.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TermsOfUseScreen(),
  ));
}
