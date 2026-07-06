import 'package:daily_notes_app/constants/constants.dart';
import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.title,
    required this.description,
    this.onDelete,
    required this.toggleFavorite,
    required this.isFavorite,
  });

  final String title;
  final String description;
  final VoidCallback? onDelete;
  final VoidCallback toggleFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    titleCase(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<int>(
                  iconColor: Colors.white,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      onTap: onDelete,
                      child: const ListTile(
                        title: Text('Delete'),
                        leading: Icon(Icons.delete),
                      ),
                    ),
                    // PopupMenuDivider(),
                    PopupMenuItem(
                      value: 2,
                      onTap: toggleFavorite,
                      child: ListTile(
                        title: Text( isFavorite? 'Remove from favorites': 'Add to favorites'),
                        leading: Icon(isFavorite? Icons.favorite : Icons.favorite_border, color: Colors.red,),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              capitalize(description),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            
          ],
        ),
      ),
    );
  }
}