import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTaskService {
  // get collection of notes
  final CollectionReference taskBox = FirebaseFirestore.instance.collection(
    "taskBox",
  );

  // CREATE: add a new note
  Future<void> addTask(
    String title,
    String description,
    String dueDate,
    String categoryName,
  ) {
    return taskBox.add({
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'categoryName': categoryName,
    });
  }

  // READ: get notes from database

  // UPDATE: Update a note

  // DELETE: Delete a note
}

class FirestoreCategoryService {
  final CollectionReference taskBox = FirebaseFirestore.instance.collection(
    "categoryBox",
  );
}
