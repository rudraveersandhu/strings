import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/SignUp.dart';
import 'auth/options.dart';
import 'main_screens/main_screen.dart';
import 'models/user_model.dart';

class Introscreen extends StatefulWidget {
  const Introscreen({super.key});

  @override
  State<Introscreen> createState() => _IntroscreenState();
}

class _IntroscreenState extends State<Introscreen> {

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.deepPurple.withOpacity(.8),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Image.asset('assets/vervesplash.png',
                fit: BoxFit.cover,),
            ),
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height/2,

                ),
                Container(
                  height: MediaQuery.of(context).size.height/2,
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
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width/1.1,
                        child: const Column(
                          children: [
                            Text(
                              'Enjoy the best music with us, without ads!',
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                            SizedBox(height: 15,),
                            Text(
                              'Listen anytime, free offline downloads, with best quality audio!',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w300
                              ),
                            ),
                            SizedBox(height: 40,),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (builder) => const Options()));
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width - 50,
                          decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: const Center(
                            child: Text(
                              'Get started',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                          ),
                        ),

                      ),
                      SizedBox(height: 30,),
                    ],
                  ),
                ),
              ],
            )

          ],
        )
    );
  }
}
