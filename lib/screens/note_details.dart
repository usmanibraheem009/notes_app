import 'package:daily_notes_app/constants/constants.dart';
import 'package:daily_notes_app/screens/add_note.dart';
import 'package:daily_notes_app/services/pdf_service.dart';
import 'package:daily_notes_app/utils/utils.dart';
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
    final noteRef = FirebaseDatabase.instance
        .ref('notes')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(id);
    bool isFavorite = false;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
          color: scheme.onPrimary,
        ),
        title: Text(
          'Note Details',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: scheme.onPrimary),
        ),
        centerTitle: true,
        backgroundColor: scheme.primary,
        actions: [
          PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: scheme.onPrimary,
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
                    _showDeleteDialog(context, id);
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
                          Icon(
                            Icons.edit,
                            color: scheme.onPrimary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: scheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: scheme.onPrimary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: scheme.onPrimary,
                            ),
                          ),
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
            return Center(
                child: Text(
              'Note not found',
              style: TextStyle(
                color: scheme.onPrimary,
              ),
            ));
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimary,
                      fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  capitalize(description),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(
                        color: scheme.onSecondary,
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
                            Utils().showToast('PDF saved into storage!');
                          }
                        } catch (error) {
                          if (context.mounted) {
                            Utils().showToast('Failed to save PDF $error');
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
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            Text(
                              'PDF',
                              style: TextStyle(
                                  color: scheme.onPrimary,
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
                          onTap: () async {
                            try {
                              final file = await PdfService.instance
                                  .generateForShare(
                                      title: title, description: description);
                              await SharePlus.instance.share(ShareParams(
                                  title: title, files: [XFile(file.path)]));
                            } catch (error) {
                              if (context.mounted) {
                                Utils().showToast('Failed to share PDF $error');
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
                      await FirebaseDatabase.instance
                          .ref('notes')
                          .child(FirebaseAuth.instance.currentUser!.uid)
                          .child(id)
                          .remove();
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
