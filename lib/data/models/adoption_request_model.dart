class AdoptionRequestModel {
  final String id;
  final String petId;
  final String petName;
  final String petBreed;
  final String petImageUrl;
  final String adopterId;
  final String adopterName;
  final String adopterEmail;
  final String adopterPhone;
  final String ownerId;
  final String message;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  AdoptionRequestModel({
    required this.id,
    required this.petId,
    required this.petName,
    this.petBreed = '',
    required this.petImageUrl,
    required this.adopterId,
    required this.adopterName,
    required this.adopterEmail,
    this.adopterPhone = '',
    required this.ownerId,
    required this.message,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'petBreed': petBreed,
      'petImageUrl': petImageUrl,
      'adopterId': adopterId,
      'adopterName': adopterName,
      'adopterEmail': adopterEmail,
      'adopterPhone': adopterPhone,
      'ownerId': ownerId,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AdoptionRequestModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AdoptionRequestModel(
      id: id ?? map['id'] ?? '',
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? '',
      petBreed: map['petBreed'] ?? '',
      petImageUrl: map['petImageUrl'] ?? '',
      adopterId: map['adopterId'] ?? '',
      adopterName: map['adopterName'] ?? '',
      adopterEmail: map['adopterEmail'] ?? '',
      adopterPhone: map['adopterPhone'] ?? '',
      ownerId: map['ownerId'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AdoptionRequestModel copyWith({
    String? id,
    String? petId,
    String? petName,
    String? petBreed,
    String? petImageUrl,
    String? adopterId,
    String? adopterName,
    String? adopterEmail,
    String? adopterPhone,
    String? ownerId,
    String? message,
    String? status,
    DateTime? createdAt,
  }) {
    return AdoptionRequestModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petBreed: petBreed ?? this.petBreed,
      petImageUrl: petImageUrl ?? this.petImageUrl,
      adopterId: adopterId ?? this.adopterId,
      adopterName: adopterName ?? this.adopterName,
      adopterEmail: adopterEmail ?? this.adopterEmail,
      adopterPhone: adopterPhone ?? this.adopterPhone,
      ownerId: ownerId ?? this.ownerId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
