class PetModel {
  final String id;
  final String name;
  final String breed;
  final String category; // 'Dog', 'Cat', 'Bird', 'Rabbit', 'Other'
  final String age; // e.g. '2 years', '6 months'
  final String gender; // 'Male', 'Female'
  final String size; // 'Small', 'Medium', 'Large'
  final String description;
  final String imageUrl;
  final List<String> images;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final String location;
  final double adoptionFee;
  final bool isAdopted;
  final DateTime createdAt;

  PetModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.category,
    required this.age,
    required this.gender,
    this.size = 'Medium',
    required this.description,
    required this.imageUrl,
    List<String>? images,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhone = '',
    required this.location,
    this.adoptionFee = 0.0,
    this.isAdopted = false,
    DateTime? createdAt,
  })  : images = (images != null && images.isNotEmpty)
            ? images
            : (imageUrl.isNotEmpty ? [imageUrl] : const []),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'category': category,
      'age': age,
      'gender': gender,
      'size': size,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'location': location,
      'adoptionFee': adoptionFee,
      'isAdopted': isAdopted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PetModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawImages = map['images'];
    List<String> imagesList = [];
    if (rawImages is List) {
      imagesList = rawImages.map((e) => e.toString()).toList();
    }
    final primaryImg = (map['imageUrl'] ?? '').toString();
    if (imagesList.isEmpty && primaryImg.isNotEmpty) {
      imagesList = [primaryImg];
    }

    return PetModel(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      category: map['category'] ?? 'Dog',
      age: map['age'] ?? '1 year',
      gender: map['gender'] ?? 'Male',
      size: map['size'] ?? 'Medium',
      description: map['description'] ?? '',
      imageUrl: imagesList.isNotEmpty ? imagesList.first : primaryImg,
      images: imagesList,
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? 'Pet Owner',
      ownerPhone: map['ownerPhone'] ?? '',
      location: map['location'] ?? 'Nearby',
      adoptionFee: (map['adoptionFee'] is num)
          ? (map['adoptionFee'] as num).toDouble()
          : 0.0,
      isAdopted: map['isAdopted'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  PetModel copyWith({
    String? id,
    String? name,
    String? breed,
    String? category,
    String? age,
    String? gender,
    String? size,
    String? description,
    String? imageUrl,
    List<String>? images,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    String? location,
    double? adoptionFee,
    bool? isAdopted,
    DateTime? createdAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      category: category ?? this.category,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      size: size ?? this.size,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      location: location ?? this.location,
      adoptionFee: adoptionFee ?? this.adoptionFee,
      isAdopted: isAdopted ?? this.isAdopted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
