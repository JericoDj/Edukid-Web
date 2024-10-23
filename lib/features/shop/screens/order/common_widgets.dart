import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/sizes.dart';

// Widget for Single Product Type
Widget buildSingleProductWidget(DocumentSnapshot product, Function(String) onPdfSelected) {
  String pdfUrl = product['PDF'] ?? ''; // PDF location for single products
  String subtitle = product['Subtitle'] ?? ''; // Fetch subtitle if available

  return Container(
    height: 480,
    width: 200,
    color: Colors.amber.withOpacity(0.3),
    child: Card(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              product['Thumbnail'],
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['Title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                const SizedBox(height: 4),

                // View PDF Button
                ElevatedButton(
                  onPressed: () {
                    if (pdfUrl.isNotEmpty) {
                      onPdfSelected(pdfUrl); // Pass PDF URL to callback
                    } else {
                      Get.snackbar('Error', 'PDF not found');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                  ),
                  child: Text('View PDF'),
                ),
                SizedBox(height: MySizes.spaceBtwItems / 2),

                // View in New Tab Button
                ElevatedButton(
                  onPressed: () {
                    if (pdfUrl.isNotEmpty) {
                      openInNewTab(pdfUrl); // Open PDF in new tab
                    } else {
                      Get.snackbar('Error', 'PDF not found');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                  ),
                  child: Text('View in New Tab'),
                ),
                SizedBox(height: MySizes.spaceBtwItems / 2),

                // Download PDF Button
                ElevatedButton(
                  onPressed: () {
                    if (pdfUrl.isNotEmpty) {
                      downloadPdf(pdfUrl, product['Title']); // Download PDF
                    } else {
                      Get.snackbar('Error', 'PDF not found');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                  ),
                  child: Text('Download PDF'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Widget for Variable Product
Widget buildVariableProductWidget(Map<String, dynamic> variation, Function(String) onPdfSelected) {
  String pdfUrl = variation['PDF'] ?? ''; // PDF location for variable products
  String subtitle = variation['Subtitle'] ?? ''; // Fetch subtitle if available

  return Container(
    height: 480,
    width: 200,
    child: Card(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variation['Title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  variation['SubTitle'],
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),

                // View PDF Button
                ElevatedButton(
                  onPressed: () {
                    if (pdfUrl.isNotEmpty) {
                      onPdfSelected(pdfUrl); // Pass PDF URL to callback
                    } else {
                      Get.snackbar('Error', 'PDF not found');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                  ),
                  child: Text('View PDF'),
                ),
                SizedBox(height: MySizes.spaceBtwItems),

                // View in New Tab Button
                ElevatedButton(
                  onPressed: () {
                    if (pdfUrl.isNotEmpty) {
                      openInNewTab(pdfUrl); // Open PDF in new tab
                    } else {
                      Get.snackbar('Error', 'PDF not found');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                  ),
                  child: Text('View in New Tab'),
                ),
                SizedBox(height: MySizes.spaceBtwItems),

                // Download PDF Button
                ElevatedButton(
                  onPressed: () {
                    if (pdfUrl.isNotEmpty) {
                      downloadPdf(pdfUrl, variation['Title']); // Download PDF
                    } else {
                      Get.snackbar('Error', 'PDF not found');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                  ),
                  child: Text('Download PDF'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Function to open PDF in a new tab
void openInNewTab(String pdfUrl) {
  html.window.open(pdfUrl, '_blank'); // Open the URL in a new browser tab
}

// Function to download PDF
void downloadPdf(String pdfUrl, String title) {
  final xhr = html.HttpRequest();
  xhr.responseType = "blob"; // Get the file as a blob
  xhr.open("GET", pdfUrl);
  xhr.onLoad.listen((event) {
    final blob = xhr.response;
    final anchorElement = html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(blob))
      ..setAttribute('download', '$title.pdf') // Dynamic file name
      ..click();
    html.Url.revokeObjectUrl(anchorElement.href!); // Clean up after download
  });
  xhr.send();
}
