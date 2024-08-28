import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../common/data/repositories.authentication/categories/category_repository.dart';
import '../../../common/data/repositories.authentication/product/product_repository.dart';
import '../../../common/widgets/loaders/loaders.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();
  final isLoading = false.obs;
  final _categoryRepository = Get.put(CategoryRepository());
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final categories = await _categoryRepository.getAllCategories();
      allCategories.assignAll(categories);

      featuredCategories.assignAll(
        allCategories
            .where(
                (category) => category.isFeatured && category.parentId.isEmpty)
            .take(8)
            .toList(),
      );
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Load selected category data
  Future<List<CategoryModel>> getSubCategories(String categoryId) async {
    try {
      final subCategories = await _categoryRepository.getSubCategories(categoryId);
      return subCategories;
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Get Category or sub category products

  Future<List<ProductModel>> getCategoryProducts(
      {required String categoryId, int limit = 4}) async {
    try {


      // Fetch Limited (4) products against each subcategory;
      final products = await ProductRepository.instance
          .getProductsForCategory(categoryId: categoryId, limit: limit);
      return products;
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      // You might want to return an empty list or handle the error appropriately.
      return [];
    }
  }

  /// Get Category or sub category products

  Future<List<ProductModel>> getSubCategoryProducts(
      {required String categoryId, int limit = 4}) async {
    try {


      // Fetch Limited (4) products against each subcategory;
      final products = await ProductRepository.instance
          .getProductsForSubCategory(categoryId: categoryId, limit: limit);
      return products;
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      // You might want to return an empty list or handle the error appropriately.
      return [];
    }
  }
}
