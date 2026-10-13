import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pet_adoption_app/data/models/user_model.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/data/models/adoption_request_model.dart';
import 'package:pet_adoption_app/viewmodels/auth_viewmodel.dart';
import 'package:pet_adoption_app/viewmodels/pet_viewmodel.dart';
import 'package:pet_adoption_app/viewmodels/adoption_viewmodel.dart';
import 'package:pet_adoption_app/views/auth/login_screen.dart';
import 'package:pet_adoption_app/views/auth/register_screen.dart';
import 'package:pet_adoption_app/views/common/profile_screen.dart';
import 'package:pet_adoption_app/views/owner/add_edit_pet_screen.dart';
import 'package:pet_adoption_app/views/adopter/pet_detail_screen.dart';

void main() {
  group('Pet Haus MVVM Models & ViewModels Tests', () {
    test('UserModel correctly parses and identifies roles', () {
      final adopter = UserModel(
        uid: 'user_123',
        name: 'Jane Doe',
        email: 'jane@example.com',
        role: 'adopter',
      );

      expect(adopter.isAdopter, isTrue);
      expect(adopter.isOwner, isFalse);

      final ownerMap = {
        'uid': 'owner_456',
        'name': 'Happy Paws Shelter',
        'email': 'shelter@example.com',
        'role': 'owner',
      };
      final owner = UserModel.fromMap(ownerMap);
      expect(owner.isOwner, isTrue);
      expect(owner.isAdopter, isFalse);
    });

    test('PetModel serializes to and from Map accurately', () {
      final pet = PetModel(
        id: 'pet_01',
        name: 'Barnaby',
        breed: 'Golden Retriever',
        category: 'Dog',
        age: '2 years',
        gender: 'Male',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/dog.jpg',
        ownerId: 'owner_456',
        ownerName: 'Shelter',
        location: 'Seattle',
        adoptionFee: 50.0,
      );

      final map = pet.toMap();
      final parsed = PetModel.fromMap(map);

      expect(parsed.id, equals('pet_01'));
      expect(parsed.name, equals('Barnaby'));
      expect(parsed.category, equals('Dog'));
      expect(parsed.adoptionFee, equals(50.0));
      expect(parsed.isAdopted, isFalse);
    });

    test('AdoptionRequestModel correctly identifies statuses', () {
      final request = AdoptionRequestModel(
        id: 'req_01',
        petId: 'pet_01',
        petName: 'Barnaby',
        petImageUrl: 'https://example.com/dog.jpg',
        adopterId: 'user_123',
        adopterName: 'Jane Doe',
        adopterEmail: 'jane@example.com',
        ownerId: 'owner_456',
        message: 'I would love to adopt Barnaby!',
        status: 'pending',
      );

      expect(request.isPending, isTrue);
      expect(request.isApproved, isFalse);

      final approvedRequest = request.copyWith(status: 'approved');
      expect(approvedRequest.isApproved, isTrue);
      expect(approvedRequest.isPending, isFalse);
    });

    test('AuthViewModel manages role switching cleanly', () {
      final authVM = AuthViewModel();
      expect(authVM.selectedRole, equals('adopter'));

      authVM.setSelectedRole('owner');
      expect(authVM.selectedRole, equals('owner'));
      expect(authVM.isOwner, isTrue);

      authVM.setSelectedRole('adopter');
      expect(authVM.selectedRole, equals('adopter'));
      expect(authVM.isAdopter, isTrue);
    });

    test('PetViewModel handles favorite toggling and category selection', () {
      final petVM = PetViewModel();

      expect(petVM.isFavorite('pet_1'), isFalse);
      petVM.toggleFavorite('pet_1');
      expect(petVM.isFavorite('pet_1'), isTrue);
      petVM.toggleFavorite('pet_1');
      expect(petVM.isFavorite('pet_1'), isFalse);

      expect(petVM.selectedCategory, equals('All'));
      petVM.setCategory('Cat');
      expect(petVM.selectedCategory, equals('Cat'));

      expect(petVM.adopterNavIndex, equals(0));
      petVM.setAdopterNavIndex(2);
      expect(petVM.adopterNavIndex, equals(2));

      final authVM = AuthViewModel();
      expect(authVM.isLoginPasswordHidden, isTrue);
      authVM.toggleLoginPasswordVisibility();
      expect(authVM.isLoginPasswordHidden, isFalse);
    });

    testWidgets('LoginScreen renders Stack with peeking dog and login card', (
      tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      // Verify Stack is present
      expect(find.byType(Stack), findsWidgets);

      // Verify peeking dog image is present in LoginScreen
      expect(find.byType(Image), findsOneWidget);

      // Verify Welcome text and form fields are present
      expect(find.text('Welcome Back! 🐾'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets(
      'RegisterScreen renders Stack with background cat Lottie and card',
      (tester) async {
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthViewModel>(
            create: (_) => AuthViewModel(),
            child: const MaterialApp(home: RegisterScreen()),
          ),
        );

        // Verify Stack is present
        expect(find.byType(Stack), findsWidgets);

        // Verify header and form elements
        expect(find.text('Join Pet Haus 🐾'), findsOneWidget);
        expect(find.text('Full Name'), findsOneWidget);
        expect(find.text('Email Address'), findsOneWidget);
        expect(find.text('Phone Number (Optional)'), findsOneWidget);
        expect(find.text('Register Account'), findsOneWidget);
        expect(find.text('Already have an account? '), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
      },
    );

    test(
      'PetViewModel and AdoptionViewModel manage stream guards without loops',
      () {
        final petVM = PetViewModel();
        expect(petVM.hasLoadedAllPets, isFalse);
        expect(petVM.hasLoadedOwnerPets, isFalse);

        final adoptionVM = AdoptionViewModel();
        expect(adoptionVM.hasLoadedAdopterRequests, isFalse);
        expect(adoptionVM.hasLoadedOwnerRequests, isFalse);
      },
    );

    testWidgets(
      'ProfileScreen renders cleanly without Material shape assertions',
      (tester) async {
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthViewModel>(
            create: (_) => AuthViewModel(),
            child: const MaterialApp(home: ProfileScreen()),
          ),
        );

        // Verify ProfileScreen components are rendered
        expect(find.text('My Profile'), findsOneWidget);
        expect(find.text('Change Profile Photo'), findsOneWidget);
        expect(find.text('Switch App Mode'), findsOneWidget);
        expect(find.text('Privacy & Security'), findsOneWidget);
        expect(find.text('About Pet Haus'), findsOneWidget);
        expect(find.text('Sign Out'), findsOneWidget);
      },
    );

    test('UserModel supports photoUrl serialization and copyWith', () {
      final user = UserModel(
        uid: 'user_789',
        name: 'Sarah Connor',
        email: 'sarah@example.com',
        role: 'owner',
        photoUrl: 'data:image/jpeg;base64,samplebase64data',
      );

      expect(user.photoUrl, equals('data:image/jpeg;base64,samplebase64data'));
      final map = user.toMap();
      expect(
        map['photoUrl'],
        equals('data:image/jpeg;base64,samplebase64data'),
      );

      final parsed = UserModel.fromMap(map);
      expect(
        parsed.photoUrl,
        equals('data:image/jpeg;base64,samplebase64data'),
      );

      final updated = parsed.copyWith(
        photoUrl: 'data:image/jpeg;base64,newphoto',
      );
      expect(updated.photoUrl, equals('data:image/jpeg;base64,newphoto'));
    });

    test('PetModel supports multi-image list serialization and fallback', () {
      final pet = PetModel(
        id: 'pet_multi',
        name: 'Mochi',
        breed: 'Siamese Cat',
        category: 'Cat',
        age: '1 year',
        gender: 'Female',
        description: 'Playful cat',
        imageUrl: 'data:image/jpeg;base64,img1',
        images: [
          'data:image/jpeg;base64,img1',
          'data:image/jpeg;base64,img2',
          'data:image/jpeg;base64,img3',
        ],
        ownerId: 'owner_1',
        ownerName: 'Alice',
        location: 'Portland',
      );

      expect(pet.images.length, equals(3));
      expect(pet.imageUrl, equals('data:image/jpeg;base64,img1'));

      final map = pet.toMap();
      expect(map['images'], isA<List>());
      expect((map['images'] as List).length, equals(3));

      final parsed = PetModel.fromMap(map);
      expect(parsed.images.length, equals(3));
      expect(parsed.images[1], equals('data:image/jpeg;base64,img2'));
      expect(parsed.imageUrl, equals('data:image/jpeg;base64,img1'));

      // Test fallback when images list is omitted in fromMap
      final legacyMap = {
        'id': 'legacy_pet',
        'name': 'Buddy',
        'imageUrl': 'https://example.com/single.jpg',
      };
      final legacyPet = PetModel.fromMap(legacyMap);
      expect(legacyPet.images.length, equals(1));
      expect(legacyPet.images.first, equals('https://example.com/single.jpg'));
    });

    test('PetViewModel manages up to 4 images with add and remove', () {
      final vm = PetViewModel();
      expect(vm.petImages.isEmpty, isTrue);

      vm.addPetImage('img_1');
      vm.addPetImage('img_2');
      vm.addPetImage('img_3');
      vm.addPetImage('img_4');
      expect(vm.petImages.length, equals(4));

      // Attempting to add 5th image must be rejected
      vm.addPetImage('img_5');
      expect(vm.petImages.length, equals(4));

      // Removing index 1
      vm.removePetImage(1);
      expect(vm.petImages.length, equals(3));
      expect(vm.petImages, equals(['img_1', 'img_3', 'img_4']));

      // Removing cover image updates primary imageUrl
      vm.removePetImage(0);
      expect(vm.petImages.first, equals('img_3'));
      expect(vm.petImageUrlController.text, equals('img_3'));
    });

    testWidgets(
      'AddEditPetScreen has no Image URL, no Presets, no Firestore banner, and renders Pet Photos header',
      (tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthViewModel>(
                create: (_) => AuthViewModel(),
              ),
              ChangeNotifierProvider<PetViewModel>(
                create: (_) => PetViewModel(),
              ),
            ],
            child: const MaterialApp(home: AddEditPetScreen()),
          ),
        );

        // Verify Pet Photos section and upload card are displayed
        expect(find.text('Pet Photos'), findsOneWidget);
        expect(find.text('Upload up to 4 photos from device'), findsOneWidget);
        expect(find.text('0/4'), findsOneWidget);
        expect(find.text('Upload Pet Photos'), findsOneWidget);
        expect(
          find.text('Select up to 4 photos from camera or gallery'),
          findsOneWidget,
        );

        // Verify Image URL textfield is removed
        expect(find.text('Image URL'), findsNothing);

        // Verify Quick Photo Presets is removed
        expect(find.text('Quick Photo Presets:'), findsNothing);

        // Verify Photo selected from device banner is removed
        expect(
          find.text('Photo selected from device (saved in Firestore)'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'PetDetailScreen renders multi-image PageView and photo count badge when multiple images exist',
      (tester) async {
        final multiImagePet = PetModel(
          id: 'test_pet_detail',
          name: 'Bella',
          breed: 'Beagle',
          category: 'Dog',
          age: '2 years',
          gender: 'Female',
          description: 'Lovable and playful beagle.',
          imageUrl: 'https://example.com/bella1.jpg',
          images: [
            'https://example.com/bella1.jpg',
            'https://example.com/bella2.jpg',
            'https://example.com/bella3.jpg',
          ],
          ownerId: 'owner_1',
          ownerName: 'John',
          location: 'San Francisco',
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthViewModel>(
                create: (_) => AuthViewModel(),
              ),
              ChangeNotifierProvider<PetViewModel>(
                create: (_) => PetViewModel(),
              ),
              ChangeNotifierProvider<AdoptionViewModel>(
                create: (_) => AdoptionViewModel(),
              ),
            ],
            child: MaterialApp(home: PetDetailScreen(pet: multiImagePet)),
          ),
        );

        // Verify PageView is used for carousel
        expect(find.byType(PageView), findsOneWidget);

        // Verify photo count badge is rendered
        expect(find.text('1/3'), findsOneWidget);

        // Verify Pet Gallery thumbnails section is rendered
        expect(find.text('Pet Gallery'), findsOneWidget);
        expect(find.text('3 photos'), findsOneWidget);
      },
    );
  });
}
