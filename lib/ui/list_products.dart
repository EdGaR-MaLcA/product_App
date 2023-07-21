import 'package:flutter/material.dart';
import 'package:product_app/util/db_helper.dart';
import 'package:product_app/models/Product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListProducts extends StatefulWidget {
  const ListProducts({super.key});

  @override
  State<ListProducts> createState() => _ListProductsState();
}

class _ListProductsState extends State<ListProducts> {
  late Future<List<Product>> _productsFuture;
  final dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
     return dbHelper.getAllProducts();
  }

  Future<void> _deleteProduct(int id) async {
    await dbHelper.deleteProduct(id);
    setState(() {
      _productsFuture = _fetchProducts(); // Actualiza el Future para refrescar la vista
    });
  }

  Future<void> _showSummaryDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final totalStock = prefs.getInt('stockSum') ?? 0;
    final totalPrices = (prefs.getInt('priceSum') ?? 0).toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Stock: $totalStock'),
              Text('Total Prices: \$${totalPrices.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: _showSummaryDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final productList = snapshot.data;

            if (productList == null || productList.isEmpty) {
              return const Center(child: Text('No products found'));
            }

            return ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];

                return ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    child: Image.network(
                      product.thumbnail ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    product.title ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    product.description ?? '',
                    textAlign: TextAlign.justify,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Price: \$${product.price ?? ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          _deleteProduct(product.id!);
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}