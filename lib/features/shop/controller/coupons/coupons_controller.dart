import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CouponController extends GetxController {
  final CollectionReference _couponsCollection =
  FirebaseFirestore.instance.collection('Coupons');

  RxList<Map<String, dynamic>> coupons = RxList<Map<String, dynamic>>([]);

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _couponsCollection.get() as QuerySnapshot<Map<String, dynamic>>;
      coupons.assignAll(querySnapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error fetching coupons: $e');
    }
  }
}
