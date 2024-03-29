

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:gamers_kingdom/enums/gender.dart';
import 'package:gamers_kingdom/enums/skills.dart';
import 'package:gamers_kingdom/extensions/string_extension.dart';
import 'package:gamers_kingdom/pop_up/pop_up.dart';
import 'package:gamers_kingdom/widgets/gmk_textfield.dart';
import 'package:gamers_kingdom/widgets/progress_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:url_launcher/url_launcher.dart';

enum AuthProblems { userNotFound, passwordNotValid, networkError }

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  static String routeName = "/SignUp";
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with AutomaticKeepAliveClientMixin  {
  @override
  bool get wantKeepAlive => true;

  PageController pageController = PageController(initialPage:0);
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseFirestore fbf = FirebaseFirestore.instance;
  late AuthProblems errorType;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double position = 0;
  bool eulaAccepted = false;
  // Page View 0
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController= TextEditingController();
  Gender gender = Gender.male;

  // Page View 1
  TextEditingController pseudoController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  List<String> skills = List.generate(Skills.values.length, (index) => Skills.values[index].name.capitalize());
  List<String> selectedSkills = [];
  late final List<MultiSelectItem<String>> items;

  @override
  void initState() {
    super.initState();
    items = skills
      .map((skill) => MultiSelectItem<String>(skill, skill))
      .toList();
  }

  String getTextByIndex(){
    if(pageController.page == 0){
      return "Next";
    } else {
      return "Register";
    }
  }

  Future alertPopUp({required String title, required String message, List<Widget>? actions}) {
    return showPlatformDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint(nameController.text);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Registration"),
      ),
      persistentFooterButtons:[
        (!isLoading)?
        FutureBuilder(
          future: Future.value(true),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return (!isLoading)?
            Column(
              children: [
                if(position == 1)
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Checkbox(
                        value: eulaAccepted, 
                        onChanged: ((value) => setState(() {
                          eulaAccepted = value!;
                        })),
                      ),
                    ),
                    Flexible(
                      flex: 8,
                      child: GestureDetector(
                        onTap: () async {
                          const url = 'https://gamerskingdoms.com/mention/';
                          // launch url here
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Text(
                          "By clicking on the register button, you agree to our terms of use and our privacy policy", 
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600],
                            decoration: TextDecoration.underline
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      debugPrint("Tapped");
                      if(!eulaAccepted){
                        PopUp.okPopUp(
                          context: _scaffoldKey.currentContext!,
                          title: "Something went wrong", 
                          message: "You must accept the terms of use and the privacy policy"
                        );
                      } else {
                        if(formKey.currentState!.validate()){
                          formKey.currentState!.save();
                          debugPrint(selectedSkills.toString());
                          if(pageController.page == 1){
                            setState(() {
                              isLoading = true;
                            });
                            try{
                              UserCredential? userC;
                              if(FirebaseAuth.instance.currentUser == null){
                                debugPrint("Creating user");
                                userC = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: emailController.text, 
                                  password: passwordController.text,
                                );
                              }
                              AggregateQuerySnapshot aq = await fbf.collection("users")
                                .where("displayName",isEqualTo: pseudoController.text.toLowerCase().trim())
                                .count()
                                .get();
                              if(aq.count > 0){
                                debugPrint("Found user already existing");
                                PopUp.okPopUp(
                                  context: _scaffoldKey.currentContext!,
                                  title: "Something went wrong", 
                                  message: "An account with this username already exist"
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                debugPrint("Creating user in firestore");
                                await fbf.collection("users").add(
                                  {
                                    "email":emailController.text.toLowerCase().trim(),
                                    "name": nameController.text.toLowerCase().trim(),
                                    "surname": surnameController.text.toLowerCase().trim(),
                                    "displayName": pseudoController.text.toLowerCase().trim(),
                                    "bio": bioController.text,
                                    "skills": selectedSkills
                                  }
                                );
                                if(userC != null){
                                  await userC.user!.sendEmailVerification();
                                }
                                await FirebaseAuth.instance.signOut();
                                debugPrint("Sign out");
                                if(!mounted)return;
                                await PopUp.okPopUp(
                                  context: _scaffoldKey.currentContext!,
                                  title: "Done", 
                                  message: "Your registration has been done, please go to your mails and click the confirmation link."
                                );
                                if(!mounted)return;
                                Navigator.of(_scaffoldKey.currentContext!).pop();
                              }
                            } on FirebaseAuthException catch (e) {
                              debugPrint("Caught exception");
                              setState(() {
                                isLoading = false;
                              });
                              debugPrint(e.code.toString());
                              switch (e.code) {
                                case 'email-already-in-use':
                                  debugPrint("Here");
                                  await PopUp.okPopUp(
                                    context: _scaffoldKey.currentContext!,
                                    title: "Something went wrong",
                                    message: "An account with this email already exists",
                                  );
                                  pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                                  break;
                                case 'weak-password':
                                  await PopUp.okPopUp(
                                    context: _scaffoldKey.currentContext!,
                                    title: "Something went wrong",
                                    message: "Password too weak",
                                  );
                                  pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                                  break;
                                default:
                                  await PopUp.okPopUp(
                                    context: _scaffoldKey.currentContext!,
                                    title: "Something went wrong",
                                    message: "Something went wrong, please try again later",
                                  );
                                  Navigator.of(context).pop();
                                }
                            }
                          } else {
                            if(!mounted)return;
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 500), 
                              curve: Curves.easeIn
                            );
                          }
                        }
                      }
                    }, 
                    child: Text(
                      getTextByIndex(),
                    )
                  ),
                ),
              ],
            ):
            const Center(child: ProgressWidget());
          }
        ):
        const Center(child: ProgressWidget())
      ],
      body: Form(
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
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4.0),
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (value){
              debugPrint("Page : ${value.toString()}");
              setState(() {
                position = value.toDouble();
                debugPrint("Position value : $position");
              });
            },
            controller: pageController,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "These informations will allow you to connect to your member area and access Gamers Kingdoms services.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GmkTextField(
                          textInputAction: TextInputAction.next,
                          controller: nameController,
                          title: "Name", 
                          onSaved: (value){
                            setState(() {
                              nameController.text = value!;
                            });
                          },
                          onChanged: (value){},
                          validator: (value){
                            if(value!.isEmpty){
                              return "Name required";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GmkTextField(
                          textInputAction: TextInputAction.next,
                          controller: surnameController,
                          title: "Surname", 
                          onChanged: (value){},
                          onSaved: (value){
                            setState(() {
                              surnameController.text = value!;
                            });
                          },                          
                          validator: (value){
                            if(value!.isEmpty){
                              return "Surname required";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GmkTextField(
                          textInputAction: TextInputAction.done,
                          textInputType: TextInputType.emailAddress,
                          controller: emailController,
                          title: "Mail address", 
                          onChanged: (value){},
                          onSaved: (value){
                            setState(() {
                              emailController.text = value!;
                            });
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return "Mail address required";
                            }
                            if(!EmailValidator.validate(value)){
                              return "Bad mail syntax";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GmkTextField(
                          textInputAction: TextInputAction.done,
                          textInputType: TextInputType.emailAddress,
                          controller: passwordController,
                          maxLines: 1,
                          title: "Password",
                          obscure: true,
                          onChanged: (value){},
                          onSaved: (value){
                            setState(() {
                              passwordController.text = value!;
                            });
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return "Password required";
                            }
                            if(value.length<6){
                              return "Password must have six minimal characters";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(bottom: 5, left: 12),
                              child: Text(
                                "Gender",
                                style: Theme.of(context).textTheme.headlineSmall,
                              )
                            ),
                            DropdownButton<Gender>(
                              isExpanded: true,
                              value: gender,
                              items: const [
                                DropdownMenuItem(
                                  value: Gender.male,
                                  child: Text("Male", style: TextStyle(color: Colors.black)),
                                ),
                                DropdownMenuItem(
                                  value: Gender.female,
                                  child: Text("Female", style: TextStyle(color: Colors.black)),
                                ),
                              ],
                              onChanged: (value){
                                setState(() {
                                  gender = value!;
                                });
                              }
                            ),
                          ],
                        ),
                      ),
                    ]
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Fill your Gamers Kingdom profile !",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GmkTextField(
                          controller: pseudoController,
                          title: "Username", 
                          onChanged: (value){},
                          onSaved: (value){
                            setState(() {
                              pseudoController.text = value!;
                            });
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return "Username is required";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: GmkTextField(
                          maxLines:5,
                          controller: bioController,
                          title: "Bio (optionnal)", 
                          onChanged: (value){},
                          onSaved: (value){
                            setState(() {
                              bioController.text = value!;
                            });
                          },
                          validator: (value){
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(bottom: 5, left: 12),
                              child: Text(
                                "Skills",
                                style: Theme.of(context).textTheme.headlineSmall,
                              )
                            ),
                            MultiSelectDialogField<String>(
                              items: items,
                              title: const Text("Skills"),
                              selectedColor: Colors.blue,
                              buttonIcon: const Icon(
                                Icons.manage_accounts,
                                color: Colors.blue,
                              ),
                              buttonText: Text(
                                "Choose your skills",
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 16,
                                ),
                              ),
                              onConfirm: (results) {
                                selectedSkills = results;
                              },
                            ),
                          ],
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}