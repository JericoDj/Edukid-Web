
import 'package:get/get.dart';

import '../../../common/data/repositories.authentication/banners/banners_repository.dart';
import '../../../common/widgets/loaders/loaders.dart';
import '../../models/banner_model.dart';

class BannerController extends GetxController {
  static BannerController get instance => Get.find();

  /// Variables
  final carousalCurrentIndex = 0.obs;

  final isLoading = false.obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;

  @override
  void onInit() {
    fetchBanners();
    super.onInit();
  }

  /// Update Page Navigational Data
  void updatePageIndicator(index) {
    carousalCurrentIndex.value = index;
  }

  /// Fetch Banners
  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;

      // Fetch Banners
      final bannerRepo = Get.put(BannerRepository());
      print("Before fetching banners");
      final banners = await bannerRepo.fetchBanners();
      print("After fetching banners");

      // Print Document Names (using 'imageUrl' as an example)
      print("Document Names:");
      banners.forEach((banner) {
        print(banner.imageUrl);
      });

      // Assign Banners
      this.banners.assignAll(banners);
    } catch (e) {
      print("Error fetching banners: $e");
      MyLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

}
