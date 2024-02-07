import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase/pages/home_page.dart';

class FirestoreService {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // CREATE
  Future<void> addNote(String title, String director, String summary,
      Iterable<Map<String, dynamic>> genres) {
    print(genres.runtimeType);
    print(genres);
    // genres.toString();

    return notes.add({
      'title': title,
      'director': director,
      'summary': summary,
      'genres': genres,
      'timestamp': Timestamp.now(),
    });
  }

  // READ
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  // UPDATE
  Future<void> updateNote(String docID, String newTitle, String newDirector,
      String newSummary, Iterable<Map<String, dynamic>> genres) {
    return notes.doc(docID).update(
      {
        'title': newTitle,
        'director': newDirector,
        'summary': newSummary,
        'genre': genres,
        'timestamp': Timestamp.now(),
      },
    );
  }

  // DELETE
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
