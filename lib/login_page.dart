import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
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
                "Connectez-vous",
                style: Theme.of(context).textTheme.titleLarge
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GmkTextField(
                controller: emailController,
                title: "Adresse e-mail", 
                onChanged: (value){
                  setState(() {
                    emailController.text = value;
                  });
                },
                validator: (value){
                  if(value!.isEmpty){
                    return "E-mail requis";
                  }
                  if(!EmailValidator.validate(value)){
                    return "Format d'e-mail incorrect";
                  }
                  if(emailController.text != "president17@gmail.com"){
                    return "Utilisateur inconnu";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GmkTextField(
                controller: passwordController,
                title: "Mot de passe",
                obscure: true,
                onChanged: (value){
                  setState(() {
                    passwordController.text = value;
                  });
                },
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Mot de passe requis";
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
                        "Se souvenir de moi",
                        style: Theme.of(context).textTheme.displaySmall,
                      )
                    ],
                  ),
                  Text(
                    "Mot de passe oublié ?",
                    style: Theme.of(context).textTheme.labelSmall
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  debugPrint("Tapped");
                  if(formKey.currentState!.validate()){
                    formKey.currentState!.save();
                    if(!mounted)return;
                  }
                }, 
                child: const Text(
                  "Se connecter",
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                onPressed: (){
                }, 
                child: const Text(
                  "Vous n'avez pas de compte ?",
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}