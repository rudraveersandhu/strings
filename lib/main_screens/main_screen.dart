import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import 'package:strings/players/bottomPlayer.dart';

import 'package:strings/players/expandedPlayer.dart';

import '../audio_handler/audio_player_handler.dart';
import '../main.dart';
import '../models/song_model.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';


class MainScreen extends StatefulWidget {

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;
  int _currentIndex = 0;
  double _sliderValue = 0.0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const SettingsScreen()
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Future<void> checkIfFavorite() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final model = context.read<SongModel>();

    try {
      QuerySnapshot existingTracks = await firestore.collection('users')
          .doc(userId)
          .collection('my_songs')
          .where('track_name', isEqualTo: model.title)
          .where('artist_name', isEqualTo: model.author)
          .get();

      setState(() {
        model.isFavorite = existingTracks.docs.isNotEmpty;
      });
      print("Heartttttttttttt Statusssssssss ${model.isFavorite }");
    } catch (e) {
      print('Error checking if favorite: $e');
    }
  }

  Future<void> _toggleExpansion() async {
    await checkIfFavorite();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      child: Consumer<SongModel>(
        builder: (context, model, child) {
          return Stack(
            children: [
              // Main content
              IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),

              // Mini player and full screen player
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  //onTap: model.isCardVisible ? _toggleExpansion : null,
                  onVerticalDragUpdate: (details){
                    if (details.primaryDelta! > 0) {
                      setState(() {
                        _toggleExpansion();
                      });
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          // Expanded Player
                          Container(
                            height: _animation.value > 0.0
                                ? _animation.value * (MediaQuery.of(context).size.height - 60) + 190
                                : _animation.value * (MediaQuery.of(context).size.height - 60) + kBottomNavigationBarHeight + 110,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15))
                            ),
                            child: Stack(
                              children: [
                                _animation.value > 0.0 ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  child: Image.network(
                                    model.tUrl, // Replace with your image URL
                                    fit: BoxFit.fitHeight,
                                  ),
                                ) : Container(),
                                _animation.value > 0.0 ? BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 50, sigmaY:50), // Adjust sigmaX and sigmaY for the blur intensity
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ) : Container(),
                                SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),

                                  child: Column(
                                    children: [
                                      // Mini player place holder
                                      Container(
                                        height: 130,
                                        //padding: const EdgeInsets.symmetric(horizontal: 16),
                                        // Your content for mini player placeholder
                                      ),

                                      // Full screen player (expanded content)
                                      Visibility(
                                        visible: true,
                                        child: Opacity(
                                          opacity: _animation.value,
                                          child: Expandedplayer(
                                            animation: _animation,
                                            // Additional properties as needed
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),   // Expanded Player

                          // Mini Player

                          Visibility(
                            visible: model.isCardVisible ? true : false,
                            child: Opacity(
                              opacity: 1-_animation.value,
                              child: GestureDetector(
                                onTap: model.isCardVisible ? _toggleExpansion : null,
                                child: SizedBox(
                                  height: 70,
                                  width: MediaQuery.of(context).size.width,
                                  child: const BottomPlayer(),
                                ),
                              ),
                            ),
                          ),
                              // Mini Player
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Bottom navigation bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation.value * 120),
                      child: child,
                    );
                  },
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                        backgroundColor: Colors.black,
                      ),
                    ),
                    child: BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: _onTabTapped,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Colors.purpleAccent,
                      unselectedItemColor: Colors.grey,
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      items: const [
                        BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
                        BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: 'Search'),
                        BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Your Library'),
                        BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildAlbumArt(String artUri, double size) {
    return Container(
      width: size,
      height: size,
      decoration: _buildBoxShadow(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(artUri),
          customSize: size == 55 ? Size(size+40, size+40) : Size(size+100, size+100),
          enableRotation: true,
          gaplessPlayback: true,
          backgroundDecoration: BoxDecoration(color: Theme.of(context).canvasColor),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxShadow() {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          spreadRadius: 2,
          blurRadius: 9,
          offset: Offset(2, 3),
        ),
      ],
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  Widget _buildSlider(MediaState mediaState, AudioHandler audioPlayerHandler) {

    // _mediaStateStream.listen((onData){
    //   print("${_sliderValue}/${onData.mediaItem?.duration?.inSeconds}");
    //   if(_sliderValue == onData.mediaItem?.duration?.inSeconds){
    //
    //     setState(() {
    //       _sliderValue = 0;
    //       audioHandler.seek(Duration(seconds: 0));
    //       audioHandler.pause();
    //       model.playing = false;
    //     });
    //
    //   }
    // });
    return GestureDetector(
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 0.1,
          activeTrackColor: Colors.white,
          thumbShape: SliderComponentShape.noThumb,
        ),
        child: Slider(
          inactiveColor: Colors.white54,
          value: _sliderValue <= mediaState.mediaItem!.duration!.inSeconds.toDouble() ? _sliderValue : 0,
          min: 0,
          max: mediaState.mediaItem!.duration!.inSeconds.toDouble(),
          onChanged: (value) {
            if (value < mediaState.mediaItem!.duration!.inSeconds.toDouble()) {
              setState(() {
                _sliderValue = value;
                audioHandler.seek(Duration(seconds: value.toInt()));
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMediaInfo(MediaState mediaState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(mediaState.mediaItem!.title,
          style: TextStyle(color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        Text(mediaState.mediaItem!.artist!, style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildPlayPauseButton(SongModel model, AudioHandler audioPlayerHandler) {
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 13),
      child: model.playing
          ? GestureDetector(
        onTap: () {
          model.playing = false;
          audioHandler.pause();
        },
        child: Icon(Icons.pause_circle_filled_rounded, size: 65.0, color: Colors.white),
      )
          : GestureDetector(
        onTap: () {
          model.playing = true;
          audioHandler.play();
        },
        child: Icon(Icons.play_circle_fill_rounded, size: 65.0, color: Colors.white),
      ),
    );
  }

  Color _buildInactiveSliderColor(SongModel model) {
    return model.accentColor
        .withRed(model.accentColor.red + 20)
        .withBlue(model.accentColor.blue + 20)
        .withGreen(model.accentColor.blue + 20);
  }

  BoxDecoration _buildDecoration(SongModel model) {
    return BoxDecoration(
      //color: model.cardBackgroundColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 15.0,
          spreadRadius: 2.8,
          offset: Offset(9, 7),
        ),
      ],
    );
  }

  Widget _buildPlaceholderPlayer(SongModel model, AudioHandler audioPlayerHandler) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      height: 70,
      width: MediaQuery.of(context).size.width * .985,
      decoration: _buildDecoration(model),
      child: Stack(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 75.0, bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 22.0),
                          child: MarqueeText(
                            text: TextSpan(
                              text: 'Unknown Song',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            speed: 12,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 22.0, top: 2.5),
                          child: MarqueeText(
                            text: TextSpan(
                              text: 'Unknown Artist',
                              style: TextStyle(color: Colors.white70),
                            ),
                            speed: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            trailing: _buildMiniPlayerPlayPauseButton(model, audioHandler),
          ),
          Positioned(
            top: 7,
            bottom: 7,
            left: 13,
            child: _buildAlbumArt('https://images.unsplash.com/photo-1598966737316-9ac16a385b22', 58),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderExpandedPlayer(SongModel model, AudioHandler audioPlayerHandler) {
    return GestureDetector(
      onVerticalDragUpdate: (details){
        if (details.primaryDelta! > 0) {
          _toggleExpansion();
        }
      },
      child: Stack(
        children: [
          Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 200,),

              _buildAlbumArt(model.tUrl, 300),
              SizedBox(height: 30),
              GestureDetector(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 0.1,
                    activeTrackColor: Colors.white,
                    thumbShape: SliderComponentShape.noThumb,
                  ),
                  child: Slider(
                    inactiveColor: _buildInactiveSliderColor(model),
                    value: _sliderValue <= audioHandler.mediaItem.value!.duration!.inSeconds.toDouble() ? _sliderValue : 0,
                    min: 0,
                    max: audioHandler.mediaItem.value!.duration!.inSeconds.toDouble(), onChanged: (double value) {  },

                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(model.title,
                    style: TextStyle(color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(model.author, style: TextStyle(color: Colors.white70)),
                ],
              ),
              _buildPlayPauseButton(model, audioPlayerHandler),
              SizedBox(height: 270,),


            ],
          ),


        ],
      ),
    );
  }

  Widget _buildMiniPlayer(MediaState mediaState, SongModel model, AudioPlayerHandler audioPlayerHandler) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      height: model.isCardVisible ? 70 : 0,
      width: MediaQuery.of(context).size.width * .985,
      decoration: _buildDecoration(model),
      child: Stack(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: _buildMiniPlayerTitle(mediaState),
            trailing: _buildMiniPlayerPlayPauseButton(model, audioPlayerHandler),
          ),
          Positioned(
            top: 7,
            bottom: 7,
            left: 15,
            child: _buildAlbumArt(mediaState.mediaItem!.artUri.toString(), 55),
          ),
          Positioned(
            top: 69,
            bottom: MediaQuery.of(context).padding.bottom,
            left: -15,
            right: -15,
            child: _buildSlider(mediaState, audioPlayerHandler),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayerTitle(MediaState mediaState) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 75.0, bottom: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 22.0),
                  child: MarqueeText(
                    text: TextSpan(
                      text: mediaState.mediaItem!.title,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal,fontSize: 14),
                    ),
                    speed: 12,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 22.0, top: 2.5),
                  child: MarqueeText(
                    text: TextSpan(
                      text: mediaState.mediaItem!.artist!,
                      style: TextStyle(color: Colors.white70,fontWeight: FontWeight.normal,fontSize: 13),
                    ),
                    speed: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniPlayerPlayPauseButton(SongModel model, AudioHandler audioPlayerHandler) {
    return Padding(
      padding: EdgeInsets.only(right: 15.0, bottom: 15),
      child: model.playing
          ? GestureDetector(
        onTap: () {
          model.playing = false;
          audioHandler.pause();
        },
        child: Icon(Icons.pause, size: 35.0, color: Colors.white),
      )
          : GestureDetector(
        onTap: () {
          model.playing = true;
          audioHandler.play();
        },
        child: Icon(Icons.play_arrow, size: 35.0, color: Colors.white),
      ),
    );
  }

}