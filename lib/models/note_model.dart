import 'package:daily_notes_app/constants/constants.dart';

class NoteModel {
  final String id;
  final String title;
  final String description;
  final bool reminderEnabled;
  final DateTime? reminderDateTime;
  final int? createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reminderEnabled,
    this.reminderDateTime,
    this.createdAt,
  });

  factory NoteModel.fromMap(Map<dynamic, dynamic> map) {
    return NoteModel(
      id: map[NoteFields.id] ?? '',
      title: map[NoteFields.title] ?? '',
      description: map[NoteFields.description] ?? '',
      reminderEnabled: map[NoteFields.reminderEnabled] ?? false,
      reminderDateTime: map[NoteFields.reminderDateTime] != null
          ? DateTime.fromMicrosecondsSinceEpoch(
              map[NoteFields.reminderDateTime],
            )
          : null,
      createdAt: map[NoteFields.createdAt],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      NoteFields.id: id,
      NoteFields.title: title,
      NoteFields.description: description,
      NoteFields.reminderEnabled: reminderEnabled,
      NoteFields.reminderDateTime:
          reminderDateTime?.microsecondsSinceEpoch,
      NoteFields.createdAt: createdAt,
    };
  }
}