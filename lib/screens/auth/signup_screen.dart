import 'package:daily_notes_app/screens/home_screen.dart';
import 'package:daily_notes_app/services/auth_methods.dart';
import 'package:daily_notes_app/utils/utils.dart';
import 'package:daily_notes_app/widgets/input_field.dart';
import 'package:daily_notes_app/widgets/round_button.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final emailController= TextEditingController();
  final passwordController= TextEditingController();
  final confirmPasswordController= TextEditingController();
  final nameController= TextEditingController();
  bool isLoading= false;
  final formKey= GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          margin: EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputField(
                  hintText: 'Enter userName', 
                  labelText: 'User Name', 
                  controller: nameController, 
                  keyboardType: TextInputType.text, 
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if(value!.isEmpty){
                      return 'This field can\'t be empty';
                    }
                    return null;
                  },
                  ),
                  SizedBox(height: 10),
                  InputField(
                  hintText: 'Enter your Email', 
                  labelText: 'Email', 
                  controller: emailController, 
                  keyboardType: TextInputType.emailAddress, 
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if(value!.isEmpty){
                      return 'This field can\'t be empty';
                    }
                    return null;
                  },
                  ),
                  SizedBox(height: 10),
                  InputField(
                  hintText: 'Enter Password Here', 
                  labelText: 'Password', 
                  controller: passwordController, 
                  keyboardType: TextInputType.text, 
                  prefixIcon: Icons.lock,
                  obsecureText: true,
                  validator: (value) {
                    if(value!.isEmpty){
                      return 'This field can\'t be empty';
                    }
                    return null;
                  },
                  ),
                  SizedBox(height: 10),
                  InputField(
                  hintText: 'Confirm Password', 
                  labelText: 'Re-Type password', 
                  controller: confirmPasswordController, 
                  keyboardType: TextInputType.text, 
                  prefixIcon: Icons.lock,
                  obsecureText: true,
                  validator: (value) {
                    if(value!.isEmpty){
                      return 'This field can\'t be empty';
                    }
                    return null;
                  },
                  ),
                  SizedBox(height: 15),
                  RoundButton(
                    onTap: (){
                      if(formKey.currentState!.validate()){
                      setState(() {
                        isLoading= true;
                      });
                    if(passwordController.text == confirmPasswordController.text){
                       AuthMethods().signUp(emailController: emailController, passwordController: passwordController, nameController: nameController).then((value){
                        Utils().showToast('user Created Successfully');
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=>HomeScreen()));
                        setState(() {
                          isLoading= false;
                        });
                        
                      }).onError((error, StackTrace){
                        Utils().showToast(error.toString());
                        setState(() {
                          isLoading= false;
                        });
                      });
                    }else{
                      Utils().showToast('Password does not match');
                      setState(() {
                        isLoading= false;
                      });
                    }
                    }
                    },
                  btnText: 'Signup',
                  isLoading: isLoading,
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Text('Already have an account?', style: TextStyle(color: scheme.onSecondary),),
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: Text('Login', style: TextStyle(color: scheme.onPrimary),)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      )
    );
  }
}