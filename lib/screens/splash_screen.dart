import 'package:daily_notes_app/services/splash_services.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  splashServices splash= splashServices();
  @override
  void initState() {
    super.initState();
    splash.splash(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              radius: 80,
              backgroundImage: AssetImage('assets/images/to_do.jpg'),
            ),
            SizedBox(height: 20,),
            Text('Daily Notes App', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
            ),
            SizedBox(height: 20,),
          ],
        ),
      )
    );
  }
}