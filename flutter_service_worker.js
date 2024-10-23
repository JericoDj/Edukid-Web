'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "9469b444f7479eef1955a8cd678cc337",
"assets/AssetManifest.bin.json": "4dd71c52de6552d4a9d797cb13d337c1",
"assets/AssetManifest.json": "579aa78f154110544aca3832568012f2",
"assets/assets/applepay.json": "09ae7ff903b460a3a12dc9a25daa9804",
"assets/assets/cute-baby-fox-with-number-1-cartoon-illustration-vector.jpg": "8529425218a0c116567b051a908e2056",
"assets/assets/EdukidLogo.jpg": "de26ab5231d04073135ca56cb414f591",
"assets/assets/gpay.json": "a25151036ce2c138c3a8327874dbec83",
"assets/assets/icons/categories/icons8-shoes-64%2520-%2520Copy.png": "7fa3c6c1d2c4f98e96a6b6ad3f48f9f3",
"assets/assets/icons/categories/WakeBoarding.png": "87ba1601ed355b5cc01b63556d4da002",
"assets/assets/icons/categories/WakeBoarding1.png": "975789aade141e25c5aa07008a9d88e1",
"assets/assets/icons/categories/WakeBoardingButton.png": "2a380cea2ba66a618f5112016ffd2159",
"assets/assets/icons/home_slider/slider1test.png": "9516eb40c4089ee08891d2171242fee9",
"assets/assets/icons/home_slider/slider2test.png": "c2a3ad0909ffdeaaf36c1e2dcf1099e4",
"assets/assets/icons/home_slider/slider3test.png": "0002e237142688dd39b186825b5f7d5d",
"assets/assets/icons/store_search/WorksheetIconOnSearch.png": "0a8d43ac92e8929bb62d78c2817f6582",
"assets/assets/images/animations/accountCreated.gif": "4e06794f0be8ddc81e5f2596a0f3514f",
"assets/assets/images/animations/Animation%2520-%25201704947911501.json": "46c3ec6bce0fe8d2336879e6346bef1e",
"assets/assets/images/animations/mailSent.gif": "f695a86bc1cc193c59faa2d87231203f",
"assets/assets/images/animations/Phone%2520Loading.json": "d23a8c509df6680ecb1aed19f2afdf79",
"assets/assets/images/on_boarding_images/Edukid_onboarding.gif": "a99ff6b8dda15e092f58fca6ccd46721",
"assets/assets/images/on_boarding_images/EduKid_onboardingscreen.gif": "3121c85e1d78a55e7497ed77e8c3525a",
"assets/assets/images/on_boarding_images/Edu_kids_screen_1.gif": "ae3e885963eadbde40f1e53c50ca5737",
"assets/assets/images/on_boarding_images/resized.gif": "65627db13e260266a16cbe58c9ad157f",
"assets/assets/images/on_boarding_images/try.gif": "269dec0962e8b6133bc4ef82df7c9c56",
"assets/assets/images/Part%25201/Cover1_-_C1P1.png": "8436744f48233a19a2c69bc159e7ab05",
"assets/assets/images/Part%25201/Cover2_-_C1P1.png": "f581bd478b1ac7cbe4273842bc1e545d",
"assets/assets/images/Part%25201/Cover_page_C1P1.png": "af9a4bd2556ba3d323093312dcf8e1bb",
"assets/assets/images/Part%25201/Primary3_C1_P1_Counting_-_Whole_Numbers_to_10000.pdf": "f5e7a266360e705b91a766f53d9a33bd",
"assets/assets/logos/ApplePay.png": "18fa293f086f9ba77dd75d34d8bb433d",
"assets/assets/logos/fblogoreal.png": "30edcd75710c80abd3274f4887094efd",
"assets/assets/logos/Gcash.png": "12e4ddfd79e1e660b580279d98f8e193",
"assets/assets/logos/googlereal.png": "608ac5cf12305833e037deb7b781a94a",
"assets/assets/logos/High%2520Quality%2520Logo%2520(1).png": "eddba8bed0c67e57e930cff4dfdca53e",
"assets/assets/logos/High%2520Quality%2520Logo%2520(2).png": "5f11828ff2ff8359a9c36103808fb08f",
"assets/assets/logos/MasterCard.png": "2a1417f2347e39968422653375c8682b",
"assets/assets/logos/Paymaya.jpg": "ea3f9a5b2293ba5303a5b6118d67a372",
"assets/assets/logos/Visa.png": "550271b76698a807a0e3403f0a4b60f3",
"assets/FontManifest.json": "4790a7f969c09287c53f7e1bfec88690",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "010c8af6d3b571a8255cc456d0636b72",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "b93248a553f9e8bc17f1065929d5934b",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/iconsax/lib/assets/fonts/iconsax.ttf": "071d77779414a409552e0584dcbfd03d",
"assets/packages/pay_platform_interface/pubspec.yaml": "6022d416cd934235cba30df63422e02b",
"assets/packages/syncfusion_flutter_pdfviewer/assets/fonts/RobotoMono-Regular.ttf": "5b04fdfec4c8c36e8ca574e40b7148bb",
"assets/packages/syncfusion_flutter_pdfviewer/assets/highlight.png": "7384946432b51b56b0990dca1a735169",
"assets/packages/syncfusion_flutter_pdfviewer/assets/squiggly.png": "c9602bfd4aa99590ca66ce212099885f",
"assets/packages/syncfusion_flutter_pdfviewer/assets/strikethrough.png": "cb39da11cd936bd01d1c5a911e429799",
"assets/packages/syncfusion_flutter_pdfviewer/assets/underline.png": "c94a4441e753e4744e2857f0c4359bf0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"flutter_bootstrap.js": "3058ea518ef00c70e447893045b523eb",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "d41d8cd98f00b204e9800998ecf8427e",
"/": "d41d8cd98f00b204e9800998ecf8427e",
"main.dart.js": "bd1df2d7313dee4a2c5c921ef562d433",
"manifest.json": "3b71bdb2149e6710878f386455126cf8",
"payment_page.html": "b2522bb4045666345f96d9e9a8ed7812",
"paypal_payment_page.html": "bf81517c1db7354e6efaf62c1c1254e7",
"save.html": "c11a2a25f53cf1d1ff166e43ee1e9b36",
"version.json": "090133897bb6a4868334089a65da78f4"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
