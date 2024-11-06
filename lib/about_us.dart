import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // About Us Header
                Center(
                  child: Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),


                // Company Overview
                const Text(
                  'Our Mission',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'At [Your Company Name], our mission is to provide the best experience and value to our users. We are committed to delivering quality services, innovative solutions, and a user-friendly experience.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // What We Do
                const Text(
                  'What We Do',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Our team of professionals specializes in delivering high-quality solutions tailored to meet the needs of our users. From our carefully designed products to exceptional customer support, we strive to exceed your expectations.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Core Values
                const Text(
                  'Our Core Values',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'We are guided by values that define who we are and what we stand for:',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.teal),
                  title: Text('Integrity'),
                  subtitle: Text('We believe in doing the right thing, even when no one is watching.'),
                ),
                const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.teal),
                  title: Text('Innovation'),
                  subtitle: Text('We continuously seek new ways to improve and provide value to our users.'),
                ),
                const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.teal),
                  title: Text('Customer-Centricity'),
                  subtitle: Text('Our users are at the heart of everything we do.'),
                ),
                const SizedBox(height: 20),

                // Team Section
                const Text(
                  'Meet Our Team',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Our team consists of dedicated professionals with diverse skills and backgrounds. Together, we work tirelessly to bring you the best experience possible.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Contact Information
                const Text(
                  'Get in Touch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'For any inquiries or feedback, feel free to reach out to us at:',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Email: dejesusjerico528@gmail.com', // Replace with your contact email
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),


                // Call to Action

              ],
            ),
          ),
        ),
      ),
    );
  }
}
