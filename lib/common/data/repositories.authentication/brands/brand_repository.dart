import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../features/shop/models/brand_model.dart';
import '../../../../features/shop/models/product_model.dart'; // Import ProductModel if needed
import '../../../../utils/exception/my_firebase_exception.dart';
import '../../../../utils/exception/my_format_exception.dart';
import '../../../../utils/exception/my_platform_exception.dart';

class BrandRepository extends GetxController {
  static BrandRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Fetch all brands
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final snapshot = await _db.collection('Brands').get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((e) => BrandModel.fromSnapshot(e)).toList();
      } else {
        return [];
      }
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching brands.';
    }
  }

  /// Fetch brand by ID
  Future<BrandModel> getBrandById(String brandId) async {
    try {
      final doc = await _db.collection('Brands').doc(brandId).get();
      if (doc.exists) {
        return BrandModel.fromSnapshot(doc);
      } else {
        throw Exception("Brand not found");
      }
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Error fetching brand by ID.';
    }
  }

  /// Fetch brands for a specific category
  Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
    try {
      final brandCategoryQuery = await _db.collection('BrandCategory')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      List<String> brandIds = brandCategoryQuery.docs.map((doc) => doc['brandId'] as String).toList();

      final brandsQuery = await _db.collection('Brands')
          .where(FieldPath.documentId, whereIn: brandIds)
          .get();

      return brandsQuery.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching brands for the category.';
    }
  }

  /// Fetch products for a specific brand
  Future<List<ProductModel>> getProductsForBrand({required String brandId, int limit = -1}) async {
    try {
      final querySnapshot = limit == -1
          ? await _db.collection('Products').where('BrandId', isEqualTo: brandId).get()
          : await _db.collection('Products').where('BrandId', isEqualTo: brandId).limit(limit).get();

      return querySnapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong while fetching products for the brand.';
    }
  }
}
