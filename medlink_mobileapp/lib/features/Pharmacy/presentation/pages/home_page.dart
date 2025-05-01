import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    email = args?['email'] as String? ?? 'No email provided';
  }

  // Sample product data
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Calcium',
      'description': '500 mg',
      'price': '800 Birr',
      'image': 'assets/images/calcium.png',
      'inStock': true,
    },
    {
      'name': 'Cold & Flu',
      'description': '150 ml',
      'price': '550 Birr',
      'image': 'assets/images/cold.png',
      'inStock': true,
    },
    {
      'name': 'Sunscreen',
      'description': '200 ml',
      'price': '2000 Birr',
      'image': 'assets/images/sunscreen.png',
      'inStock': false,
    },
    {
      'name': 'Calcium',
      'description': '',
      'price': '800 Birr',
      'image': 'assets/images/calcium.png',
      'inStock': true,
    },
  ];

  // Sample categories
  final List<String> categories = [
    'Painkillers',
    'Antibiotics',
    'Cough & Cold',
    'Vitamins',
    'Diabetes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF2b8761)),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF2b8761)),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF2b8761),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF2b8761),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'HY',
                        style: TextStyle(
                          color: Color(0xFF2b8761),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Helen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'helen@gmail.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Home
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text(
                'Home',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text(
                'Recent Orders',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.white),
              title: const Text(
                'Addresses',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.white),
              title: const Text(
                'Notifications',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.gps_fixed, color: Colors.white),
              title: const Text(
                'Location',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search medicine, Beauty care...',
                  hintStyle: const TextStyle(color: Colors.white),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF94c2af),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF94c2af), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Recommended For You',
                    style: TextStyle(color: Color(0xFF2b8761)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2b8761),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'SEE ALL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2b8761),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF94c2aF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(category),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF5),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              image: DecorationImage(
                                image: AssetImage(product['image']),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (product['description'].isNotEmpty)
                                  Text(
                                    product['description'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  product['price'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (!product['inStock'])
                                      const Text(
                                        'Out of Stock',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                       
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
