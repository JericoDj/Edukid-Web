import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/editprofile.dart';
import 'package:webedukid/features/shop/screens/brands/brand_products.dart';
import 'package:webedukid/features/shop/screens/order/all_orders_screen.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'common/widgets/customShapes/containers/search_container.dart';
import 'features/authentication/login/login.dart';
import 'features/bookings/status/processing.dart';
import 'features/bookings/status/scheduled.dart';
import 'features/bookings/status/ongoing.dart';
import 'features/bookings/status/completed.dart';
import 'features/bookings/status/rescheduled.dart';
import 'features/bookings/status/cancelled.dart';
import 'features/screens/gamesscreen/games screen.dart';
import 'features/screens/homescreen/HomeScreen.dart';
import 'features/screens/navigation_controller.dart';
import 'features/screens/personalization/screens/address/address.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/shop/cart/cart.dart';
import 'features/shop/controller/product/product_controller.dart';
import 'features/shop/models/category_model.dart';
import 'features/shop/screens/account_privacy/account_privacy_screen.dart';
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/checkout/checkout.dart';
import 'features/shop/screens/coupons/coupons_screen.dart';
import 'features/shop/screens/order/order.dart';
import 'features/shop/screens/product_detail/product_detail.dart';
import 'features/shop/screens/store/store.dart';
import 'features/shop/screens/bookings/booking_session.dart';
import 'features/shop/screens/all_products/all_products.dart';
import 'features/shop/screens/wishlist/wishlist.dart';
import 'features/screens/profilescreen/widgets/change_name.dart';
import 'features/shop/models/product_model.dart';
import 'features/shop/screens/sub_category/sub_category.dart';
import 'features/shop/controller/category_controller.dart';
import 'package:webedukid/common/data/repositories.authentication/authentication_repository.dart';

// Use a GlobalKey to manage the state of NavigationBarMenu
final GlobalKey<NavigationBarMenuState> navigationBarKey = GlobalKey<NavigationBarMenuState>();

class NavigationBarMenu extends StatefulWidget implements PreferredSizeWidget {
  @override
  NavigationBarMenuState createState() => NavigationBarMenuState();

  @override
  Size get preferredSize => const Size.fromHeight(300);
}

class NavigationBarMenuState extends State<NavigationBarMenu> {
  bool _isDrawerOpen = false;
  bool _isEditProfileDrawerOpen = false;
  bool isInteractive = true; // Control for pointerEvents based on drawer state

