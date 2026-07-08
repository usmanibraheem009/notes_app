import 'package:daily_notes_app/constants/constants.dart';
import 'package:daily_notes_app/screens/add_note.dart';
import 'package:daily_notes_app/screens/note_details.dart';
import 'package:daily_notes_app/services/lock_service.dart';
import 'package:daily_notes_app/utils/notes_filter.dart';
import 'package:daily_notes_app/utils/utils.dart';
import 'package:daily_notes_app/widgets/note_card.dart';
import 'package:daily_notes_app/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      appBar: AppBar(
        iconTheme: IconThemeData(color: scheme.onPrimary),
        backgroundColor: scheme.primary,
        title: Text(
          'Home Screen',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: scheme.onPrimary),
        ),
        centerTitle: true,
      ),
      drawer: NotesDrawer(),
      body: Center(
          child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          children: [
            TextFormField(
              controller: searchController,
              cursorColor: scheme.onPrimary,
              style: TextStyle(color: scheme.onPrimary),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: scheme.onPrimary),
                prefixIconColor: scheme.onPrimary,
                filled: true,
                fillColor: scheme.surface,
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: scheme.onSurface)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: scheme.onSurface)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: scheme.onSurface)),
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
                            child: Text(
                          'Somthing went wrong: ${snapshot.error}',
                          style: TextStyle(color: scheme.onPrimary),
                        ));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final notesMap =
                          parseNotesMap(snapshot.data?.snapshot.value);
                      if (notesMap == null || notesMap.isEmpty) {
                        return Center(
                          child: Text(
                            'No notes yet',
                            style: TextStyle(color: scheme.onPrimary),
                          ),
                        );
                      }

                      final sorted = sortByTimeStamp(notesMap);
                      final query = searchController.text.trim().toLowerCase();
                      final filtered = filterNotes(sorted, query);

                      if (filtered.isEmpty) {
                        return Center(
                            child: Text(
                          'No matching notes found',
                          style: TextStyle(color: scheme.onPrimary),
                        ));
                      }

                      return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 1,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (gridContext, index) {
                            final id = filtered[index].key;
                            final value = Map<String, dynamic>.from(
                                filtered[index].value as Map);
                            return InkWell(
                              onTap: () async {
                                final isLocked =
                                    value[NoteFields.isLocked] ?? false;
                                if (isLocked) {
                                  final success =
                                      await LockService.instance.authenticate();

                                  if (!success) return;
                                  if (!mounted) return;
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) => NoteDetails(
                                              id: id,
                                            )));
                              },
                              child: NoteCard(
                                title:
                                    value[NoteFields.title]?.toString() ?? '',
                                description:
                                    value[NoteFields.description]?.toString() ??
                                        '',
                                onDelete: () {
                                  _showDeleteDialog(context, id);
                                },
                                toggleFavorite: () {
                                  dbref.child(id).update({
                                    'isFavorite': !value[NoteFields.isFavorite]
                                  });
                                  Utils().showToast(value[NoteFields.isFavorite]
                                      ? 'Removed from favorites!'
                                      : 'Added to favorites!');
                                },
                                isFavorite:
                                    value[NoteFields.isFavorite] ?? false,
                                isPinned: value[NoteFields.isPinned] ?? false,
                                togglePin: () {
                                  dbref.child(id).update({
                                    'isPinned': !value[NoteFields.isPinned]
                                  });
                                  Utils().showToast(value[NoteFields.isPinned]
                                      ? 'Note is unpinned!'
                                      : 'Note is pinned to top!');
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
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: scheme.onSurface)),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => AddNote()));
        },
        child: Icon(Icons.add, color: scheme.onPrimary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
