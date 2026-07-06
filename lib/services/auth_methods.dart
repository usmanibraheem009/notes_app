import 'package:daily_notes_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {

  final _auth= FirebaseAuth.instance;
  bool isLoading=false;

  Future<void> signUp({
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController nameController
  }) async{
    await _auth.createUserWithEmailAndPassword(
      email: emailController.text, 
      password: passwordController.text,
      
      ).then((UserCredential){
        UserCredential.user?.updateDisplayName(nameController.text);
      });
  }

  Future<void> signIn({
    required TextEditingController emailController,
    required TextEditingController passwordController
  })async{
    await _auth.signInWithEmailAndPassword(
      email: emailController.text, 
      password: passwordController.text
      );
  }

  Future<void> signOut()async{
    await _auth.signOut();
  }

  Future<void> googleSignIn(context) async{
    GoogleSignInAccount? user= await GoogleSignIn().signIn();
    GoogleSignInAuthentication? gAuth= await user!.authentication;
    AuthCredential credential= GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    UserCredential userCredential= await _auth.signInWithCredential(credential);
    if(userCredential.user!=null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=>HomeScreen()));
    }
  }
}