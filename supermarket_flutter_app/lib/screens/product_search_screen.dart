
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/product.dart';
import '../../core/models/category.dart';
import '../../core/providers/cart_provider.dart';
import '../../features/products/providers/product_provider.dart';
import '../../features/products/providers/category_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cart/cart_page.dart';  // Import CartPage
import 'barcode_scanner_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize provider data if needed
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _searchController.text = args;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // Ensure we have the full catalog loaded
       final provider = context.read<ProductProvider>();
       if (provider.products.isEmpty) {
         provider.loadProducts();
       }
       // Ensure categories are loaded for POS filtering
       final catProvider = context.read<CategoryProvider>();
       if (catProvider.categories.isEmpty) {
         catProvider.fetchCategories();
       }
    });
  }

  void _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    if (result != null) {
      _searchController.text = result; // Just set text, the UI filters automatically via Provider
      setState(() {});
    }
  }

  Future<void> _addToCart(Product product) async {
    // ... same implementation ...
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Out of Stock — cannot add to cart')));
      return;
    }
    final cart = context.read<CartProvider>();
    try {
      await cart.addItem(CartItem(productId: product.id!, name: product.name, unitPrice: product.price));
      // Removed "Added to cart" SnackBar as user requested no popping messages.
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not add to cart: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    
    var allProducts = productProvider.products;
    
    // "Bar" User Customization and Restriction
    final barCategory = categoryProvider.categories.firstWhere(
        (c) => c.name.toLowerCase() == 'bar',
        orElse: () => Category(id: -1, name: 'None')
    );
    
    if (authProvider.username?.toLowerCase() == 'bar') {
        // Bar User: ONLY sees Bar items
        if (barCategory.id != -1) {
            allProducts = allProducts.where((p) => p.categoryId == barCategory.id).toList();
        } else {
             allProducts = []; 
        }
    } else {
        // Other Users: See EVERYTHING EXCEPT Bar items
        if (barCategory.id != -1) {
             allProducts = allProducts.where((p) => p.categoryId != barCategory.id).toList();
        }
    }
    
    // Filter locally based on search text
    final query = _searchController.text.toLowerCase();
    final displayedProducts = allProducts.where((p) {
      final matchesName = p.name.toLowerCase().contains(query);
      final matchesBarcode = p.barcode?.toLowerCase().contains(query) ?? false;
      return matchesName || matchesBarcode;
    }).where((p) => p.stock > 0).toList(); // Only show in-stock for POS

    // Custom App Bar Title
    final title = (authProvider.username?.toLowerCase() == 'bar') ? 'Top Bar' : 'Product Search';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) return const SizedBox.shrink();
          return Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cart.items.length} Items',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        'Total: LKR ${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('Active Cart / Checkout')),
                            body: const CartPage(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('View Cart & Checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(labelText: 'Search by name or barcode'),
                    onChanged: (v) => setState(() {}), // Trigger rebuild to filter
                  ),
                ),
                IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode),
              ],
            ),
          ),
          if (productProvider.isLoading) const LinearProgressIndicator(),
          Expanded(
            child: displayedProducts.isEmpty 
              ? Center(child: Text(query.isEmpty ? 'No products available' : 'No matches found'))
              : ListView.builder(
              itemCount: displayedProducts.length,
              itemBuilder: (context, index) {
                final product = displayedProducts[index];
                return ListTile(
                  leading: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.image),
                  title: Text(product.name),
                  subtitle: Text('Price: LKR ${product.price} | Stock: ${product.stock}'),
                  trailing: ElevatedButton(
                    onPressed: () => _addToCart(product),
                    child: const Text('Add to Cart'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}