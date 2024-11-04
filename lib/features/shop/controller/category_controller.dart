import 'package:get/get.dart';
import '../../../common/data/repositories.authentication/categories/category_repository.dart';
import '../../../common/data/repositories.authentication/product/product_repository.dart';
import '../../../common/widgets/loaders/loaders.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CategoryController extends GetxController {
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  // Singleton instance
  static CategoryController get instance => Get.find();

  // Observables
  final isLoading = false.obs;
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;
  var selectedCategory = Rxn<CategoryModel>();  // Observable to store selected category

  // Repositories
  final _categoryRepository = Get.put(CategoryRepository());

  @override
  void onInit() {
    super.onInit();
    fetchCategories(); // Fetch categories on controller initialization
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final categories = await _categoryRepository.getAllCategories();
      allCategories.assignAll(categories ?? []);

      print('Fetched Categories: ${allCategories.length}');

      featuredCategories.assignAll(
        allCategories
            .where((category) => category != null && category.isFeatured && category.parentId.isEmpty)
            .take(8)
            .toList(),
      );

      print('Featured Categories: ${featuredCategories.length}');
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Setter method to update the selected category
  void setSelectedCategory(CategoryModel category) {
    selectedCategory.value = category;
  }

  // Fetch sub-categories based on a parent category ID
  Future<List<CategoryModel>> getSubCategories(String categoryId) async {
    try {
      final subCategories = await _categoryRepository.getSubCategories(categoryId);
      return subCategories; // Return empty list if null
    } catch (e) {
      // Show an error message and return an empty list
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  // Fetch products for a specific category
  Future<List<ProductModel>> getCategoryProducts({
    required String categoryId,
    int limit = 4,
  }) async {
    try {
      final products = await ProductRepository.instance
          .getProductsForCategory(categoryId: categoryId, limit: limit);
      return products ?? []; // Return empty list if null
    } catch (e) {
      // Show an error message and return an empty list
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  // Fetch products for a specific sub-category
  Future<List<ProductModel>> getSubCategoryProducts({
    required String categoryId,
    int limit = 4,
  }) async {
    try {
      final products = await ProductRepository.instance
          .getProductsForSubCategory(categoryId: categoryId, limit: limit);
      return products ?? []; // Return empty list if null
    } catch (e) {
      // Show an error message and return an empty list
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }
}
