import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');
  final FirebaseStorage storage =
      FirebaseStorage.instance; // Firebase Storage instance

  // Create
  Future<String> addNote({
    required String longitude,
    required String latitude,
    required File image,
    String? stage, // Change to String
  }) async {
    try {
      print(
          'Attempting to save note with Longitude: $longitude, Latitude: $latitude');

      // Upload image to Firebase Storage
      String imageUrl = await uploadImage(image);

      // Get the current count of notes to increment the title
      int noteCount = await getNotesCount();
      String title = 'Tagged-Tree ${noteCount + 1}';

      // Add note to Firestore
      DocumentReference docRef = await notes.add({
        'title': title,
        'longitude': longitude,
        'latitude': latitude,
        'imageUrl': imageUrl, // Store image URL
        'stage': stage ?? 'No data yet',
        'timestamp': Timestamp.now(),
      });
      return docRef.id; // Return the document ID
    } catch (e) {
      print('Error adding data: $e');
      rethrow; // Re-throw the error to be handled by the caller
    }
  }

  // Method to update the stage for an existing note
  Future<void> updateStage({
    required String docID,
    required String stage, // Stage to update or add
  }) async {
    try {
      print('Updating stage for note ID: $docID to $stage');
      await notes.doc(docID).update({
        'stage': stage, // Update the stage field
        'timestamp': Timestamp.now(), // Optionally update the timestamp
      });
      print('Stage updated successfully!');
    } catch (e) {
      print('Error updating stage: $e');
      rethrow; // Re-throw the error to be handled by the caller
    }
  }

  // Function to get the count of existing notes
  Future<int> getNotesCount() async {
    QuerySnapshot snapshot = await notes.get();
    return snapshot.docs.length; // Return the count of documents
  }

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

  // Read
  Stream<QuerySnapshot> getNoteStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  // Update
  Future<void> updateNote({
    required String docID,
    required String title,
    required String longitude,
    required String latitude,
    String? imageUrl, // Optional image URL for updates
    String? stage, // Optional stage for updates
  }) {
    return notes.doc(docID).update({
      'title': title,
      'longitude': longitude,
      'latitude': latitude,
      if (imageUrl != null)
        'imageUrl': imageUrl, // Update image URL if provided
      if (stage != null) 'stage': stage, // Update stage if provided
      'timestamp': Timestamp.now(),
    });
  }

  // Delete
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }

  // Get a specific note by ID
  Future<Map<String, dynamic>> getNoteById(String docID) async {
    DocumentSnapshot doc = await notes.doc(docID).get();
    return doc.data() as Map<String, dynamic>;
  }
}
