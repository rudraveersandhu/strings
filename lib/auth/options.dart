import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:strings/auth/SignUp.dart';
import 'package:strings/auth/sign_in.dart';

class Options extends StatefulWidget {
  const Options({super.key});

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.deepPurple.withOpacity(.8),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Image.asset('assets/vervesplash3.jpg',
                fit: BoxFit.cover,),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                SizedBox(
                  height: MediaQuery.of(context).size.height/1.8,
                  //width: MediaQuery.of(context).size.width/1.1,
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/1.8,
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
                        bottom: 60,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [

                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'The Best Music Collection for every mood !',
                                style: TextStyle(

                                    fontSize: 28,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 30,),
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (builder) => const SignIn()));
                              },
                              child: Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width - 300,
                                decoration: BoxDecoration(
                                    color: Colors.purple.shade300,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child:  Center(
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text("or",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700
                              ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (builder) => const Signup()));
                              },
                              child: Container(

                                height: 50,
                                width: MediaQuery.of(context).size.width - 100,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child:  const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: Icon(Icons.mail_lock_outlined),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 100.0),
                                        child: Text(
                                          'Sign Up for free',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,

                                          ),

                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(

                              height: 50,
                              width: MediaQuery.of(context).size.width - 100,
                              decoration: BoxDecoration(
                                  color: Colors.purple.shade300,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child:  Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      child: Icon(
                                        FontAwesomeIcons.google,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 80.0),
                                      child: Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(

                              height: 50,
                              width: MediaQuery.of(context).size.width - 100,
                              decoration: BoxDecoration(
                                  color: Colors.purple.shade300,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child:  const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: Icon(
                                        FontAwesomeIcons.facebook,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 80.0),
                                      child: Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(

                              height: 50,
                              width: MediaQuery.of(context).size.width - 100,
                              decoration: BoxDecoration(
                                  color: Colors.purple.shade300,
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child:  Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      child: Icon(
                                        FontAwesomeIcons.apple,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 80.0),
                                      child: Text(
                                        'Continue with Apple',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),



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
                        child: Text('Strings',
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

                      SizedBox(height: 70,),




                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }
}
