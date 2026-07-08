import 'package:daily_notes_app/providers/theme_provider.dart';
import 'package:daily_notes_app/screens/auth/login_screen.dart';
import 'package:daily_notes_app/services/auth_methods.dart';
import 'package:daily_notes_app/utils/utils.dart';
import 'package:daily_notes_app/widgets/round_button.dart';
import 'package:daily_notes_app/widgets/settings_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController userNameController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userNameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    userNameController.dispose();
    super.dispose();
  }

  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: scheme.onPrimary,
            )),
        title: Text(
          'Settings',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: scheme.onPrimaryContainer,
                    child: Icon(
                      Icons.person,
                      color: scheme.onPrimary,
                      size: 30,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'PROFILE',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: scheme.onPrimary),
              ),
              SizedBox(
                height: 10,
              ),
              SettingsTile(
                title: 'User Name',
                value: user?.displayName,
                trailingIcon: Icons.edit,
                topCard: true,
                onTap: _showEditDialoge,
              ),
              SizedBox(
                height: 2,
              ),
              SettingsTile(
                  bottomCard: true, title: 'Email', value: user?.email),
              SizedBox(
                height: 20,
              ),
              Text(
                'THEME MODE',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: scheme.onPrimary),
              ),
              SizedBox(
                height: 10,
              ),
              Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
                final current = themeProvider.themeMode;
                return Column(
                  children: [
                    SettingsTile(
                      title: 'Light Mode',
                      trailingIcon: current == ThemeMode.light
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      topCard: true,
                      onTap: () => themeProvider.setTheme(ThemeMode.light),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    SettingsTile(
                      title: 'Dark Mode',
                      trailingIcon: current == ThemeMode.dark
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      onTap: () => themeProvider.setTheme(ThemeMode.dark),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    SettingsTile(
                        bottomCard: true,
                        title: 'System',
                        onTap: () => themeProvider.setTheme(ThemeMode.system),
                        trailingIcon: current == ThemeMode.system
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off),
                  ],
                );
              }),
              SizedBox(
                height: 20,
              ),
              Text(
                'LOGOUT',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: scheme.onPrimary),
              ),
              SizedBox(
                height: 10,
              ),
              RoundButton(
                btnText: 'Logout',
                color: Colors.red,
                onTap: () {
                  _showLogoutDialog(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialoge() {
    final scheme = Theme.of(context).colorScheme;
    return showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                return AlertDialog(
                  title: Text(
                    'Edit User Name',
                    style: TextStyle(color: scheme.onPrimary),
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: userNameController,
                          style: TextStyle(color: scheme.onPrimary),
                          cursorColor: scheme.onPrimary,
                          decoration: InputDecoration(
                              labelText: 'User Name',
                              hintText: 'User Name',
                              labelStyle: TextStyle(color: scheme.onPrimary),
                              prefixIcon: const Icon(Icons.person),
                              prefixIconColor: scheme.onPrimary,
                              filled: true,
                              fillColor: scheme.surface,
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: scheme.onSurface)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: scheme.onSurface))),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: scheme.onPrimary),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: () async {
                        setDialogState(
                            () => isLoading = true);
                        try {
                          await FirebaseAuth.instance.currentUser!
                              .updateDisplayName(
                                  userNameController.text.trim());
                          if (mounted) {
                            Navigator.pop(dialogContext);
                            Utils().showToast('User name updated!');
                            setState(
                                () {});
                          }
                        } catch (error) {
                          if (mounted) {
                            Utils().showToast('Error updating user name: $error');
                          }
                        } finally {
                          setDialogState(() => isLoading = false);
                        }
                      },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Update',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            ));
  }

  void _showLogoutDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: Text(
                'Logout',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to logout?',
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
                      AuthMethods().signOut();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (ctx) => LoginScreen()));
                      Utils().showToast('Logged out!');
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ));
  }
}
