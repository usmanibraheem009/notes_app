import 'package:daily_notes_app/screens/auth/login_screen.dart';
import 'package:daily_notes_app/screens/favorites.dart';
import 'package:daily_notes_app/screens/settings_screen.dart';
import 'package:daily_notes_app/services/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotesDrawer extends StatefulWidget {
  const NotesDrawer({super.key});

  @override
  State<NotesDrawer> createState() => _NotesDrawerState();
}

class _NotesDrawerState extends State<NotesDrawer> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: colorScheme.tertiary,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
            ),
            accountName: Text(
              user?.displayName ?? 'Guest',
              style: TextStyle(
                  color: colorScheme.onPrimary, fontWeight: FontWeight.w400),
            ),
            accountEmail: Text(
              user?.email ?? 'No email availabe',
              style: TextStyle(
                  color: colorScheme.onPrimary, fontWeight: FontWeight.w400),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: colorScheme.onSecondary,
              radius: 30,
              child: Icon(
                Icons.person,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          Divider(
            color: colorScheme.onSurface,
            thickness: 1,
            height: 1,
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: colorScheme.onPrimary,
            ),
            title: Text(
              'Home',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: colorScheme.onPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.star,
              color: colorScheme.onPrimary,
            ),
            title: Text(
              'Favourites',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: colorScheme.onPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Favorites()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: colorScheme.onPrimary),
            title: Text(
              'Settings',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: colorScheme.onPrimary),
            ),
            onTap: () {
              Navigator.pop(
                  context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: colorScheme.onPrimary,
            ),
            title: Text(
              'LogOut',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: colorScheme.onPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              AuthMethods().signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (ctx) => LoginScreen()));
            },
          )
        ],
      ),
    );
  }
}
