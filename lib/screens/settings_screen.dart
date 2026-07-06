import 'package:daily_notes_app/providers/theme_provider.dart';
import 'package:daily_notes_app/screens/auth/login_screen.dart';
import 'package:daily_notes_app/services/auth_methods.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            )),
        title: Text(
          'Settings',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.white),
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
                    backgroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
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
                'My Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              SettingsTile(
                title: 'User Name',
                value: user?.displayName,
                trailingIcon: Icons.chevron_right_rounded,
                topCard: true,
                onTap: _showEditDialoge,
              ),
              SizedBox(
                height: 2,
              ),
              SettingsTile(
                  bottomCard: true, title: 'Email', value: user?.email),
              SizedBox(
                height: 10,
              ),
              Text(
                'Select Mode',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                height: 10,
              ),
              Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              RoundButton(
                btnText: 'Logout',
                color: Colors.red,
                onTap: () {
                  AuthMethods().signOut();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) => LoginScreen()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialoge() {
    return showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                return AlertDialog(
                  title: const Text('Edit User Name'),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: userNameController,
                          decoration: InputDecoration(
                            labelText: 'User Name',
                            hintText: 'User Name',
                            prefixIcon: const Icon(Icons.person),
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () async {
                        setDialogState(
                            () => isLoading = true); // rebuilds the DIALOG now
                        try {
                          await FirebaseAuth.instance.currentUser!
                              .updateDisplayName(
                                  userNameController.text.trim());
                          if (mounted) {
                            setState(
                                () {}); // refresh the settings screen behind it
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('User name is updated')),
                            );
                          }
                        } catch (error) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Error updating user name: $error')),
                            );
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
}
