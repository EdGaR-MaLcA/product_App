import 'package:flutter/material.dart';
import 'package:product_app/util/http_helper.dart';
import 'package:product_app/util/db_helper.dart';
import 'package:product_app/models/Product.dart';
import 'package:product_app/ui/list_products.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductView(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/listProducts': (context) => ListProducts(),
      },
    );
  }
}

class ProductView extends StatefulWidget {
  const ProductView({Key? key});

  @override
  State<ProductView> createState() => _ProductViewState();
}
//funcion para obtener los productos gracias al API
class _ProductViewState extends State<ProductView> {
  Future<dynamic> _fetchProducts() async {
    try {
      final response = await ApiHelper.get('/products');
      final productList = response['products'] as List<dynamic>;
      return productList;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
  //funcion para grabar el prodcto a mi database
  void _saveProduct(Product product) async {
    final dbHelper = DbHelper();
    await dbHelper.addProduct(product);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product saved to database')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product View'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_basket),
            onPressed: () {
              Navigator.pushNamed(context, '/listProducts');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final productList = snapshot.data as List<dynamic>;

            return ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Card(
                    elevation: 2.0,
                    color: Colors.lightBlue.withOpacity(0.25),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        child: Image.network(
                          product['thumbnail'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        product['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['description'],
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Stock: ${product['stock']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Price: \$${product['price']}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              final selectedProduct = Product(
                                id: product['id'],
                                title: product['title'],
                                description: product['description'],
                                price: product['price'],
                                stock: product['stock'],
                                thumbnail: product['thumbnail'],
                              );
                              _saveProduct(selectedProduct);
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.indigo,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
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