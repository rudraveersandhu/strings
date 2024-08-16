import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../main_screens/main_screen.dart';
import '../main_screens/home_screen.dart';
import '../models/user_model.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass1 = TextEditingController();
  TextEditingController pass2 = TextEditingController();
  TextEditingController cnCode = TextEditingController();
  final TextEditingController phone = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool showPass = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.deepPurple.withOpacity(.8),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Image.asset('assets/vervesplash1.jpg',
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
                              child: const Text(
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
                              child: const Text(
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
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 100,),
                      Center(
                          child: Text('Lets make you an Insider',
                            style: TextStyle(
                                color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      BlurryContainer(
                        blur: 30,
                        width: MediaQuery.of(context).size.width - 50,
                        height: 50,
                        elevation: 0,
                        color: Colors.transparent,
                        padding: EdgeInsets.all(0),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: TextField(
                          controller: name,
                          style: TextStyle(
                            color: Colors.white
                          ),
                          decoration: InputDecoration(
                              hintText: "Name",
                              hintStyle: TextStyle(color: Colors.white54),
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Icon(CupertinoIcons.person),
                            ),
                            border: InputBorder.none
                          ),
                          onChanged: (value){
                            name.text = value;
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
                          controller: pass2,
                          style: TextStyle(
                              color: Colors.white
                          ),
                          decoration: InputDecoration(
                              hintText: "Confirm passowrd",
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
                            pass2.text = value;
                          },
                        ),
                      ),
                      SizedBox(height: 70,),

                      GestureDetector(
                        onTap: (){

                          _signup();
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width - 200,
                          decoration: BoxDecoration(
                              color: Color(0xFF8A56AC),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: const Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ),
                        ),
                      ),


                    ],
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

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  checkPass(){
    bool passcheck = pass1.text == pass2.text;
    return passcheck;
  }

  Future<void> _signup() async {
    final model = context.read<UserModel>();
    if (checkPass()){
      _showLoadingDialog();
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: pass1.text.trim(),
        );
        User? user = _auth.currentUser;
        DateTime now = DateTime.now();
        Timestamp x = Timestamp.fromDate(now);
        print("timestamp: $x");

        await _firestore.collection('users').doc(user?.uid).set({
          'id' : user?.uid,
          'name': name.text.trim(),
          'phone': phone.text.trim(),
          'email': email.text.trim(),
          'password': hashPassword(pass1.text.trim()),
          'blogs' : [],
          'profile_pic' : 'https://firebasestorage.googleapis.com/v0/b/beam-care.appspot.com/o/placeholder.png?alt=media&token=1244b6ef-2cdf-459e-9c1c-d6d5aa1978dc',
          'joined_on' : x
        }).then((onValue){
          model.id = user!.uid;
          model.name = name.text.trim();
          model.profilePicture = 'https://firebasestorage.googleapis.com/v0/b/beam-care.appspot.com/o/placeholder.png?alt=media&token=1244b6ef-2cdf-459e-9c1c-d6d5aa1978dc';
          model.email = email.text.trim();
          //model.pass = hashPassword(_passwordController.text.trim());
          //model.number = _phoneController.text.trim();
          model.joinedOn = x;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up Successful'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error saving user details to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup()));
      }
    } else {
      print('Password do not match');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password mismatch!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    //final model = context.read<UserModel>();
  }
}
