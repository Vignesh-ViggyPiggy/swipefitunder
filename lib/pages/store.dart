import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  int _selectedcloth = -1;
  final images = [
    'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F00962381807-e0.jpg?alt=media&token=8c1392ec-9fc8-485b-840f-2d030a6aa821',
    'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F01887450800-e1.jpg?alt=media&token=9065579a-1d09-49fa-868d-6c62776624cd',
    'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04090335807-e2.jpg?alt=media&token=8dd51ff3-528f-4c0a-a887-db78c8ad2f28',
    'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04393350800-e3.jpg?alt=media&token=10c99a3c-6154-49c5-ba0e-e19b3367baae',
    'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F04805305251-e4.jpg?alt=media&token=cca33518-f5b0-424f-ac7c-475348902f28',
    'https://firebasestorage.googleapis.com/v0/b/ratefit-bed29.appspot.com/o/Cloths%2F05679250401-e5.jpg?alt=media&token=b90c0efd-4c03-4003-8c9a-cc1fa3b67e08',
  ];

  final List<String> image_link = [
    'https://www.google.com/maps',
    'https://www.zara.com/in/en/basic-heavy-weight-t-shirt-p01887450.html?v1=364113271',
    'https://www.zara.com/in/en/printed-knit-t-shirt-p04090335.html?v1=390672229',
    'https://www.zara.com/in/en/hoodie-p00761330.html?v1=381137893',
    'https://www.zara.com/in/en/spray-print-knit-t-shirt-p04805305.html?v1=365910331',
    'https://www.zara.com/in/en/abstract-print-shirt-p05679250.html?v1=372994197'
  ];

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("SWIPE FIT"),
      ),
      body: SingleChildScrollView(
        child: Container(
            height: size.height,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedcloth = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 10, 10, 10),
                        border: Border.all(
                            color: _selectedcloth == index
                                ? Colors.cyan
                                : Colors.black),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          images[index],
                          width: size.width,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )),
      ),
      floatingActionButton: _selectedcloth != -1
          ? FloatingActionButton(
              onPressed: () {
                _launchUrl(image_link[_selectedcloth]);
              },
              backgroundColor: Colors.cyan,
              child: const Text(
                "BUY",
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}
