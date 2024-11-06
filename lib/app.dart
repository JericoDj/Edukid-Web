import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:webedukid/utils/constants/image_strings.dart';
import 'common/success_screen/sucess_screen.dart';
import 'drawer_controller.dart';
import 'features/authentication/login/login.dart';
import 'features/authentication/password_configuration/forget_password.dart';
import 'features/screens/gamesscreen/games screen.dart';
import 'features/screens/navigation_controller.dart';
import 'features/screens/personalization/screens/address/address.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/screens/profilescreen/widgets/editprofile.dart';
import 'features/screens/signup/widgets/signup.dart';
import 'features/shop/cart/cart.dart';
import 'features/shop/controller/product/product_controller.dart';
import 'features/shop/models/brand_model.dart';
import 'features/shop/models/product_model.dart';
import 'features/shop/screens/account_privacy/account_privacy_screen.dart';
import 'features/shop/screens/all_products/all_products.dart';
import 'features/shop/screens/booking_checkout/booking_checkout.dart';
import 'features/shop/screens/bookings/booking_session.dart';
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/brands/brand_products.dart';
import 'features/shop/screens/coupons/coupons_screen.dart';
import 'features/shop/screens/order/all_orders_screen.dart';
import 'features/shop/screens/order/order.dart';
import 'features/shop/screens/product_detail/product_detail.dart';
import 'features/shop/screens/store/store.dart';
import 'features/shop/screens/wishlist/wishlist.dart';
import 'navigation_Bar.dart';
import 'features/screens/homescreen/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  final MyDrawerController drawerController = Get.put(MyDrawerController());

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(()=>NavigationController());
    final GoRouter router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              appBar: NavigationBarMenu(),
              endDrawerEnableOpenDragGesture: true,
              endDrawer: Obx(() => Container(
                width: 400,
                margin: EdgeInsets.only(top: kToolbarHeight),
                child: Drawer(
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Settings screen content
                      Positioned.fill(
                        child: SettingsScreen(
                          isOpen: drawerController.isDrawerOpen.value,
                          onClose: drawerController.closeDrawer,
                          onEditProfile: drawerController.toggleEditProfileDrawer,
                          onUserAddress: () => context.go('/userAddress'),
                          onCart: () => context.go('/cart'),
                          onOrder: () => context.go('/allOrders'),
                          onWishlist: () => context.go('/wishlist'),
                          onCoupon: () => context.go('/coupon'),
                          onAccountPrivacy: () => context.go('/accountPrivacy'),
                        ),
                      ),
                      // Overlaying EditProfileScreen
                      if (drawerController.isEditProfileDrawerOpen.value)
                        Positioned(
                          right: 0,
                          top: 80,
                          bottom: 0,
                          child: Material(
                            elevation: 16,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: 400,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: EditProfileScreen(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
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
            GoRoute(path: '/allOrders', builder: (context, state) => AllOrdersScreen(isInteractive: true)),
            GoRoute(path: '/wishlist', builder: (context, state) => WishlistScreen()),
            GoRoute(path: '/coupon', builder: (context, state) => CouponScreen()),
            GoRoute(path: '/accountPrivacy', builder: (context, state) => AccountPrivacyScreen()),
            GoRoute(path: '/bookSession', builder: (context, state) => BookingSessionScreen()),
            GoRoute(
              path: '/brandProducts/:brandId/:brandName',
              builder: (context, state) {
                final brand = state.extra as BrandModel? ?? BrandModel.empty();
                return BrandProducts(brand: brand, brandId: '', brandName: '',);
              },
            ),
            GoRoute(
              path: '/productDetail/:productId/:productName',
              builder: (context, state) {
                final product = state.extra as ProductModel;
                return ProductDetailScreen(product: product);
              },
            ),
            GoRoute(
              path: '/bookingCheckout',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final pickedDates = (extra?['pickedDates'] as List).map((date) => date as DateTime).toList();
                final pickedTimes = (extra?['pickedTimes'] as List).map((time) => time as TimeOfDay).toList();
                final price = extra?['price'] as double? ?? 0.0;

                return BookingCheckOutScreen(
                  pickedDates: pickedDates,
                  pickedTimes: pickedTimes,
                  price: price,
                );
              },
            ),
            GoRoute(
              path: '/success',
              builder: (context, state) => SuccessScreen(
                image: MyImages.accountGIF,
                title: 'Booking Successful!',
                subtitle: 'Your booking has been confirmed!',
                onPressed: () => context.go('/home'),
              ),
            ),
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
