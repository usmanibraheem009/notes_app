class NoteFields {
  static const id = 'id';
  static const title = 'title';
  static const description = 'description';
  static const timestamp = 'timestamp';
  static const createdAt = 'createdAt';
  static const reminderEnabled = 'reminderEnabled';
  static const reminderDateTime = 'reminderDateTime';
  static const isFavorite = 'isFavorite';
}

String titleCase(String text) {
  return text
      .split(' ')
      .map((word) => word.isEmpty
          ? word
          : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

String capitalize(String text){
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}
