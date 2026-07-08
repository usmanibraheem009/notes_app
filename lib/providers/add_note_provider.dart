import 'package:daily_notes_app/constants/constants.dart';
import 'package:daily_notes_app/services/notification_service.dart';
import 'package:daily_notes_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotesProvider extends ChangeNotifier {
  bool isLoading = false;
  final dbRef = FirebaseDatabase.instance
      .ref('notes')
      .child(FirebaseAuth.instance.currentUser!.uid);
  String? errorMessage;

  Future<void> addNote(
      {required String title,
      required String description,
      required bool reminderEnabled,
      DateTime? reminderDateTime,
      bool? isFavorite,
      bool? isLocked,
      bool? isPinned}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newRef = dbRef.push();
      await newRef.set({
        NoteFields.id: newRef.key,
        NoteFields.title: title,
        NoteFields.description: description,
        NoteFields.reminderEnabled: reminderEnabled,
        NoteFields.reminderDateTime: reminderDateTime?.microsecondsSinceEpoch,
        NoteFields.createdAt: ServerValue.timestamp,
        NoteFields.isFavorite: isFavorite,
        NoteFields.isPinned: isPinned,
        NoteFields.isLocked: isLocked,
      });
      Utils().showToast('Note added successfully!');
      if (reminderEnabled && reminderDateTime != null) {
        NotificationService.instance.scheduleReminder(
            noteId: newRef.key!,
            title: title,
            description: description,
            scheduleDateTime: reminderDateTime);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNote(
      {required String id,
      required String title,
      required String description,
      bool reminderEnabled = false,
      DateTime? reminderDateTime,
      bool? isFavorite,
      bool? isLocked,
      bool? isPinned}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await dbRef.child(id).update({
        NoteFields.title: title,
        NoteFields.description: description,
        NoteFields.reminderEnabled: reminderEnabled,
        NoteFields.reminderDateTime: reminderDateTime?.microsecondsSinceEpoch,
        NoteFields.isFavorite: isFavorite,
        NoteFields.isPinned: isPinned,
        NoteFields.isLocked: isLocked,
      });
      Utils().showToast('Note updated successfully!');
      if (reminderEnabled && reminderDateTime != null) {
        NotificationService.instance.scheduleReminder(
            noteId: id,
            title: title,
            description: description,
            scheduleDateTime: reminderDateTime);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) {
    return dbRef.child(id).remove().then((_) {
      NotificationService.instance.cancelReminder(id);
      notifyListeners();
    });
  }

  Future<void> saveNote(
      {String? id,
      required String title,
      required String description,
      required bool reminderEnabled,
      DateTime? reminderDateTime,
      bool? isFavorite,
      bool? isLocked,
      bool? isPinned}) async {
    if (id == null) {
      return addNote(
          title: title,
          description: description,
          reminderEnabled: reminderEnabled,
          reminderDateTime: reminderDateTime,
          isFavorite: isFavorite,
          isLocked: isLocked,
          isPinned: isPinned);
    } else {
      return updateNote(
          id: id,
          title: title,
          description: description,
          reminderEnabled: reminderEnabled,
          reminderDateTime: reminderDateTime,
          isFavorite: isFavorite,
          isLocked: isLocked,
          isPinned: isPinned);
    }
  }
}
