import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'view_material.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import 'my_materials.dart';
import '../../models/product_model.dart';

class OrderScreen extends StatefulWidget {
  final bool isInteractive;

  const OrderScreen({Key? key, required this.isInteractive}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String selectedGrade = ''; // Grade selected by user
  String? selectedPdfUrl;
  bool showDefaultPage = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            _buildGradeBox(context, 'Grade 1'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 2'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 3'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 4'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 5'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 6'),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: MySizes.spaceBtwItems),
          Expanded(
            child: showDefaultPage
                ? MyMaterialsPage(isInteractive: widget.isInteractive)
                : (selectedPdfUrl != null
                ? ViewMaterial(
              pdfUrl: selectedPdfUrl!,
              onClose: _closePdfView,
              isInteractive: widget.isInteractive,
            )
                : Align(
              alignment: Alignment.topCenter,
              child: _buildOrderList(),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeBox(BuildContext context, String gradeName) {
    final bool isSelected = selectedGrade == gradeName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGrade = gradeName;
          selectedPdfUrl = null;
          showDefaultPage = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: MyColors.primaryColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colors.yellow : MyColors.white,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        child: Center(
          child: Text(
            gradeName,
            style: TextStyle(
              color: isSelected ? Colors.yellow : MyColors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection('Users')
          .doc(_auth.currentUser?.uid)
          .collection('Orders')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No materials found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          );
        }

        final orders = snapshot.data!.docs;

        return Container(
          width: 1000,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var items = List.from(order['items']);

              return FutureBuilder(
                future: _fetchMatchingProducts(items),
                builder: (context, AsyncSnapshot<List<Widget>> productSnapshot) {
                  if (productSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!productSnapshot.hasData ||
                      productSnapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: productSnapshot.data!,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<List<Widget>> _fetchMatchingProducts(List<dynamic> items) async {
    List<Widget> matchingWidgets = [];

    for (var item in items) {
      var title = item['title'];

      var productQuery = await _firestore
          .collection('Products')
          .where('Title', isEqualTo: title)
          .where('Level', isEqualTo: selectedGrade)
          .get();

      for (var product in productQuery.docs) {
        var productType = product['ProductType'];

        if (productType == 'ProductType.single') {
          matchingWidgets.add(_buildSingleProductWidget(
              product as DocumentSnapshot<Map<String, dynamic>>)); // Casting here
        } else if (productType == 'ProductType.variable') {
          var matchedVariation =
          await _fetchMatchingVariation(item['selectedVariation'], product);
          if (matchedVariation != null) {
            matchingWidgets
                .add(_buildVariableProductWidget(matchedVariation));
          }
        }
      }
    }
    return matchingWidgets;
  }

  /// Widget for Single Product Type
  Widget _buildSingleProductWidget(
      DocumentSnapshot<Map<String, dynamic>> product) {
    String pdfUrl = product['PDF'] ?? ''; // PDF location for single products

    return GestureDetector(
      onTap: () {
        // The GestureDetector now follows the first button's functionality
        if (pdfUrl.isNotEmpty) {
          setState(() {
            selectedPdfUrl = pdfUrl;
          });
        } else {
          Get.snackbar('Error', 'PDF not found');
        }
      }, // Gesture opens the PDF within the app
      child: Container(
        width: 280,
        height: 360,
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          elevation: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                child: Image.network(
                  product['Thumbnail'],
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      product['Title'],
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: MySizes.spaceBtwItems/2),
                    ElevatedButton(
                      onPressed: () {
                        if (pdfUrl.isNotEmpty) {
                          setState(() {
                            selectedPdfUrl = pdfUrl;
                          });
                        } else {
                          Get.snackbar('Error', 'PDF not found');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('View PDF'),
                    ),
                    SizedBox(height: MySizes.spaceBtwItems / 2),
                    ElevatedButton(
                      onPressed: () {
                        if (pdfUrl.isNotEmpty) {
                          _openInNewTab(pdfUrl);
                        } else {
                          Get.snackbar('Error', 'PDF not found');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: Text('View in New Tab'),
                    ),
                    SizedBox(height: MySizes.spaceBtwItems/2),
                    ElevatedButton(
                      onPressed: () {
                        if (pdfUrl.isNotEmpty) {
                          _downloadPdf(pdfUrl, product['Title']);
                        } else {
                          Get.snackbar('Error', 'PDF not found');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Download PDF'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariableProductWidget(Map<String, dynamic> variation) {
    String pdfUrl = variation['PDF'] ?? '';

    return GestureDetector(
      onTap: () {
        if (pdfUrl.isNotEmpty) {
          setState(() {
            selectedPdfUrl = pdfUrl;
          });
        } else {
          Get.snackbar('Error', 'PDF not found');
        }
      }, // Gesture opens the PDF within the app
      child: Container(
        height: 360,
        width: 280,
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          elevation: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                child: Image.network(
                  variation['Image'],
                  fit: BoxFit.scaleDown,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      variation['Title'],
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      variation['SubTitle'],
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: MySizes.spaceBtwItems/2),
                    ElevatedButton(
                      onPressed: () {
                        if (pdfUrl.isNotEmpty) {
                          setState(() {
                            selectedPdfUrl = pdfUrl;
                          });
                        } else {
                          Get.snackbar('Error', 'PDF not found');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('View PDF'),
                    ),
                    SizedBox(height: MySizes.spaceBtwItems/2),
                    ElevatedButton(
                      onPressed: () {
                        if (pdfUrl.isNotEmpty) {
                          _openInNewTab(pdfUrl);
                        } else {
                          Get.snackbar('Error', 'PDF not found');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: Text('View in New Tab'),
                    ),
                    SizedBox(height: MySizes.spaceBtwItems/2),
                    ElevatedButton(
                      onPressed: () {
                        if (pdfUrl.isNotEmpty) {
                          _downloadPdf(pdfUrl, variation['Title']);
                        } else {
                          Get.snackbar('Error', 'PDF not found');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Download PDF'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openInNewTab(String pdfUrl) {
    html.window.open(pdfUrl, '_blank');
  }

  void _downloadPdf(String pdfUrl, String title) {
    final xhr = html.HttpRequest();
    xhr.responseType = "blob";
    xhr.open("GET", pdfUrl);
    xhr.onLoad.listen((event) {
      final blob = xhr.response;
      final anchorElement = html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(blob),
      )
        ..setAttribute('download', '$title.pdf')
        ..click();
      html.Url.revokeObjectUrl(anchorElement.href!);
    });
    xhr.send();
  }

  Future<Map<String, dynamic>?> _fetchMatchingVariation(
      Map selectedVariation, DocumentSnapshot<Map<String, dynamic>> product) async {
    var chapter = selectedVariation['Chapter'];
    var part = selectedVariation['Part'];

    var variations =
    List<Map<String, dynamic>>.from(product['ProductVariations']);
    for (var variation in variations) {
      var attributes = variation['AttributeValues'];
      if (attributes['Chapter'] == chapter && attributes['Part'] == part) {
        return variation;
      }
    }
    return null;
  }

  void _closePdfView() {
    setState(() {
      selectedPdfUrl = null;
    });
  }
}
