import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';
import '../models/adoption_request_model.dart';
import 'mock_data_helper.dart';

class PetService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _petsRef =>
      _firestore.collection('pets');

  CollectionReference<Map<String, dynamic>> get _requestsRef =>
      _firestore.collection('adoption_requests');

  /// Stream of all available pets
  Stream<List<PetModel>> getAllPetsStream() {
    return _petsRef.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        // Return default starter pets if Firestore is empty
        return MockDataHelper.getInitialSamplePets();
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PetModel.fromMap(data, id: doc.id);
      }).toList();
    }).handleError((error) {
      // ignore: avoid_print
      print('Firestore getAllPetsStream error: $error');
      return MockDataHelper.getInitialSamplePets();
    });
  }

  /// Stream of pets owned by a specific owner
  Stream<List<PetModel>> getOwnerPetsStream(String ownerId) {
    return _petsRef
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PetModel.fromMap(data, id: doc.id);
      }).toList();
    }).handleError((error) {
      // ignore: avoid_print
      print('Firestore getOwnerPetsStream error: $error');
      return <PetModel>[];
    });
  }

  /// Add a new pet listing
  Future<void> addPet(PetModel pet) async {
    try {
      final docRef = _petsRef.doc();
      final newPet = pet.copyWith(id: docRef.id);
      await docRef.set(newPet.toMap());
    } catch (e) {
      throw Exception('Failed to add pet: $e');
    }
  }

  /// Update an existing pet listing
  Future<void> updatePet(PetModel pet) async {
    try {
      await _petsRef.doc(pet.id).update(pet.toMap());
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  /// Delete a pet listing
  Future<void> deletePet(String petId) async {
    try {
      await _petsRef.doc(petId).delete();
    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }

  /// Submit an adoption request
  Future<void> submitAdoptionRequest(AdoptionRequestModel request) async {
    try {
      final docRef = _requestsRef.doc();
      final newRequest = request.copyWith(id: docRef.id);
      await docRef.set(newRequest.toMap());
    } catch (e) {
      throw Exception('Failed to submit adoption request: $e');
    }
  }

  /// Stream of requests submitted by an adopter
  Stream<List<AdoptionRequestModel>> getAdopterRequestsStream(String adopterId) {
    return _requestsRef
        .where('adopterId', isEqualTo: adopterId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AdoptionRequestModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    }).handleError((error) {
      // ignore: avoid_print
      print('Firestore getAdopterRequestsStream error: $error');
      return <AdoptionRequestModel>[];
    });
  }

  /// Stream of requests received by an owner
  Stream<List<AdoptionRequestModel>> getOwnerRequestsStream(String ownerId) {
    return _requestsRef
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AdoptionRequestModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    }).handleError((error) {
      // ignore: avoid_print
      print('Firestore getOwnerRequestsStream error: $error');
      return <AdoptionRequestModel>[];
    });
  }

  /// Update request status ('approved' or 'rejected')
  Future<void> updateRequestStatus({
    required String requestId,
    required String petId,
    required String status,
  }) async {
    try {
      await _requestsRef.doc(requestId).update({'status': status});
      if (status.toLowerCase() == 'approved') {
        // Mark pet as adopted
        await _petsRef.doc(petId).update({'isAdopted': true});
      }
    } catch (e) {
      throw Exception('Failed to update request: $e');
    }
  }

  /// Seed initial pets into Firestore if collection is empty
  Future<void> seedInitialPets() async {
    try {
      final snapshot = await _petsRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        final samplePets = MockDataHelper.getInitialSamplePets();
        for (final pet in samplePets) {
          await _petsRef.doc(pet.id).set(pet.toMap());
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Seeding initial pets note: $e');
    }
  }
}
