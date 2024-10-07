import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../features/shop/models/brand_model.dart';
import '../../../../utils/exception/my_firebase_exception.dart';
import '../../../../utils/exception/my_format_exception.dart';
import '../../../../utils/exception/my_platform_exception.dart';


class BrandRepository extends GetxController {
  static BrandRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<List<BrandModel>> getAllBrands() async {
    try {
      final snapshot = await _db.collection('Brands').get();

      if (snapshot.docs.isNotEmpty) {
        final result = snapshot.docs.map((e) => BrandModel.fromSnapshot(e)).toList();
        return result;
      } else {
        return []; // Return an empty list or handle accordingly
      }
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching Banners.';
    }
  }

  Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
    try {



      // Query to get all documents where categoryId matches the provided categoryId
      QuerySnapshot brandCategoryQuery = await _db.collection('BrandCategory')
          .where('categoryId', isEqualTo: categoryId)

          .get();

      // Print the result
      print('Brand Category Query Result: ${brandCategoryQuery.docs.map((doc) => doc.data()).toList()}');

      // Extract brandIds from the documents
      List<String> brandIds = brandCategoryQuery.docs.map((doc) => doc['brandId'] as String).toList();



      // Query to get all documents where the brand Id is in the list of brandIds, FieldPath.documentId to query documents in Collection
      final brandsQuery = await _db.collection('Brands').where(
          FieldPath.documentId, whereIn: brandIds).get();


      // Extract brand names or other relevant data from the documents
      List<BrandModel> brands = brandsQuery.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();

      return brands;

    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching Banners.';
    }
  }
}
