import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/sign_up.dart';
import 'package:gamers_kingdom/widgets/gmk_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool checkValue = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(.2),
              offset: const Offset(0,0),
              blurRadius: 5,
              spreadRadius: 1
            )
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "Log In",
                style: Theme.of(context).textTheme.titleLarge
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GmkTextField(
                controller: emailController,
                title: "Mail address", 
                onChanged: (value){
                  setState(() {
                    emailController.text = value;
                  });
                },
                validator: (value){
                  if(value!.isEmpty){
                    return "Mail address required";
                  }
                  if(!EmailValidator.validate(value)){
                    return "Bad mail address syntax";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GmkTextField(
                maxLines: 1,
                controller: passwordController,
                title: "Password",
                obscure: true,
                onChanged: (value){
                  setState(() {
                    passwordController.text = value;
                  });
                },
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Password required";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: checkValue, 
                        onChanged: (value){
                          setState(() {
                            checkValue = !checkValue;
                          });
                        }
                      ),
                      Text(
                        "Remember me",
                        style: Theme.of(context).textTheme.displaySmall,
                      )
                    ],
                  ),
                  Text(
                    "Forgot password ?",
                    style: Theme.of(context).textTheme.labelSmall
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if(formKey.currentState!.validate()){
                    formKey.currentState!.save();
                    if(!mounted)return;
                    try{
                      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
                    } on FirebaseAuthException catch (_) {
                      await PopUp.okPopUp(
                        context: context,
                        title: "Something went wrong",
                        message: "This account does not exist or the password is invalid",
                      );
                    }
                  }
                }, 
                child: const Text(
                  "Login",
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                onPressed: (){
                  Navigator.of(context).pushNamed(SignUp.routeName);
                }, 
                child: const Text(
                  "No account ?",
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}