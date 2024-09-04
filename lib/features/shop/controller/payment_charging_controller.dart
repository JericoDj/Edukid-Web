import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// A utility function to charge the customer using the Square payment API
Future<bool> chargeCustomer(String customerId, String cardId, double amount) async {
  try {
    final Uuid uuid = Uuid();  // Instantiate the UUID generator

    // Print statements for debugging
    print("Charging customer with ID: $customerId using card ID: $cardId for amount: $amount");

    final response = await http.post(
      Uri.parse('http://localhost:3000/charge-customer'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'customerId': customerId,
        'cardId': cardId, // Use cardId for specifying which card to charge
        'amount': (amount).round(), // Convert to cents
      }),
    );

    if (response.statusCode == 200) {
      print('Payment successful: ${response.body}');
      return true;
    } else {
      print('Payment failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error charging customer: $e');
    return false;
  }
}
