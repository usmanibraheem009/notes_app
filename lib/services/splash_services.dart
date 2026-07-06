import 'package:daily_notes_app/screens/home_screen.dart';
import 'package:daily_notes_app/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class splashServices{

  Future<void> splash(context)async{

    Future.delayed(Duration(seconds: 2), (){

      final auth= FirebaseAuth.instance;
      final user= auth.currentUser;

      if(user!=null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=>HomeScreen()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=>LoginScreen()));
      }
    });
  }
}