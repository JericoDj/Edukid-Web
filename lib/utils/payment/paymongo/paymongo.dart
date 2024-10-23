import 'dart:convert';
import 'package:http/http.dart' as http;

class PayMongo {
  static String apiKey = 'sk_test_yLaKKg5hbBMegiZgMwFvBum4';

  static Future<void> createCharge(double amount) async {
    String url = 'https://api.paymongo.com/v1/payments';

    Map<String, dynamic> requestBody = {
      'data': {
        'attributes': {
          'amount': amount * 100, // Amount in cents
          'description': 'Payment for your product',
          'statement_descriptor': 'YourCompany',
          'payment_method_allowed': ['credit_card'],
          'payment_method_options': {
            'card': {
              'request_three_d_secure': 'automatic'
            }
          },
        }
      }
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestBody),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $apiKey',
        },
      );

      if (response.statusCode == 200) {
        // Charge created successfully
        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        // Handle the response as needed
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}
