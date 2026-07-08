import 'package:daily_notes_app/screens/home_screen.dart';
import 'package:daily_notes_app/screens/auth/signup_screen.dart';
import 'package:daily_notes_app/services/auth_methods.dart';
import 'package:daily_notes_app/utils/utils.dart';
import 'package:daily_notes_app/widgets/input_field.dart';
import 'package:daily_notes_app/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController= TextEditingController();
  final passwordController= TextEditingController();
  bool isLoading= false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          margin: EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              InputField(
              hintText: 'Enter Email', 
              labelText: 'Email', 
              controller: emailController, 
              keyboardType: TextInputType.emailAddress, 
              prefixIcon: Icons.email
              ),
              SizedBox(height: 15),
              InputField(
              hintText: 'Enter Password Here', 
              labelText: 'Password', 
              controller: passwordController, 
              keyboardType: TextInputType.text, 
              prefixIcon: Icons.lock,
              obsecureText: true,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                onPressed: (){
                  
                },
                child: Text('Forgot Password?'),
              ),
              ),
              RoundButton(
                onTap: (){
                  setState(() {
                  isLoading=true;
                });
                AuthMethods().signIn(emailController: emailController, passwordController: passwordController).then((value){
                  Utils().showToast('signed in as ${emailController.text}');
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=>HomeScreen()));
                  setState(() {
                    isLoading=false;
                  });
                }).onError((error, StackTrace){
                  Utils().showToast(error.toString());
                  setState(() {
                    isLoading=false;
                  });
                });
                },
              btnText: 'Login', 
              isLoading: isLoading,
              ),
              Row(
                children: [
                  Text('Doesn\'t have an account?', style: TextStyle(color: scheme.onSecondary),),
                  TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      enableFeedback: false
                    ),
                    onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (ctx)=>SignupScreen()));
                  }, child: Text('SignUp', style: TextStyle(color: scheme.onPrimary),)
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){},
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: SvgPicture.asset('assets/images/google.svg'),
                    ),
                  ),
                  SizedBox(width: 40),
                  InkWell(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: SvgPicture.asset('assets/images/gmail.svg'),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}