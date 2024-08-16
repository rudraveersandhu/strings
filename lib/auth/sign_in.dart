import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strings/main_screens/main_screen.dart';

import '../models/user_model.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController email = TextEditingController();
  TextEditingController pass1 = TextEditingController();
  bool showPass = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.deepPurple.withOpacity(.8),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Image.asset('assets/options.jpeg',
                fit: BoxFit.cover,),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                SizedBox(
                  //width: MediaQuery.of(context).size.width/1.1,
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/2-50,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: AlignmentDirectional.topEnd,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(.7),
                                  Colors.black.withOpacity(.93),
                                  //Colors.black,
                                ])
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'Enter the world of music, with quality at your fingertips',
                                style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                            SizedBox(height: 15,),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'Listen anytime, free offline downloads, with best quality audio!',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                            ),
                            SizedBox(height: 30,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 100,),
            Positioned(
              top: 100,
              child: BlurryContainer(
                borderRadius: BorderRadius.circular(0),
                height: 50,
                width: MediaQuery.of(context).size.width,
                blur: 30,
                child: Center(
                  child: Text('Welcome back Insider',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150,

              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,


                      decoration: BoxDecoration(

                        //color: Colors.black54,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text("Strings",style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800
                          ),),
                          SizedBox(height: 40,),
                          BlurryContainer(
                            blur: 30,
                            width: MediaQuery.of(context).size.width - 50,
                            height: 50,
                            elevation: 0,
                            color: Colors.transparent,
                            padding: EdgeInsets.all(0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: TextField(
                              controller: email,
                              style: TextStyle(
                                  color: Colors.white
                              ),
                              decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.white54),
                                  icon: Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Icon(CupertinoIcons.at),
                                  ),
                                  border: InputBorder.none
                              ),
                              onChanged: (value){
                                email.text = value;
                              },
                            ),

                          ),
                          SizedBox(height: 20,),
                          BlurryContainer(
                            blur: 30,
                            width: MediaQuery.of(context).size.width - 50,
                            height: 50,
                            elevation: 0,
                            color: Colors.transparent,
                            padding: EdgeInsets.all(0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: TextField(
                              controller: pass1,
                              style: TextStyle(
                                  color: Colors.white
                              ),
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: TextStyle(color: Colors.white54),
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Icon(CupertinoIcons.padlock_solid),
                                ),
                                border: InputBorder.none,
                                suffixIcon: showPass ? GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        showPass = false;
                                      });
                                    },
                                    child: Icon(CupertinoIcons.eye,color: Colors.white,)) :
                                GestureDetector(
                                    onTap:(){
                                      setState(() {
                                        showPass = true;
                                      });
                                    },
                                    child: Icon(CupertinoIcons.eye_slash,color: Colors.white,)),
                              ),
                              obscureText: !showPass,
                              onChanged: (value){
                                pass1.text = value;
                              },
                            ),
                          ),
                          SizedBox(height: 50,),
                          GestureDetector(
                            onTap: (){
                              signIn();
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width - 200,
                              decoration: BoxDecoration(
                                  color: Colors.purple.shade400,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Center(
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40,),


                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }
  void _showLoadingDialog() {
    showDialog(
      barrierColor: Colors.black.withOpacity(.65),
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: BlurryContainer(
            blur: 15,
            height: 300,
            width: 300,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white,),
                SizedBox(height: 20),
                Text('Signing you up...',style: TextStyle(
                    color: Colors.white
                ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.text,
        password: pass1.text,
      );
      print("User signed in: ${userCredential.user?.email}");
      _getUserInfo();
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _getUserInfo() async {
    final model = context.read<UserModel>();
    final user = FirebaseAuth.instance.currentUser;

    try{
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        model.id = userData['id'];
        model.name = userData['name'];
        model.profilePicture = userData['profile_pic'];
        model.email = userData['email'];
        model.pass = userData['password'];
        model.number = userData['phone'];
        model.joinedOn = userData['joined_on'];

      } else {
        print('user is null');
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
    }catch(e){
      print('error: $e');
    }
  }
}
