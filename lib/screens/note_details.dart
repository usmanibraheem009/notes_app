import 'package:daily_notes_app/constants/constants.dart';
import 'package:daily_notes_app/screens/add_note.dart';
import 'package:daily_notes_app/services/pdf_service.dart';
import 'package:daily_notes_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class NoteDetails extends StatelessWidget {
  const NoteDetails({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final noteRef = FirebaseDatabase.instance.ref('notes').child(FirebaseAuth.instance.currentUser!.uid).child(id);
    bool isFavorite = false;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
        ),
        title: Text(
          'Note Details',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => AddNote(id: id, isEditMode: true)),
                    );
                    break;
                  case 'delete':
                    _showDeleteDialog(context);
                    break;

                  case 'favorite':
                    await noteRef.update({NoteFields.isFavorite: !isFavorite});
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'favorite',
                      child: Row(
                        children: [
                          Icon(
                            isFavorite == true ? Icons.favorite : Icons.favorite_border,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 10),
                          Text('Favorite'),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 10),
                          Text('Share'),
                        ],
                      ),
                    ),
                  ])
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: noteRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final raw = snapshot.data?.snapshot.value;
          if (raw == null) {
            return const Center(child: Text('Note not found'));
          }

          final value = Map<String, dynamic>.from(raw as Map);
          final title = value[NoteFields.title]?.toString() ?? '';
          final description = value[NoteFields.description]?.toString() ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleCase(title),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      )
                      .copyWith(),
                ),
                const SizedBox(height: 6),
                Text(
                  capitalize(description),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )
                      .copyWith(fontWeight: FontWeight.w400),
                ),
                const Spacer(),
                Row(
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () async {
                        try {
                          await PdfService.instance.downloadToDownloads(
                              title: title, description: description);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('PDF saved to Storage')),
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to save PDF: $error')),
                            );
                          }
                        }
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(50)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            Text(
                              'PDF',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: RoundButton(
                          btnText: 'Share Note',
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          onTap: () async {
                            try {
                              final file = await PdfService.instance
                                  .generateForShare(
                                      title: title, description: description);
                              await SharePlus.instance.share(ShareParams(
                                  title: title, files: [XFile(file.path)]));
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to share PDF: $error')),
                                );
                              }
                            }
                          }),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
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
                      await FirebaseDatabase.instance
                          .ref('notes')
                          .child(id)
                          .remove();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ));
  }
}
