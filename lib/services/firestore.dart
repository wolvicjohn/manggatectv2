import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// import 'package:manggatectv2/utility/DeviceIdentifier.dart';

class FirestoreService {
  final CollectionReference mango_tree =
      FirebaseFirestore.instance.collection('mango_tree');
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Create a mango_tree
  Future<String> addmango_tree({
    required String longitude,
    required String latitude,
    required File image,
    String? stage,
    required stageImage,
    required bool isArchived,
    required String uploader,
  }) async {
    try {
      print(
          'Attempting to save mango_tree with Longitude: $longitude, Latitude: $latitude');

      // String deviceId = await DeviceIdentifier.getDeviceId();

      // Upload main image to Firebase Storage
      String imageUrl = await uploadImage(image);

      // Upload stage image if provided
      String? stageImageUrl;
      if (stageImage != null) {
        stageImageUrl = await uploadImage(stageImage);
      }

      // Add mango_tree to Firestore
      DocumentReference docRef = await mango_tree.add({
        'longitude': longitude,
        'latitude': latitude,
        'imageUrl': imageUrl,
        'stage': stage ?? 'No data yet',
        'stageImageUrl': stageImageUrl,
        'timestamp': Timestamp.now(),
        'isArchived': false,
        // 'deviceId': deviceId,
        'uploader': uploader,
      });

      print('mango_tree added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding data: $e');
      rethrow;
    }
  }

  // Method to update the stage and its image URL
  Future<void> updateStage({
    required String docID,
    required String stage,
    File? stageImage,
  }) async {
    try {
      print('Updating stage for mango_tree ID: $docID to $stage');

      // Upload new stage image if provided
      String? stageImageUrl;
      if (stageImage != null) {
        stageImageUrl = await uploadImage(stageImage);
      }

      // Update mango_tree in Firestore
      await mango_tree.doc(docID).update({
        'stage': stage, // Update the stage field
        if (stageImageUrl != null) 'stageImageUrl': stageImageUrl,
        'timestamp': Timestamp.now(), // Optionally update the timestamp
      });
      print('Stage updated successfully!');
    } catch (e) {
      print('Error updating stage: $e');
      rethrow;
    }
  }

  // get user history
  Stream<List<Map<String, dynamic>>> getAllMangoTrees() async* {
    String username = FirebaseAuth.instance.currentUser?.displayName ?? 'Guest';

    yield* mango_tree.where('uploader', isEqualTo: username).snapshots().map(
      (querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
      },
    );
  }

  // Function to get the count of existing mango_tree
  Future<int> getmango_treeCount() async {
    QuerySnapshot snapshot = await mango_tree.get();
    return snapshot.docs.length;
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File image) async {
    try {
      Reference ref = storage
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      await ref.putFile(image, metadata);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Read mango_tree
  Stream<QuerySnapshot> getmango_treetream() {
    return mango_tree.orderBy('timestamp', descending: true).snapshots();
  }

  // Update an existing mango_tree
  Future<void> updatemango_tree({
    required String docID,
    required String longitude,
    required String latitude,
    String? imageUrl, // Optional image URL for updates
    String? stage, // Optional stage for updates
    String? stageImageUrl, // Optional stage image URL for updates
  }) {
    return mango_tree.doc(docID).update({
      'longitude': longitude,
      'latitude': latitude,
      if (imageUrl != null)
        'imageUrl': imageUrl, // Update image URL if provided
      if (stage != null) 'stage': stage, // Update stage if provided
      if (stageImageUrl != null)
        'stageImageUrl': stageImageUrl, // Update stage image URL
      'timestamp': Timestamp.now(),
    });
  }

  // Get a specific mango_tree by ID
  Future<Map<String, dynamic>> getmango_treeById(String docID) async {
    DocumentSnapshot doc = await mango_tree.doc(docID).get();
    return doc.data() as Map<String, dynamic>;
  }
}
