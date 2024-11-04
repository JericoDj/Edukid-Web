import 'package:get/get.dart';
import '../../../common/data/repositories.authentication/brands/brand_repository.dart';
import '../../../common/data/repositories.authentication/product/product_repository.dart';
import '../../../common/widgets/loaders/loaders.dart';
import '../models/brand_model.dart';
import '../models/product_model.dart';

class BrandController extends GetxController {
  static BrandController get instance => Get.find();

  RxBool isLoading = true.obs;
  final RxList<BrandModel> featuredBrands = <BrandModel>[].obs;
  final RxList<BrandModel> allBrands = <BrandModel>[].obs;

  final brandRepository = Get.put(BrandRepository());
  final productRepository = Get.put(ProductRepository());

  // Caching maps to store loaded brands and products by brandId
  final _brandCache = <String, BrandModel>{}.obs;
  final _productsCache = <String, List<ProductModel>>{}.obs;

  @override
  void onInit() {
    getFeaturedBrands();
    super.onInit();
  }

  /// Fetch brand details by ID with caching
  Future<BrandModel> getBrandById(String brandId) async {
    // Check if the brand is already in the cache
    if (_brandCache.containsKey(brandId)) {
      print("Fetching brand $brandId from cache.");
      return _brandCache[brandId]!;
    }

    try {
      print("Fetching brand $brandId from repository.");
      final brand = await brandRepository.getBrandById(brandId);
      _brandCache[brandId] = brand; // Cache the result
      return brand;
    } catch (e) {
      print("Error fetching brand details: $e");
      throw Exception("Error fetching brand details");
    }
  }

  /// Fetch products for a specific brand with caching
  Future<List<ProductModel>> getBrandProducts({required String brandId, int? limit}) async {
    // Check if products for the brand are already in the cache
    if (_productsCache.containsKey(brandId)) {
      print("Fetching products for brand $brandId from cache.");
      return _productsCache[brandId]!;
    }

    try {
      print("Fetching products for brand $brandId from repository.");
      final products = await brandRepository.getProductsForBrand(brandId: brandId, limit: limit ?? -1);
      _productsCache[brandId] = products; // Cache the result
      return products;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  /// Get Featured Brands
  Future<void> getFeaturedBrands() async {
    try {
      isLoading.value = true;
      final brands = await brandRepository.getAllBrands();
      allBrands.assignAll(brands);
      featuredBrands.assignAll(
        allBrands.where((brand) => brand.isFeatured ?? false).take(4),
      );
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Get Brands For Category with caching
  Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
    try {
      final brands = await brandRepository.getBrandsForCategory(categoryId);
      return brands;
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Clear specific brand cache (useful if data may change)
  void clearBrandCache(String brandId) {
    _brandCache.remove(brandId);
    _productsCache.remove(brandId);
  }

  /// Clear all caches (e.g., on logout or major data refresh)
  void clearAllCaches() {
    _brandCache.clear();
    _productsCache.clear();
  }
}
