import 'package:daily_notes_app/constants/constants.dart';
import 'package:daily_notes_app/screens/note_details.dart';
import 'package:daily_notes_app/services/lock_service.dart';
import 'package:daily_notes_app/utils/notes_filter.dart';
import 'package:daily_notes_app/utils/utils.dart';
import 'package:daily_notes_app/widgets/note_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final dbref = FirebaseDatabase.instance
      .ref('notes')
      .child(FirebaseAuth.instance.currentUser!.uid);
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: colorScheme.onPrimary,
            )),
        title: Text(
          'Favorites',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              TextFormField(
                controller: searchController,
                cursorColor: colorScheme.onPrimary,
                style: TextStyle(color: colorScheme.onPrimary),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: colorScheme.onPrimary),
                  prefixIconColor: colorScheme.onPrimary,
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.onSurface)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.onSurface)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colorScheme.onSurface)),
                ),
                onChanged: (String value) {
                  setState(() {});
                },
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                      stream: dbref.onValue,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child:
                                Text('Something went wrong: ${snapshot.error}'),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final notesMap =
                            parseNotesMap(snapshot.data?.snapshot.value);
                        if (notesMap == null || notesMap.isEmpty) {
                          return Center(
                              child: Text(
                            'No notes yet',
                            style: TextStyle(color: colorScheme.onPrimary),
                          ));
                        }

                        final sorted = sortByTimeStamp(notesMap);
                        final favoritesOnly = filterFavorites(sorted);

                        if (favoritesOnly.isEmpty) {
                          return Center(
                              child: Text(
                            'No favorite notes yet',
                            style: TextStyle(color: colorScheme.onPrimary),
                          ));
                        }

                        final query =
                            searchController.text.trim().toLowerCase();
                        final filtered = filterNotes(favoritesOnly, query);

                        if (filtered.isEmpty) {
                          return Center(
                              child: Text(
                            'No matching favorites found',
                            style: TextStyle(color: colorScheme.onPrimary),
                          ));
                        }

                        return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final id = filtered[index].key;
                              final value = Map<String, dynamic>.from(
                                  filtered[index].value as Map);

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) =>
                                              NoteDetails(id: id)));
                                },
                                child: NoteCard(
                                  title:
                                      value[NoteFields.title]?.toString() ?? '',
                                  description: value[NoteFields.description]
                                          ?.toString() ??
                                      '',
                                  toggleFavorite: () {
                                    dbref.child(id).update({
                                      NoteFields.isFavorite:
                                          !(value[NoteFields.isFavorite])
                                    });
                                    Utils().showToast(value[NoteFields.isFavorite] ? 'Removed from favorites!': 'Added to favorites');
                                  },
                                  isFavorite:
                                      value[NoteFields.isFavorite] ?? false,
                                  onDelete: () {
                                    _showDeleteDialog(context, id);
                                  },
                                  isPinned: value[NoteFields.isPinned],
                                  togglePin: (){
                                    dbref.child(id).update({
                                      NoteFields.isPinned:
                                          !(value[NoteFields.isPinned])
                                    });
                                    Utils().showToast(value[NoteFields.isPinned]? 'Note is unpinned!': 'Note is pinned to top!');
                                  },
                                  isLocked: value[NoteFields.isLocked] ?? false,
                                  toggleLock: () async {
                                  final currentlyLocked =
                                      value[NoteFields.isLocked] ?? false;
                                      await LockService.instance.authenticate();

                                  await dbref.child(id).update({
                                    NoteFields.isLocked: !currentlyLocked,
                                  });

                                  Utils().showToast(
                                    currentlyLocked
                                        ? 'Note unlocked!'
                                        : 'Note locked!',
                                  );
                                },
                                ),
                              );
                            });
                      }))
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) async {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: Text(
                'Delete Note',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to delete this note?',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colorScheme.onSecondary),
                    )),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                    ),
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await dbref.child(id).remove();
                      Utils().showToast('Note was deleted!');
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ));
  }
}
