import '../models/pet_model.dart';

class MockDataHelper {
  static List<PetModel> getInitialSamplePets() {
    return [
      PetModel(
        id: 'sample_dog_1',
        name: 'Barnaby',
        breed: 'Golden Retriever',
        category: 'Dog',
        age: '1.5 years',
        gender: 'Male',
        size: 'Large',
        description:
            'Barnaby is an exuberant, gentle-hearted Golden Retriever who adores belly rubs, playing fetch in the park, and greeting everyone with a wagging tail. He is fully vaccinated, potty trained, and great with children!',
        imageUrl:
            'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=800&q=80',
        ownerId: 'sample_owner_1',
        ownerName: 'Sarah Jenkins',
        ownerPhone: '+1 (555) 234-8901',
        location: 'Downtown, Seattle',
        adoptionFee: 50.0,
        isAdopted: false,
      ),
      PetModel(
        id: 'sample_cat_1',
        name: 'Mochi',
        breed: 'Ragdoll Cat',
        category: 'Cat',
        age: '8 months',
        gender: 'Female',
        size: 'Small',
        description:
            'Mochi is a sweet, blue-eyed Ragdoll who loves warm sunspots and quiet evening cuddles. She is purr-fectly litter trained, spayed, and loves playing with feather wands.',
        imageUrl:
            'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
        ownerId: 'sample_owner_2',
        ownerName: 'Liam Carter',
        ownerPhone: '+1 (555) 456-1122',
        location: 'West End, Portland',
        adoptionFee: 35.0,
        isAdopted: false,
      ),
      PetModel(
        id: 'sample_dog_2',
        name: 'Milo & Bella',
        breed: 'French Bulldog',
        category: 'Dog',
        age: '2 years',
        gender: 'Male',
        size: 'Small',
        description:
            'Friendly, compact, and extremely loving. Milo is very calm and gets along famously with other dogs. He loves short walks and snuggling on the sofa.',
        imageUrl:
            'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&w=800&q=80',
        ownerId: 'sample_owner_1',
        ownerName: 'Sarah Jenkins',
        ownerPhone: '+1 (555) 234-8901',
        location: 'Capitol Hill, Seattle',
        adoptionFee: 65.0,
        isAdopted: false,
      ),
      PetModel(
        id: 'sample_rabbit_1',
        name: 'Snowball',
        breed: 'Holland Lop',
        category: 'Rabbit',
        age: '1 year',
        gender: 'Female',
        size: 'Small',
        description:
            'Snowball is a silky soft Holland Lop bunny with adorable floppy ears. She loves fresh parsley, gentle ear scratches, and hopping around safe carpeted rooms.',
        imageUrl:
            'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?auto=format&fit=crop&w=800&q=80',
        ownerId: 'sample_owner_3',
        ownerName: 'Emma Watson',
        ownerPhone: '+1 (555) 789-3344',
        location: 'Bellevue, WA',
        adoptionFee: 25.0,
        isAdopted: false,
      ),
      PetModel(
        id: 'sample_cat_2',
        name: 'Oliver',
        breed: 'British Shorthair',
        category: 'Cat',
        age: '2.5 years',
        gender: 'Male',
        size: 'Medium',
        description:
            'A distinguished British Shorthair gentleman with a round face and plush silver coat. Very quiet, independent, yet deeply affectionate when it is time to unwind.',
        imageUrl:
            'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&w=800&q=80',
        ownerId: 'sample_owner_2',
        ownerName: 'Liam Carter',
        ownerPhone: '+1 (555) 456-1122',
        location: 'Green Lake, Seattle',
        adoptionFee: 40.0,
        isAdopted: false,
      ),
    ];
  }
}
