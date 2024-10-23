import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/shop/screens/account_privacy/terms_of_use/terms_of_use.dart';
import 'package:webedukid/utils/constants/sizes.dart';


class AccountPrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Privacy'),
        centerTitle: true, // Center the title
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600), // Set maximum width to 600
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Base padding around content
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align content to the top
              crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
              mainAxisSize: MainAxisSize.min, // Minimize height usage
              children: [
                Text(
                  'Data Management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: MySizes.spaceBtwInputItems),
                Text(
                  'Learn about how we handle your data and your privacy rights.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                // Paragraph about account privacy
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust this padding as needed
                  child: Text(
                    "At EduKid, your privacy is our priority. We are committed to safeguarding your personal information and ensuring a safe and secure experience on our platform. We only collect the necessary data to provide you with personalized learning experiences and never share your information with third parties without your explicit consent. You have full control over your account settings, where you can manage your data, adjust privacy preferences, and delete your account at any time.\n\nWe also provide detailed terms of use to inform you about our data management practices. If you need assistance or have any questions regarding your privacy, our Customer Support team is always ready to help. EduKid is dedicated to creating a trusted environment where you can focus on learning, knowing that your data is protected.",
                    style: TextStyle(fontSize: 12, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  title: Center(
                    child: Text(
                      'Terms of Use',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  onTap: () => showTermsOfUseDialog(context), // Use the dialog function
                ),
                ListTile(
                  title: Center(
                    child: Text(
                      'Customer Support',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  onTap: () {
                    // Handle navigating to the customer support screen
                  },
                ),
                Divider(),
                ListTile(
                  title: Center(
                    child: Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  onTap: () {
                    // Handle deleting the user account
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AccountPrivacyScreen(),
  ));
}
