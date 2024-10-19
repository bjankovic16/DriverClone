import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:project_udemy_app/auth/signin_page.dart';
import 'package:project_udemy_app/global.dart';
import 'package:project_udemy_app/widgets/loading_dialog.dart';

import '../pages/map_page.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({super.key});

  @override
  State<SingupPage> createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();

  validateSingUpForm() {
    if(userNameTextEditingController.text.trim().length < 3) {
      associateMethods.showSnackBarMsg("name must be at least 3 or more characters", context);
    } else if(userPhoneTextEditingController.text.trim().length < 7) {
      associateMethods.showSnackBarMsg("phone number must be at least 7 or more characters", context);
    } else if(!emailTextEditingController.text.contains("@")) {
      associateMethods.showSnackBarMsg("email is not valid", context);
    } else if(passwordTextEditingController.text.trim().length < 5) {
      associateMethods.showSnackBarMsg("password must be at least 5 or more characters", context);
    } else {
      singUserNow();
    }
  }

  singUserNow() async{

    showDialog(context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "Checking credentials")
    );

    try {
      final User? firebaseUser = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim()
        ).catchError((onError) {
          Navigator.pop(context);
          associateMethods.showSnackBarMsg(onError.toString(), context);
        })
      ).user;

      Map userDataMap = {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": firebaseUser!.uid,
        "blockStatus": "no"
      };
      FirebaseDatabase.instance.ref().child("users").child(firebaseUser!.uid).set(userDataMap);
      Navigator.pop(context);
      associateMethods.showSnackBarMsg("Account created successfully", context);
      Navigator.push(context, MaterialPageRoute(builder: (c) => const MapPage()));
    } on FirebaseAuthException catch(e){
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
                      "assets/signup.webp",
                      width: MediaQuery.of(context).size.width * .5,
                    ),
                    const SizedBox(height: 10,),

                    const Text(
                      "Register new acount",
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
                              controller: userNameTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "user name",
                                  labelStyle: const TextStyle(fontSize: 14)
                              ),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15
                              ),
                            ),

                            const SizedBox(height: 22,),
                            TextField(
                              controller: userPhoneTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "user phone",
                                  labelStyle: const TextStyle(fontSize: 14)
                              ),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15
                              ),
                            ),

                            const SizedBox(height: 22,),

                            TextField(
                              controller: emailTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "user email",
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
                                  labelText: "user password",
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
                                validateSingUpForm();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10)
                              ),
                              child: Text("Sing up", style: TextStyle(color: Colors.white),),
                            ),

                            const SizedBox(height: 12,),

                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (c)=>SigninPage()));
                              },
                              child: const Text(
                                  "Already have an account? Login here",
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
