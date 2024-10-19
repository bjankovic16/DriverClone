import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:project_udemy_app/auth/singup_page.dart';
import 'package:project_udemy_app/global.dart';
import 'package:project_udemy_app/pages/map_page.dart';

import '../widgets/loading_dialog.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateSignInForm() {
    if(!emailTextEditingController.text.contains("@")) {
      associateMethods.showSnackBarMsg("email is not valid", context);
    } else if(passwordTextEditingController.text.trim().length < 5) {
      associateMethods.showSnackBarMsg("password must be at least 5 or more characters", context);
    } else {
      signInUserNow();
    }
  }

  signInUserNow() async {
    showDialog(context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "Checking credentials")
    );
    try {
      final User? firebaseUser = (
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim()
          ).catchError((onError) {
            Navigator.pop(context);
            associateMethods.showSnackBarMsg(onError.toString(), context);
          })
      ).user;
      if (firebaseUser != null) {
        DatabaseReference ref = FirebaseDatabase.instance.ref().child("users").child(firebaseUser.uid);
        await ref.once().then((dataSnapshot) {
          if(dataSnapshot.snapshot.value != null) {
            if ((dataSnapshot.snapshot.value as Map)["blockStatus"] == "no") {
              userName = (dataSnapshot.snapshot.value as Map)["name"];
              userPhone = (dataSnapshot.snapshot.value as Map)["phone"];
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => const MapPage()));
            } else {
              FirebaseAuth.instance.signOut();
              associateMethods.showSnackBarMsg(
                  "Error your status is blocked", context);
            }
          } else {
            FirebaseAuth.instance.signOut();
            associateMethods.showSnackBarMsg(
                "Your record doesn't exist", context);
          }
        });
      }
    }  on FirebaseAuthException catch(e){
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      associateMethods.showSnackBarMsg(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const SizedBox(height: 122,),
                Image.asset(
                  "assets/signin.webp",
                  width: MediaQuery.of(context).size.width * .7,
                ),
                const SizedBox(height: 10,),

                const Text(
                  "Login as user",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold
                  ),
                ),

                Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailTextEditingController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "user Email",
                            labelStyle: const TextStyle(fontSize: 14)
                          ),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15
                          ),
                        ),

                        const SizedBox(height: 22,),

                        TextField(
                          controller: passwordTextEditingController,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              labelText: "user Password",
                              labelStyle: TextStyle(fontSize: 14)
                          ),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15
                          ),
                        ),

                        const SizedBox(height: 32,),
                        
                        ElevatedButton(
                          onPressed: () {
                            validateSignInForm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                          ),
                          child: Text("Login", style: TextStyle(color: Colors.white),),
                        ),

                        const SizedBox(height: 12,),

                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c)=>SingupPage()));
                          },
                          child: const Text(
                            "Don't have an account? Sing up here",
                            style: TextStyle(
                              color: Colors.grey,
                            )
                          ),
                        ),

                      ],
                    )
                ),
              ],
            )
        )
      )
    );
  }
}