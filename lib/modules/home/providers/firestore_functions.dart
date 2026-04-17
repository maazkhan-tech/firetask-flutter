import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FireStoreAction { addtask, updateTask, deleteTask, taskStatus, none }

class FireStoreState {
  final AsyncValue<void> status;
  final FireStoreAction action;
  FireStoreState({required this.status, this.action = FireStoreAction.none});
}

class FireBaseFirestoreNotifier extends Notifier<FireStoreState> {
  @override
  FireStoreState build() => FireStoreState(status: AsyncData(null));

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // fire store system
  Future<void> addTask(String title, String? description) async {
    state = FireStoreState(
      status: const AsyncLoading(),
      action: FireStoreAction.addtask,
    );
    final result = await AsyncValue.guard(() async {
      final userUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      String desc = description == null || description.isEmpty
          ? 'No description provided for this task.'
          : description;
      await firestore.collection('tasks').add({
        'title': title,
        'description': desc,
        'userId': userUid,
        'createdAt': FieldValue.serverTimestamp(),
        'isCompleted': false,
      });
    });
    state = FireStoreState(status: result, action: FireStoreAction.addtask);
  }

  // Update Task
  Future<void> updateTask(String userIDd, Map<String, dynamic> data) async {
    state = FireStoreState(
      status: const AsyncLoading(),
      action: FireStoreAction.updateTask,
    );
    final result = await AsyncValue.guard(() async {
      await firestore.collection('tasks').doc(userIDd).update(data);
    });
    state = FireStoreState(status: result, action: FireStoreAction.updateTask);
  }

  // delete Task

  Future<void> deleteTask(String userId) async {
    state = FireStoreState(
      status: const AsyncLoading(),
      action: FireStoreAction.deleteTask,
    );
    final result = await AsyncValue.guard(() async {
      await firestore.collection('tasks').doc(userId).delete();
    });
    state = FireStoreState(status: result, action: FireStoreAction.deleteTask);
  }
}

final firebaseFirestoreProvider =
    NotifierProvider<FireBaseFirestoreNotifier, FireStoreState>(
      () => FireBaseFirestoreNotifier(),
    );