  void toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      isInteractive =
      !_isDrawerOpen; // Toggle pointerEvents when drawer is toggled
      if (!_isDrawerOpen) {
        _isEditProfileDrawerOpen = false;
      }
    });
  }

  void toggleEditProfileDrawer() {
    setState(() {
      _isEditProfileDrawerOpen = !_isEditProfileDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => NavigationController());
    final NavigationController navigationController = Get.find();

    // Define screens map once
    final Map<String, Widget Function()> screens = {
      'home': () => HomeScreen(),
      'store': () => StoreScreen(),
      'checkout': () => CheckOutScreen(),
      'bookings': () => BookingsScreen(),
      'brandProducts': () {
        final brand = navigationController.selectedBrand;
        if (brand != null) {
          return BrandProducts(brand: brand);
        } else {
          return Center(child: Text("No brand selected"));
        }
      },
      'subcategories': () {
        final CategoryModel? category = Get.find<CategoryController>().selectedCategory.value;
        if (category == null) {
          return Center(child: Text("No category selected"));
        }
        return SubCategoriesScreen(category: category);
      },
      'processingBookings': () => ProcessingBookingsScreen(),
      'scheduledBookings': () => ScheduledBookingsScreen(),
      'ongoingBookings': () => OngoingBookingsScreen(),
      'completedBookings': () => CompletedBookingsScreen(),
      'rescheduledBookings': () => RescheduledBookingsScreen(),
      'cancelledBookings': () => CancelledBookingsScreen(),
      'order': () => OrderScreen(isInteractive: isInteractive),
      'cart': () => CartScreen(),
      'allOrders': () => AllOrdersScreen(isInteractive: isInteractive),
      'bookingSession': () => BookingSessionScreen(),
      'allProducts': () {
        Get.lazyPut(() => ProductController());
        return AllProductsScreen(
          title: 'Popular Products',
          futureMethod: Get.find<ProductController>().fetchAllFeaturedProducts(),
        );
      },
      'games': () => GamesScreen(),
      'editProfile': () => EditProfileScreen(),
      'userAddress': () => UserAddressScreen(),
      'wishlist': () => WishlistScreen(),
      'coupon': () => CouponScreen(),
      'accountPrivacy': () => AccountPrivacyScreen(),
      'productDetail': () => ProductDetailScreen(product: navigationController.selectedProduct!),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: GestureDetector(
                  onTap: () => navigationController.navigateTo('home'),
                  child: Image.asset('assets/EdukidLogo.jpg', height: 50)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildNavButton('home', Iconsax.home, 'Home'),
                  _buildNavButton('store', Iconsax.shop, 'Store'),
                  _buildNavButton('bookings', Iconsax.task, 'Bookings'),
                  _buildNavButton('order', Iconsax.note, 'Worksheets'),
                  // Worksheets button
                  _buildNavButton('games', Iconsax.game, 'Games'),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: MySearchContainer(text: 'Search for Items'),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.shopping_cart, color: Colors.white),
                  onPressed: () {
                    // Handle navigation to cart with authentication check
                    _handleNavigationWithRestriction('cart', navigationController);
                  },
                ),
                IconButton(
                  icon: const Icon(Iconsax.user, color: Colors.white),
                  onPressed: () {
                    if (AuthenticationRepository.instance.authUser != null) {
                      // If the user is authenticated, open the drawer
                      toggleDrawer();
                    } else {
                      // If not authenticated, redirect to the login screen
                      Future.delayed(Duration.zero, () => Get.to(() => const LoginScreen()));
                    }
                  },
                ),

                const SizedBox(width: 10),
              ],
            ),

          ],
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
            // Ensure screen exists in the map to avoid null errors
            final screenBuilder = screens[navigationController.currentScreen
                .value];
            return screenBuilder != null
                ? screenBuilder()
                : SizedBox.shrink(); // Show loading indicator
          }),
          if (_isDrawerOpen)
            SettingsScreen(
              isOpen: _isDrawerOpen,
              onClose: toggleDrawer,
              onEditProfile: toggleEditProfileDrawer,
              onUserAddress: () =>
                  navigationController.navigateTo('userAddress'),
              onCart: () => navigationController.navigateTo('cart'),
              onOrder: () => navigationController.navigateTo('allOrders'),
              onWishlist: () => navigationController.navigateTo('wishlist'),
              onCoupon: () => navigationController.navigateTo('coupon'),
              onAccountPrivacy: () =>
                  navigationController.navigateTo('accountPrivacy'),
            ),
          if (_isEditProfileDrawerOpen)
            Positioned(
              right: 0,
              top: 80,
              bottom: 0,
              width: 400,
              child: Material(
                borderRadius: BorderRadius.circular(30),
                color: Colors.transparent,
                elevation: 10,
                child: EditProfileScreen(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String screenKey, IconData icon, String label, {ProductModel? product, CategoryModel? category}) {
    final NavigationController navigationController = Get.find();
    return Obx(() {
      return TextButton.icon(
        icon: Icon(
          icon,
          color: navigationController.currentScreen.value == screenKey ? Colors.yellow : Colors.white,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: navigationController.currentScreen.value == screenKey ? Colors.yellow : Colors.white,
          ),
        ),
        onPressed: () {
          if (navigationController.currentScreen.value == screenKey) {
            // If the same screen is clicked, clear the screen first
            navigationController.currentScreen.value = ''; // Clear the current screen
            Future.delayed(Duration(milliseconds: 100), () {
              // Delay before setting it back to the original screen
              navigationController.currentScreen.value = screenKey; // Set it back to the original screen
            });
          } else {
            // Call the function to handle the navigation and restriction logic
            _handleNavigationWithRestriction(screenKey, navigationController, product: product, category: category);
          }
        },
      );
    });
  }



// New function to handle navigation and restriction
  void _handleNavigationWithRestriction(String screenKey,
      NavigationController navigationController,
      {ProductModel? product, CategoryModel? category}) {
    // Allow navigation to 'home' without restrictions
    if (screenKey == 'home' || screenKey == 'store') {
      navigationController.currentScreen.value =
          screenKey; // Set screen to home directly
      return; // Exit the function for home navigation
    }

    // For other screens, handle the authentication and then proceed with navigation if authenticated
    AuthenticationRepository.instance.handleRestrictedContent(() {
      // Now set the screenKey after auth check
      navigationController.currentScreen.value = screenKey;

      // Then proceed with the appropriate action
      if (category != null) {
        navigationController.navigateToSubCategories(category);
      } else if (product != null) {
        navigationController.navigateTo('productDetail', product: product);
      } else {
        _handleBookingScreenNavigation(screenKey);
      }

      return SizedBox.shrink(); // Ensure this returns a widget
    });
  }


}

  void _handleBookingScreenNavigation(String screenKey) {
    final NavigationController navigationController = Get.find();

    if (screenKey == 'order') {
      navigationController.forceReloadScreen(screenKey); // Force reload when clicking on 'order'
    } else {
      navigationController.navigateTo(screenKey);
    }
  }
