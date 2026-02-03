class Item {
  String? id;
  String name;
  String description;
  String location;
  String category; // "Lost" or "Found"
  String whatsapp;
  String imageUrl;
  String userId;
  String status; // "Active" or "Solved"

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.category,
    required this.whatsapp,
    required this.imageUrl,
    required this.userId,
    this.status = "Active",
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? 'Lost',
      whatsapp: json['whatsapp'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      userId: json['userId']?.toString() ?? '',
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'category': category,
      'whatsapp': whatsapp,
      'imageUrl': imageUrl,
      'userId': userId,
      'status': status,
    };
  }
}
