import 'package:daily_notes_app/constants/constants.dart';
import 'package:daily_notes_app/screens/note_details.dart';
import 'package:daily_notes_app/utils/notes_filter.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            )),
        title: Text(
          'Favorites',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.white),
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
                decoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                          return const Center(child: Text('No notes yet'));
                        }

                        final sorted = sortByTimeStamp(notesMap);
                        final favoritesOnly = filterFavorites(sorted);

                        if (favoritesOnly.isEmpty) {
                          return const Center(
                              child: Text('No favorite notes yet'));
                        }

                        final query =
                            searchController.text.trim().toLowerCase();
                        final filtered = filterNotes(favoritesOnly, query);

                        if (filtered.isEmpty) {
                          return const Center(
                              child: Text('No matching favorites found'));
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
                                  toggleFavorite: () => {
                                    dbref.child(id).update({
                                      NoteFields.isFavorite:
                                          !(value[NoteFields.isFavorite])
                                    })
                                  },
                                  isFavorite:
                                      value[NoteFields.isFavorite] ?? false,
                                  onDelete: () {
                                    _showDeleteDialog(context, id);
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
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                'Delete Note',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to delete this note?',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await dbref.child(id).remove();
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ));
  }
}
