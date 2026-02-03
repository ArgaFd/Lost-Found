import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  _MyPostsScreenState createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  List<Item> _myItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyItems();
  }

  Future<void> _fetchMyItems() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentUserId = prefs.getString('userId');

    // Note: Idealnya backend punya endpoint /items/my atau filter by user_id
    // Di sini kita filter manual dari getAll (kurang efisien tapi ok untuk demo)
    try {
      if (currentUserId != null) {
        List<Item> allItems = await ApiService.getItems();
        setState(() {
          _myItems = allItems
              .where((item) => item.userId == currentUserId)
              .toList();
        });
      }
    } catch (e) {
      // handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Hapus Postingan?"),
            content: const Text("Tindakan ini tidak bisa dibatalkan."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hapus"),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await ApiService.deleteItem(id);
      _fetchMyItems();
    }
  }

  Future<void> _markAsSolved(Item item) async {
    await ApiService.updateItem(item.id!, {'status': 'Solved'});
    _fetchMyItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Postingan Saya")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _myItems.length,
              itemBuilder: (context, index) {
                final item = _myItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text("${item.category} - ${item.status}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'delete') _deleteItem(item.id!);
                        if (val == 'solve') _markAsSolved(item);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'solve',
                          child: Text("Tandai Selesai"),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            "Hapus",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
