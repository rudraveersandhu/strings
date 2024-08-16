import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bottom_player.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final model = context.read<BottomPlayerModel>();
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

            ),
          ),
        );
      },
    );
  }
}
