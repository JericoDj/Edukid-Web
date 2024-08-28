import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:webedukid/features/shop/screens/account_privacy/terms_of_use/terms_of_use.dart';

class AccountPrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Privacy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Terms of Use'),
              onTap: () => Get.to (() => TermsOfUseScreen()),
            ),
            ListTile(
              title: Text('Customer Support'),
              onTap: () {
                // Handle navigating to the customer support screen
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                // Handle deleting the user account
              },
            ),
          ],
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
