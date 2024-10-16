import 'package:cloud_firestore/cloud_firestore.dart';

// Helper function to validate promo code
Future<double?> validatePromoCode(String promoCode) async {
  if (promoCode.isEmpty) {
    print('Please enter a promo code');
    return null;
  }

  try {
    // Query Firebase to check if the promo code exists
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Coupons')
        .where('code', isEqualTo: promoCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Promo code exists, fetch the discount value
      final discount = querySnapshot.docs.first['discount'];
      print('Promo code applied. Discount: $discount%');
      return discount; // Return the discount
    } else {
      // Promo code does not exist
      print('Invalid promo code');
      return null;
    }
  } catch (e) {
    print('Error validating promo code: $e');
    return null;
  }
}
