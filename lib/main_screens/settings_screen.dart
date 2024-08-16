import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strings/introScreen.dart';

import '../models/bottom_player.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomPlayerModel>(
      builder: (context, model, child) {
        return Material(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300), // Duration of the animation
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  model.cardBackgroundColor,
                  Colors.black,
                  Colors.black
                ],
              ),
            ),
            child: Container(
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => Introscreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}