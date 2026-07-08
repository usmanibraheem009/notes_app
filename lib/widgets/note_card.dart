
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
    required this.isPinned,
    this.togglePin,
    required this.isLocked,
    this.toggleLock
  });

  final String title;
  final String description;
  final VoidCallback? onDelete;
  final VoidCallback toggleFavorite;
  final VoidCallback? togglePin;
  final VoidCallback? toggleLock;
  final bool isFavorite;
  final bool isPinned;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
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
                    style: TextStyle(
                        color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  iconColor: colorScheme.onPrimary,
                  onSelected: (value) {
                    if(value == 'delete'){
                      onDelete?.call();
                    }else if(value == 'favorite'){
                      toggleFavorite();
                    }else if(value == 'pinned'){
                      togglePin?.call();
                    }else if(value == 'locked'){
                      toggleLock?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'pinned',
                      child: ListTile(
                        title: Text(isPinned? 'Unpin' : 'Pin', style: TextStyle(color: colorScheme.onPrimary),),
                        leading: Icon(isPinned? Icons.push_pin_rounded : Icons.push_pin_outlined, color: colorScheme.onPrimary,),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        title: Text('Delete', style: TextStyle(color: colorScheme.onPrimary),),
                        leading: Icon(Icons.delete, color: colorScheme.onPrimary,),
                      ),
                    ),
                    // PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'favorite',
                      child: ListTile(
                        title: Text( isFavorite? 'Remove from favorites': 'Add to favorites', style: TextStyle(color: colorScheme.onPrimary),),
                        leading: Icon(isFavorite? Icons.favorite : Icons.favorite_border, color: Colors.red,),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'locked',
                      child: ListTile(
                        title: Text( isLocked? 'Unlock': 'Lock', style: TextStyle(color: colorScheme.onPrimary),),
                        leading: Icon(isLocked? Icons.lock : Icons.lock_open, color: colorScheme.onPrimary,),
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
              style: TextStyle(color: colorScheme.onPrimary),
            ),
            
          ],
        ),
      ),
    );
  }
}