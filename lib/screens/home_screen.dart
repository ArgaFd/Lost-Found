import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';
import 'add_item_screen.dart';
import 'detail_screen.dart';
import 'login_screen.dart';
import 'my_posts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> _items = [];
  bool _isLoading = true;
  String _filter = "All"; // All, Lost, Found

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    try {
      List<Item> items = await ApiService.getItems();

      // Filter di sisi App (ideal di backend, tapi untuk simpel di sini saja)
      if (_filter != "All") {
        items = items
            .where((i) => i.category.toLowerCase() == _filter.toLowerCase())
            .toList();
      }

      setState(() {
        _items = items;
      });
    } catch (e) {
      // print(e); // Avoid print in production
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onFilterChanged(String category) {
    setState(() {
      _filter = category;
    });
    _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPostsScreen()),
            ),
            tooltip: 'Postingan Saya',
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
          _fetchItems(); // Refresh on back
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton("Semua", "All"),
                const SizedBox(width: 8),
                _buildFilterButton("Hilang", "Lost"),
                const SizedBox(width: 8),
                _buildFilterButton("Ditemukan", "Found"),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                ? const Center(child: Text("Belum ada barang"))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: item.imageUrl.isNotEmpty
                                ? Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, _) =>
                                        const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.image),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.location),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(item.category),
                                backgroundColor: item.category == 'Lost'
                                    ? Colors.red[100]
                                    : Colors.green[100],
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  color: item.category == 'Lost'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(item: item),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    bool isActive = _filter == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? Theme.of(context).primaryColor
            : Colors.white,
        foregroundColor: isActive ? Colors.white : Colors.black,
      ),
      onPressed: () => _onFilterChanged(value),
      child: Text(label),
    );
  }
}
