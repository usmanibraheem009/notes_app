import 'package:daily_notes_app/constants/constants.dart';

Map<String, dynamic>? parseNotesMap(Object? raw) {
  if (raw is! Map) return null;
  try {
    return Map<String, dynamic>.from(raw);
  } catch (_) {
    return null;
  }
}

List<MapEntry<String, dynamic>> sortByTimeStamp(
    Map<String, dynamic> notesMap) {
  final validEntries = notesMap.entries.where((e) => e.value is Map).toList();
  validEntries.sort((a, b) {

    final aMap = a.value as Map;
    final bMap = b.value as Map;

   final aPinned = (aMap[NoteFields.isPinned] ?? false) == true;
    final bPinned = (bMap[NoteFields.isPinned] ?? false) == true;

    if(aPinned != bPinned){
      return aPinned ? -1 : 1;
    }

    final aTime = (aMap[NoteFields.timestamp]) ?? 0;
    final bTime = (bMap[NoteFields.timestamp]) ?? 0;
    return bTime.compareTo(aTime);
  });
  return validEntries;
}

List<MapEntry<String, dynamic>> filterNotes(
  List<MapEntry<String, dynamic>> entries,
  String query,
) {
  if (query.isEmpty) return entries;
  return entries.where((entry) {
    final v = entry.value as Map;
    final title = v[NoteFields.title]?.toString().toLowerCase() ?? '';
    final description = v[NoteFields.description]?.toString().toLowerCase() ?? '';
    return title.contains(query) || description.contains(query);
  }).toList();
}

List<MapEntry<String, dynamic>> filterFavorites(
  List<MapEntry<String, dynamic>> entries,
) {
  return entries.where((entry) {
    final v = entry.value as Map;
    return (v[NoteFields.isFavorite] ?? false) == true;
  }).toList();
}