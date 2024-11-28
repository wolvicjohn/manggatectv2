import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Create a note
  Future<String> addNote({
    required String longitude,
    required String latitude,
    required File image,
    String? stage,
    required stageImage,
    required bool isArchived, 
  }) async {
    try {
      print(
          'Attempting to save note with Longitude: $longitude, Latitude: $latitude');

      // Upload main image to Firebase Storage
      String imageUrl = await uploadImage(image);

      // Upload stage image if provided
      String? stageImageUrl;
      if (stageImage != null) {
        stageImageUrl = await uploadImage(stageImage);
      }

      // Add note to Firestore
      DocumentReference docRef = await notes.add({
        'longitude': longitude,
        'latitude': latitude,
        'imageUrl': imageUrl,
        'stage': stage ?? 'No data yet',
        'stageImageUrl': stageImageUrl, 
        'timestamp': Timestamp.now(),
        'isArchived': false,
      });

      print('Note added with ID: ${docRef.id}');
      return docRef.id; // Return the document ID
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
      print('Updating stage for note ID: $docID to $stage');

      // Upload new stage image if provided
      String? stageImageUrl;
      if (stageImage != null) {
        stageImageUrl = await uploadImage(stageImage);
      }

      // Update note in Firestore
      await notes.doc(docID).update({
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

  // Function to get the count of existing notes
  Future<int> getNotesCount() async {
    QuerySnapshot snapshot = await notes.get();
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

  // Read notes
  Stream<QuerySnapshot> getNoteStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  // Update an existing note
  Future<void> updateNote({
    required String docID,
    required String longitude,
    required String latitude,
    String? imageUrl, // Optional image URL for updates
    String? stage, // Optional stage for updates
    String? stageImageUrl, // Optional stage image URL for updates
  }) {
    return notes.doc(docID).update({
      'longitude': longitude,
      'latitude': latitude,
      if (imageUrl != null) 'imageUrl': imageUrl, // Update image URL if provided
      if (stage != null) 'stage': stage, // Update stage if provided
      if (stageImageUrl != null) 'stageImageUrl': stageImageUrl, // Update stage image URL
      'timestamp': Timestamp.now(),
    });
  }

  // Delete a note
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }

  // Get a specific note by ID
  Future<Map<String, dynamic>> getNoteById(String docID) async {
    DocumentSnapshot doc = await notes.doc(docID).get();
    return doc.data() as Map<String, dynamic>;
  }
}
