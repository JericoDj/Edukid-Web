import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../features/models/banner_model.dart';
import '../../../../utils/exception/my_firebase_exception.dart';
import '../../../../utils/exception/my_format_exception.dart';
import '../../../../utils/exception/my_platform_exception.dart';


class BannerRepository extends GetxController {
  static BannerRepository get instance => Get.find();

  /// Variables
  final _db = FirebaseFirestore.instance;


  /// Get all order related to current User
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final result = await _db.collection('Banners').where(
          'active', isEqualTo: true).get();

      return result.docs.map((documentSnapshot) =>
          BannerModel.fromSnapshot(documentSnapshot)).toList();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {}
    throw 'Something went wrong while fetching Banners. ';
  }
}