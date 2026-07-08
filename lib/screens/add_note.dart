import 'package:daily_notes_app/constants/constants.dart';
import 'package:daily_notes_app/providers/add_note_provider.dart';
import 'package:daily_notes_app/utils/utils.dart';
import 'package:daily_notes_app/widgets/input_field.dart';
import 'package:daily_notes_app/widgets/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key, this.id, this.isEditMode = false});

  final String? id;
  final bool isEditMode;

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  late final DatabaseReference noteRef;
  bool isFatching = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode && widget.id != null) {
      noteRef = FirebaseDatabase.instance
      .ref('notes')
      .child(FirebaseAuth.instance.currentUser!.uid).child(widget.id!);
      _loadNote();
    }
  }

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isEnabled = false;
  bool isFavorite = false;
  bool isPinned = false;
  bool isLocked = false;
  DateTime? reminderDateTime;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: colorScheme.onPrimary,
            )),
        backgroundColor: colorScheme.primary,
        title: Text(
          widget.isEditMode ? 'Edit Note' : 'Add Note',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Consumer<NotesProvider>(
            builder: (context, notesProvider, child) {
              return Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          InputField(
                            hintText: 'Add Title',
                            labelText: 'Title',
                            controller: titleController,
                            keyboardType: TextInputType.text,
                            prefixIcon: Icons.title,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          InputField(
                            hintText: 'Enter Description',
                            labelText: 'Description',
                            controller: descriptionController,
                            keyboardType: TextInputType.text,
                            prefixIcon: Icons.description,
                            maxLines: 2,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 1,
                                color: colorScheme.onPrimaryContainer)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Enable Reminder',
                                  style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Switch(
                                    value: isEnabled,
                                    activeThumbColor: colorScheme.onPrimary,
                                    inactiveThumbColor: colorScheme.onPrimary,
                                    inactiveTrackColor: colorScheme.onSurface,
                                    onChanged: (value) => {
                                          setState(() {
                                            isEnabled = value;
                                          })
                                        }),
                              ],
                            ),
                            if (isEnabled) ...[
                              SizedBox(height: 10),
                              Text(
                                reminderDateTime == null
                                    ? 'No reminder time is selected'
                                    : 'Reminder set for ${DateFormat('dd MM yyyy • hh:mm a').format(reminderDateTime!)}',
                                style: TextStyle(color: colorScheme.onPrimary),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: colorScheme.onSecondary),
                                  onPressed: _pickReminder,
                                  child: Text(
                                    'Pick Date',
                                    style: TextStyle(color: Colors.white),
                                  ))
                            ]
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RoundButton(
                        isLoading: notesProvider.isLoading,
                        onTap: () async {
                          if (titleController.text.isEmpty ||
                              descriptionController.text.isEmpty) {
                            Utils().showToast('Please fill up all the fields');
                            return;
                          }
                          if (isEnabled && reminderDateTime == null) {
                            Utils().showToast('Please select reminder date and time');
                            return;
                          }

                          await notesProvider.saveNote(
                              id: widget.id,
                              title: titleController.text,
                              description: descriptionController.text,
                              reminderEnabled: isEnabled,
                              reminderDateTime: reminderDateTime,
                              isFavorite: isFavorite,
                              isPinned: isPinned,
                              isLocked: isLocked);

                          if (!context.mounted) return;

                          if (notesProvider.errorMessage != null) {
                            Utils().showToast(notesProvider.errorMessage!);
                            return;
                          }
                          Navigator.pop(context);
                        },
                        btnText: widget.isEditMode ? 'Update Note' : 'Add Note',
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickReminder() async {
    final scheme = Theme.of(context).colorScheme;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: scheme.copyWith(
              primary: scheme
                  .secondaryContainer, // header bg — your button-purple, reads as an accent
              onPrimary: Colors.white, // header text
              surface: scheme
                  .primaryContainer, // calendar bg — your "card" white/dark surface
              onSurface: scheme.onPrimary,
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: scheme.surface, // the missing piece
              headerForegroundColor: Colors.white,
              backgroundColor: scheme.primaryContainer,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: scheme.copyWith(
              primary: scheme
                  .secondaryContainer, // header bg — your button-purple, reads as an accent
              onPrimary: Colors.white, // header text
              surface: scheme
                  .primaryContainer, // calendar bg — your "card" white/dark surface
              onSurface: scheme.onPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: scheme.primaryContainer,
              hourMinuteColor: scheme.surface,
              hourMinuteTextColor: scheme.onPrimary,
              dialBackgroundColor: scheme.surface,
              dialHandColor: scheme.secondaryContainer,
              dayPeriodColor: scheme.surface,
              dayPeriodTextColor: scheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    setState(() {
      reminderDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _loadNote() async {
    setState(() {
      isFatching = true;
    });

    try {
      final snapshot = await noteRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        titleController.text = data[NoteFields.title]?.toString() ?? '';
        descriptionController.text =
            data[NoteFields.description]?.toString() ?? '';
        isEnabled = data[NoteFields.reminderEnabled] ?? false;
        if (data[NoteFields.reminderDateTime] != null) {
          reminderDateTime = DateTime.fromMillisecondsSinceEpoch(
              data[NoteFields.reminderDateTime]);
        }
        setState(() {});
      }
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        isFatching = false;
      });
    }
  }
}
