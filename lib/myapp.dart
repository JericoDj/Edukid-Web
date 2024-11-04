import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:webedukid/utils/constants/image_strings.dart';
import 'package:webedukid/utils/network%20manager/network_manager.dart';

import 'common/data/repositories.authentication/product/product_repository.dart';
import 'common/success_screen/sucess_screen.dart';
import 'common/widgets/appbar/tabbar.dart';
import 'drawer_controller.dart';
import 'features/authentication/login/login.dart';
import 'features/authentication/password_configuration/forget_password.dart';
import 'features/screens/gamesscreen/games screen.dart';
import 'features/screens/homescreen/HomeScreen.dart';
import 'features/screens/navigation_controller.dart';
import 'features/screens/personalization/controllers/address_controller.dart';
import 'features/screens/personalization/screens/address/add_new_address.dart';
import 'features/screens/personalization/screens/address/address.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/screens/profilescreen/widgets/editprofile.dart';
import 'features/screens/signup/widgets/signup.dart';
import 'features/shop/cart/cart.dart';
import 'features/shop/controller/brand_controller.dart';
import 'features/shop/controller/category_controller.dart';
import 'features/shop/controller/product/cart_controller.dart';
import 'features/shop/controller/product/checkout_controller.dart';
import 'features/shop/controller/product/product_controller.dart';
import 'features/shop/controller/product/variation_controller.dart';
import 'features/shop/models/brand_model.dart';
import 'features/shop/models/category_model.dart';
import 'features/shop/models/product_model.dart';
import 'features/shop/screens/account_privacy/account_privacy_screen.dart';
import 'features/shop/screens/all_products/all_products.dart';
import 'features/shop/screens/booking_checkout/booking_checkout.dart';
import 'features/shop/screens/bookings/booking_session.dart';
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/brands/brand_products.dart';
import 'features/shop/screens/checkout/checkout.dart';
import 'features/shop/screens/coupons/coupons_screen.dart';
import 'features/shop/screens/order/all_orders_screen.dart';
import 'features/shop/screens/order/order.dart';
import 'features/shop/screens/product_detail/product_detail.dart';
import 'features/shop/screens/store/store.dart';
import 'features/shop/screens/sub_category/sub_category.dart';
import 'features/shop/screens/wishlist/wishlist.dart';
import 'navigation_Bar.dart';

final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(key: appKey));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDrawerOpen = false;
  bool _isEditProfileDrawerOpen = false;

  final brandController = Get.put(BrandController());
  final drawerController = Get.put(MyDrawerController());


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
    // Initialize other controllers if necessary
    Get.lazyPut(() => NetworkManager());
    Get.lazyPut(() => AddressController());
    Get.lazyPut(() => CheckoutController());
    Get.lazyPut(() => VariationController());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => CategoryController());
    Get.lazyPut(() => NavigationController());

    final GoRouter router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              appBar: NavigationBarMenu(),
              endDrawerEnableOpenDragGesture: true,
              endDrawer: Container(
                margin: EdgeInsets.only(top: kToolbarHeight),
                child: Obx(
                      () => Drawer(
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SettingsScreen(
                            isOpen: drawerController.isDrawerOpen.value,
                            onClose: () => drawerController.closeDrawer(),
                            onEditProfile: toggleEditProfileDrawer, // Toggles the edit profile drawer
                            onUserAddress: () => context.go('/userAddress'),
                            onCart: () => context.go('/cart'),
                            onOrder: () => context.go('/allOrders'),
                            onWishlist: () => context.go('/wishlist'),
                            onCoupon: () => context.go('/coupon'),
                            onAccountPrivacy: () => context.go('/accountPrivacy'),
                          ),
                        ),
                        if (_isEditProfileDrawerOpen)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),

                            right: 0,
                            top: 100,
                            bottom: 0,
                            width: 400,
                            child: Material(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              elevation: 10,
                              child: EditProfileScreen(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              body: child,
            );
          },
          routes: [
            GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
            GoRoute(path: '/store', builder: (context, state) => const StoreScreen()),
            GoRoute(path: '/bookings', builder: (context, state) => const BookingsScreen()),
            GoRoute(path: '/order', builder: (context, state) => OrderScreen(isInteractive: true)),
            GoRoute(path: '/games', builder: (context, state) => const GamesScreen()),
            GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
            GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
            GoRoute(path: '/register', builder: (context, state) => SignUpScreen()),
            GoRoute(path: '/forgotPassword', builder: (context, state) => ForgetPasswordScreen()),
            GoRoute(path: '/userAddress', builder: (context, state) => UserAddressScreen()),
            GoRoute(
              path: '/allProducts',
              builder: (context, state) {
                final productController = Get.find<ProductController>();
                return AllProductsScreen(
                  title: 'Popular Products',
                  futureMethod: productController.fetchAllFeaturedProducts(),
                );
              },
            ),
            // Add remaining routes here
          ],
        ),
      ],
    );

    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
