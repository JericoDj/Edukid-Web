import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:webedukid/utils/constants/sizes.dart';
import 'view_material.dart';

class MyMaterialsPage extends StatefulWidget {
  final bool isInteractive;

  MyMaterialsPage({required this.isInteractive});

  @override
  _MyMaterialsPageState createState() => _MyMaterialsPageState();
}

class _MyMaterialsPageState extends State<MyMaterialsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedPdfUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedPdfUrl != null
          ? ViewMaterial(
        pdfUrl: selectedPdfUrl!,
        onClose: _closePdfView,
        isInteractive: widget.isInteractive,
      )
          : FutureBuilder<QuerySnapshot>(
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
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 1000,
              child: GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
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
                    builder: (context,
                        AsyncSnapshot<List<Widget>> productSnapshot) {
                      if (productSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!productSnapshot.hasData ||
                          productSnapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: productSnapshot.data!,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<Widget>> _fetchMatchingProducts(List<dynamic> items) async {
    List<Widget> matchingWidgets = [];

    for (var item in items) {
      var title = item['title'];

      var productQuery = await _firestore
          .collection('Products')
          .where('Title', isEqualTo: title)
          .get();

      for (var product in productQuery.docs) {
        var productLevel = product['Level'];
        var productType = product['ProductType'];

        if (productType == 'ProductType.single') {
          matchingWidgets.add(_buildSingleProductWidget(product));
        } else if (productType == 'ProductType.variable') {
          var matchedVariation =
          await _fetchMatchingVariation(item['selectedVariation'], product);
          if (matchedVariation != null) {
            matchingWidgets.add(_buildVariableProductWidget(matchedVariation));
          }
        }
      }
    }
    return matchingWidgets;
  }

  // Widget for Single Product Type
  Widget _buildSingleProductWidget(DocumentSnapshot product) {
    String pdfUrl = product['PDF'] ?? ''; // PDF location for single products

    return GestureDetector(
      onTap: () {
        if (pdfUrl.isNotEmpty) {
          setState(() {
            selectedPdfUrl = pdfUrl; // Set PDF to show
          });
        } else {
          Get.snackbar('Error', 'PDF not found');
        }
      },
      child: Container(
        height: 360,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: Card(
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Image.network(
                  height: 180,
                  product['Thumbnail'],
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    product['Title'],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),

                  // View PDF Button
                  ElevatedButton(
                    onPressed: () {
                      if (pdfUrl.isNotEmpty) {
                        setState(() {
                          selectedPdfUrl = pdfUrl; // Set PDF to show
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

                  // View in New Tab Button
                  ElevatedButton(
                    onPressed: () {
                      if (pdfUrl.isNotEmpty) {
                        _openInNewTab(pdfUrl); // Open PDF in new tab
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
                  SizedBox(height: MySizes.spaceBtwItems / 2),

                  // Download PDF Button
                  ElevatedButton(
                    onPressed: () {
                      if (pdfUrl.isNotEmpty) {
                        _downloadPdf(pdfUrl, product['Title']); // Download PDF
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
                  SizedBox(height: MySizes.spaceBtwItems / 2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget for Variable Product
  Widget _buildVariableProductWidget(Map<String, dynamic> variation) {
    String pdfUrl = variation['PDF'] ?? ''; // PDF location for variable products

    return GestureDetector(
      onTap: () {
        if (pdfUrl.isNotEmpty) {
          setState(() {
            selectedPdfUrl = pdfUrl; // Set PDF to show
          });
        } else {
          Get.snackbar('Error', 'PDF not found');
        }
      },
      child: Container(
        height: 430,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: Card(
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    variation['Image'],
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: 200,
                    alignment: Alignment.center,
                  ),
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
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      variation['SubTitle'],
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),

                    // View PDF Button
                    ElevatedButton(
                      onPressed: () {
                        if (pdfUrl.isNotEmpty) {
                          setState(() {
                            selectedPdfUrl = pdfUrl; // Set PDF to show
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

                    // View in New Tab Button
                    ElevatedButton(
                      onPressed: () {
                        if (pdfUrl.isNotEmpty) {
                          _openInNewTab(pdfUrl); // Open PDF in new tab
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
                    SizedBox(height: MySizes.spaceBtwItems / 2),

                    // Download PDF Button
                    ElevatedButton(
                      onPressed: () {
                        if (pdfUrl.isNotEmpty) {
                          _downloadPdf(pdfUrl, variation['Title']); // Download PDF
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

  // Close PDF View
  void _closePdfView() {
    setState(() {
      selectedPdfUrl = null;
    });
  }

  /// Function to open PDF in a new tab
  void _openInNewTab(String pdfUrl) {
    html.window.open(pdfUrl, '_blank'); // Open the URL in a new browser tab
  }

  /// Function to download PDF using XHR (for web)
  void _downloadPdf(String pdfUrl, String title, [String? subtitle]) {
    String fileName = subtitle != null && subtitle.isNotEmpty
        ? '$title-$subtitle.pdf'
        : '$title.pdf';

    final xhr = html.HttpRequest();
    xhr.responseType = "blob"; // Get the file as a blob
    xhr.open("GET", pdfUrl);
    xhr.onLoad.listen((event) {
      final blob = xhr.response;
      final anchorElement =
      html.AnchorElement(href: html.Url.createObjectUrlFromBlob(blob))
        ..setAttribute('download', fileName) // Use the dynamic file name
        ..click();
      html.Url.revokeObjectUrl(anchorElement.href!); // Clean up after download
    });
    xhr.send();
  }

  /// Widget for Variable Product Type
  Future<Map<String, dynamic>?> _fetchMatchingVariation(
      Map selectedVariation, DocumentSnapshot product) async {
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
}
