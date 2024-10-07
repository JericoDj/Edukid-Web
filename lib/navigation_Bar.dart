import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/editprofile.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'common/widgets/customShapes/containers/search_container.dart';
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

  void toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
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

    final Map<String, Widget Function()> screens = {
      'home': () => HomeScreen(),
      'store': () => StoreScreen(),
      'checkout': () => CheckOutScreen(), // Add Checkout Screen to screen map
      'bookings': () => BookingsScreen(), // Main bookings screen
      'processingBookings': () => ProcessingBookingsScreen(),
      'scheduledBookings': () => ScheduledBookingsScreen(),
      'ongoingBookings': () => OngoingBookingsScreen(),
      'completedBookings': () => CompletedBookingsScreen(),
      'rescheduledBookings': () => RescheduledBookingsScreen(),
      'cancelledBookings': () => CancelledBookingsScreen(),

      'order': () => OrderScreen(),
      'cart': () => CartScreen(),
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
      'productDetail': () => ProductDetailScreen(product: navigationController.selectedProduct!), // Use the selected product
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
              child: Image.asset('assets/EdukidLogo.jpg', height: 50),
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
                  onPressed: () => navigationController.navigateTo('cart'),
                ),
                IconButton(
                  icon: const Icon(Iconsax.user, color: Colors.white),
                  onPressed: toggleDrawer,
                ),
                const SizedBox(width: 10)
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Obx(() => screens[navigationController.currentScreen.value]!()),
          if (_isDrawerOpen)
            SettingsScreen(
              isOpen: _isDrawerOpen,
              onClose: toggleDrawer,
              onEditProfile: toggleEditProfileDrawer,
              onUserAddress: () => navigationController.navigateTo('userAddress'),
              onCart: () => navigationController.navigateTo('cart'),
              onOrder: () => navigationController.navigateTo('order'),
              onWishlist: () => navigationController.navigateTo('wishlist'),
              onCoupon: () => navigationController.navigateTo('coupon'),
              onAccountPrivacy: () => navigationController.navigateTo('accountPrivacy'),
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

  Widget _buildNavButton(String screenKey, IconData icon, String label, {ProductModel? product}) {
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
          if (product != null) {
            navigationController.navigateTo('productDetail', product: product);
          } else {
            _handleBookingScreenNavigation(screenKey);
          }
        },
      );
    });
  }

  void _handleBookingScreenNavigation(String screenKey) {
    final NavigationController navigationController = Get.find();

    switch (screenKey) {
      case 'home':
        navigationController.currentScreen.value = 'home';
        break;
      case 'store':
        navigationController.currentScreen.value = 'store';
        break;
      case 'order':
        navigationController.currentScreen.value = 'order';
        break;
      case 'games':
        navigationController.currentScreen.value = 'games';
        break;
      case 'bookings':
        navigationController.currentScreen.value = 'bookings';
        break;
      default:
        navigationController.currentScreen.value = 'home'; // Or any default screen
        break;
    }
  }
}
