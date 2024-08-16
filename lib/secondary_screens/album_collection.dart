// *
// * This file is an essential component of Verve, a free music playing app.
// *
// * Verve is an open-source software project, released under the terms
// * of the GNU Lesser General Public License (GPL), version 3 or any later version.
// *
// * The primary mission of Verve is to provide an accessible platform for
// * free music enjoyment for all users. By redistributing or modifying this software,
// * you are agreeing to the terms specified in the GPL.
// *
// * Verve is distributed with the aspiration to contribute to the musical
// * experience of users worldwide. However, it comes with no warranty, either
// * implied or expressed,regarding its merchantability or fitness for a specific purpose.
// *
// * For detailed information, refer to the GNU Lesser General Public License. If you did
// * not receive a copy of the GNU Lesser General Public License along with Verve, please
// * visit <http://www.gnu.org/licenses/>.
// *
// * Copyright (c) 2023-2024, Rudraveer Singh Sandhu
// * Project Git: https://github.com/rudraveersandhu/Verve
// *

import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:strings/models/song_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../audio_handler/audio_player_handler.dart';
import '../main.dart';
import '../models/album.dart';
import '../models/bottom_player.dart';

import '../models/recomendation_model.dart';
import '../playlist_provider.dart';
import '../services/download_video.dart';


class AlbumCollection extends StatefulWidget {
  final List<DocumentSnapshot<Object?>> musicTracks;
  AlbumCollection({super.key, required this.musicTracks});

  @override
  State<AlbumCollection> createState() => _AlbumCollectionState();
}

class _AlbumCollectionState extends State<AlbumCollection> with TickerProviderStateMixin {
  final ScrollController _controller1 = ScrollController();
  final ScrollController _controller2 = ScrollController();
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<bool> isInPlaylist ;
  List<Future<bool>> futures = [];
  int currentlydownloadingIndex = -1;
  bool track1 = false;
  late List<bool> isPlayingList ;
  int currentlyPlayingIndex = -1;
  int check = 0;
  bool _isMounted = false;
  bool linear = false;
  bool shuffle = false;
  bool repeat = false ;

  int clickedIndex = 999;
  bool downloaded = false;



  void _onScrollEvent() {
    _controller1.jumpTo(_controller2.offset);
    track1 = true;
  }



  @override
  void initState() {

    _isMounted = true;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = Tween(begin: 0.0,end: 1.0).animate(_controller);
    //final ABmodel = Provider.of<AlbumModel>(context, listen: false);
    //isPlayingList = List.generate(ABmodel.playlistLength , (index) => false);
    //print("Printing playlist detains from album collection : ${ABmodel.playlistLength}");
    _controller2.addListener(_onScrollEvent);
    super.initState();
  }

  fetchData(playlistDetails) async {
    isInPlaylist = List.generate(playlistDetails!.length, (index) => false);
    for (int i = 0; i < playlistDetails.length; i++) {
      futures.add(checkInPlaylist('My Songs', playlistDetails[i]['vId'].toString()));
    }
    List<bool> results = await Future.wait(futures);
    print(results);

    setState(() {
      isInPlaylist = results;
      check = 3;
    });
  }

  Future<bool> checkInPlaylist(String targetPlaylistName, String id) async {
    final box = await Hive.openBox('playlists');
    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    var targetPlaylist = storedPlaylists.firstWhere(
          (playlist) => playlist['name'] == targetPlaylistName,
      orElse: () => <String, Object>{},
    );

    if (targetPlaylist != null) {
      List<dynamic> songs = targetPlaylist['songs'];

      for (var song in songs) {
        String vId = song['vId'];

        if (vId == id) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }


  @override
  void dispose() {
    _isMounted = false;
    _controller1.dispose();
    _controller2.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String thumbnailUrl1 = '';
    String thumbnailUrl2 = '';
    String thumbnailUrl3= '';
    String thumbnailUrl4 = '';
    //print(widget.musicTracks[0]['thumbnail_url']);

    try{
      switch (widget.musicTracks.length) {
        case 0:
          print("case 0");
          thumbnailUrl1 =
              'https://t3.ftcdn.net/jpg/04/54/66/12/360_F_454661277_NtQYM8oJq2wOzY1X9Y81FlFa06DVipVD.jpg';
          thumbnailUrl2 =
              'https://t3.ftcdn.net/jpg/04/54/66/12/360_F_454661277_NtQYM8oJq2wOzY1X9Y81FlFa06DVipVD.jpg';
          thumbnailUrl3 =
              'https://t3.ftcdn.net/jpg/04/54/66/12/360_F_454661277_NtQYM8oJq2wOzY1X9Y81FlFa06DVipVD.jpg';
          thumbnailUrl4 =
              'https://t3.ftcdn.net/jpg/04/54/66/12/360_F_454661277_NtQYM8oJq2wOzY1X9Y81FlFa06DVipVD.jpg';
          break;

        case 1:
          print("case 1");
          thumbnailUrl1 = widget.musicTracks[0]['thumbnail_url'];
          thumbnailUrl2 = widget.musicTracks[0]['thumbnail_url'];
          thumbnailUrl3 = widget.musicTracks[0]['thumbnail_url'];
          thumbnailUrl4 = widget.musicTracks[0]['thumbnail_url'];
          break;

        case 2:
          print("case 2");
          thumbnailUrl1 = widget.musicTracks[0]['thumbnail_url'];
          thumbnailUrl2 = widget.musicTracks[1]['thumbnail_url'];
          thumbnailUrl3 = widget.musicTracks[1]['thumbnail_url'];
          thumbnailUrl4 = widget.musicTracks[0]['thumbnail_url'];
          break;

        case 3:
          print("case 3");
          thumbnailUrl1 = widget.musicTracks[0]['thumbnail_url'];
          thumbnailUrl2 = widget.musicTracks[1]['thumbnail_url'];
          thumbnailUrl3 = widget.musicTracks[2]['thumbnail_url'];
          thumbnailUrl4 = widget.musicTracks[0]['thumbnail_url'];
          break;

        case >4:
          print("case 4");
          thumbnailUrl1 = widget.musicTracks[0]['thumbnail_url'];
          thumbnailUrl2 = widget.musicTracks[1]['thumbnail_url'];
          thumbnailUrl3 = widget.musicTracks[2]['thumbnail_url'];
          thumbnailUrl4 = widget.musicTracks[3]['thumbnail_url'];
          break;

          default:
            thumbnailUrl1 =
            'https://t3.ftcdn.net/jpg/04/54/66/12/360_F_454661277_NtQYM8oJq2wOzY1X9Y81FlFa06DVipVD.jpg';
            thumbnailUrl2 =
            'https://t3.ftcdn.net/jpg/04/54/66/12/360_F_454661277_NtQYM8oJq2wOzY1X9Y81FlFa06DVipVD.jpg';
            thumbnailUrl3 =
            'https://t3.ftcdn.net/jpg/04/54/66/12/360_F_454661277_NtQYM8oJq2wOzY1X9Y81FlFa06DVipVD.jpg';
            thumbnailUrl4 =
            'https://t3.ftcdn.net/jpg/04/54/66/12/360_F_454661277_NtQYM8oJq2wOzY1X9Y81FlFa06DVipVD.jpg';

      }
    }catch(e){
      print("Switch case error: $e");
    }
    final model = context.read<SongModel>();
    //final nav = context.watch<Playlists>();
    _controller.forward();

    print(thumbnailUrl1);

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              model.accentColor,
              Colors.black.withOpacity(.96)
            ],
            stops: [
              0.3,
              .65
            ]),
      ),
      child: Stack(
        children: [
          NestedScrollView(
              physics: const BouncingScrollPhysics(),
              controller: _controller1,
              headerSliverBuilder: (BuildContext context, bool innerBoxScrolled,) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 260,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: false,
                    toolbarHeight: 40,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back,color:Colors.white), // Change this to your custom icon
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    //floating: true,
                    automaticallyImplyLeading: true,
                    flexibleSpace: LayoutBuilder(
                      builder: (
                          BuildContext context,
                          BoxConstraints constraints,
                          ) {
                        return FlexibleSpaceBar(
                          background: GestureDetector(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  height: 60,
                                ),
                                Expanded(
                                  child: Stack(
                                    children: [
                                      _animation.value > 0.0 ? Container(
                                        //height: MediaQuery.of(context).size.height,
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
                                      Center(
                                        child: Container(
                                          width: 203.0,
                                          //height: 203.0,
                                          decoration: BoxDecoration(
                                            // color: model.cardBackgroundColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.6),
                                                spreadRadius: 10,
                                                blurRadius: 35,
                                                offset: Offset(15, 15),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  FadeTransition(
                                                    opacity: _animation,
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.only(
                                                            bottomRight: Radius.zero,
                                                            topLeft:
                                                            Radius.circular(15)),
                                                        child: PhotoView(
                                                          imageProvider: CachedNetworkImageProvider(
                                                            thumbnailUrl1,
                                                          ),
                                                          customSize: Size(180, 180),
                                                          enableRotation: true,
                                                          gaplessPlayback: true,
                                                          backgroundDecoration: BoxDecoration(
                                                            color: Theme.of(context).canvasColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 100,
                                                    width: 3,
                                                  ),
                                                  FadeTransition(
                                                    opacity: _animation,
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.only(
                                                            bottomRight: Radius.zero,
                                                            topRight:
                                                            Radius.circular(15),
                                                            bottomLeft: Radius.zero),
                                                        child: PhotoView(
                                                          imageProvider: CachedNetworkImageProvider(
                                                            thumbnailUrl2,
                                                          ),
                                                          customSize: Size(180, 180),
                                                          enableRotation: true,
                                                          gaplessPlayback: true,
                                                          backgroundDecoration: BoxDecoration(
                                                            color: Theme.of(context).canvasColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 3,
                                                width: 200,
                                              ),
                                              Row(
                                                children: [
                                                  FadeTransition(
                                                    opacity: _animation,
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.only(
                                                          bottomLeft:
                                                          Radius.circular(15),
                                                        ),
                                                        child: PhotoView(
                                                          imageProvider: CachedNetworkImageProvider(
                                                            thumbnailUrl3,
                                                          ),
                                                          customSize: Size(180, 180),
                                                          enableRotation: true,
                                                          gaplessPlayback: true,
                                                          backgroundDecoration: BoxDecoration(
                                                            color: Theme.of(context).canvasColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 100,
                                                    width: 3,
                                                  ),
                                                  FadeTransition(
                                                    opacity: _animation,
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                        const BorderRadius.only(
                                                            bottomRight: Radius.circular(10)
                                                        ),
                                                        child: PhotoView(
                                                          imageProvider: CachedNetworkImageProvider(
                                                            thumbnailUrl4,
                                                          ),
                                                          customSize: Size(180, 180),
                                                          enableRotation: true,
                                                          gaplessPlayback: true,
                                                          backgroundDecoration: BoxDecoration(
                                                            color: Theme.of(context).canvasColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 13),
                              ],
                            ),
                          ),
                        ); // the vanishing upper part
                      },
                    ),
                  ),
                ];
              },
              body: SingleChildScrollView(
                controller: _controller2,
                physics: NeverScrollableScrollPhysics(),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, top: 15),
                                child: Container(
                                    width: MediaQuery.of(context).size.width - 120,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.waveform_path,
                                              color: Colors.grey.shade500,
                                            ),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  "Listen on Strings",
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                      color: Colors.grey.shade500,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Consumer<AudioPlayerHandler>(
                                              builder:((context, playmodeModel, child)=>
                                              playmodeModel.playbac == "linear" ? GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = Provider.of<AlbumModel>(context, listen: false);
                                                    setState(() {
                                                      linear = false;
                                                      playmodeModel.playbac = 'none';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.playlist_play,
                                                    color: model.accentColor.withRed(model.accentColor.red + 80).withGreen(model.accentColor.green + 80).withBlue(model.accentColor.blue + 80),
                                                    size: 40,
                                                  )
                                              )
                                                  : GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      linear = true;
                                                      shuffle = false;
                                                      repeat = false;
                                                      playmodeModel.playbac = 'linear';
                                                      playback = 'linear';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.playlist_play,
                                                    color: Colors.white70,
                                                    size: 40,
                                                  )
                                              )
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Consumer<AudioPlayerHandler>(
                                              builder:((context, playmodeModel, child)=>
                                              playmodeModel.playbac == "shuffle" ? GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      shuffle = false;
                                                      playmodeModel.playbac = 'none';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.shuffle,
                                                    color: model.accentColor.withRed(model.accentColor.red + 80).withGreen(model.accentColor.green + 80).withBlue(model.accentColor.blue + 80),
                                                    size: 30,
                                                  )
                                              )
                                                  :  GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      shuffle = true;
                                                      linear = false;
                                                      repeat = false;
                                                      playmodeModel.playbac = 'shuffle';
                                                      playback = 'shuffle';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.shuffle,
                                                    color: Colors.white70,
                                                    size: 30,
                                                  )
                                              )
                                              ),
                                            ),
                                            SizedBox(width: 12,),
                                            Consumer<AudioPlayerHandler>(
                                              builder:((context, playmodeModel, child)=>
                                              playmodeModel.playbac == "repeat" ? GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      repeat = false;
                                                      playmodeModel.playbac = 'none';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.repeat,
                                                    color: model.accentColor.withRed(model.accentColor.red + 80).withGreen(model.accentColor.green + 80).withBlue(model.accentColor.blue + 80),
                                                    size: 30,
                                                  )
                                              )
                                                  : GestureDetector(
                                                  onTap: () {
                                                    //final ABmodel = context.read<AlbumModel>();
                                                    setState(() {
                                                      shuffle = false;
                                                      linear = false;
                                                      repeat = true;
                                                      playback = 'repeat';
                                                      playmodeModel.playbac = 'repeat';
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.repeat,
                                                    color: Colors.white70,
                                                    size: 30,
                                                  )
                                              )
                                              ),
                                            ),
                                            //SizedBox(width: 20,)
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.play_circle_filled_rounded,
                                  color: Colors.white,
                                  size: 77,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height,
                            child: ListView.builder(
                              itemCount: widget.musicTracks.length,
                              itemBuilder: (context, index) {
                                var track = widget.musicTracks[index];
                                var title = track['track_name'];
                                var author = track['artist_name'];
                                var thumbnail = track['thumbnail_url'];
                                var localPath = track['track_local_path'];
                                var urlPath = track['track_url'];
                                var duration = track['duration'];
                                var id = track['id'];
                                var url = track['url'];

                                return Padding(
                                        padding: const EdgeInsets.only(bottom: 5.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            //await download(id.toString(), title, author, thumbnail_url, bottomplayer_thumbnail_url, duration!);
                                            var color = await updateCardColor(track['thumbnail_url']);
                                            setState(() {
                                              context.read<SongModel>().CardVisibilityOn();
                                              context.read<SongModel>().title = title;
                                              context.read<SongModel>().author = author;
                                              context.read<SongModel>().duration = duration;
                                              context.read<SongModel>().tUrl = thumbnail;
                                              clickedIndex = index;
                                              downloaded = false;
                                            });
                                            print("${title}/${id}");

                                            await download(id.toString(), title, author, thumbnail, thumbnail, Duration(seconds: duration),urlPath);
                                            await getRelatedVideos(url);

                                          },
                                          child: Container(
                                            height: 70,
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 20.0),
                                                  child: FadeTransition(
                                                    opacity: _animation,
                                                    child: Container(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(0.8),
                                                            spreadRadius: 2,
                                                            blurRadius: 7,
                                                            offset: Offset(2, 3),
                                                          ),
                                                        ],
                                                        color: Colors.orange,
                                                        borderRadius:
                                                        BorderRadius.circular(2.0),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                        BorderRadius.circular(2),
                                                        child: PhotoView(
                                                          imageProvider: CachedNetworkImageProvider(
                                                            track['thumbnail_url'].toString(),

                                                          ),
                                                          customSize: Size(120, 120),
                                                          enableRotation: true,
                                                          gaplessPlayback: true,
                                                          backgroundDecoration: BoxDecoration(
                                                            color: Theme.of(context).canvasColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10,),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 15.0,
                                                      left: 12,
                                                      right: 12
                                                  ),
                                                  child: Column(
                                                    //mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        width: 260,
                                                        child: Text(
                                                          track['track_name']
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            top: 5.0),
                                                        child: Container(
                                                          width: 220,
                                                          child: Text(
                                                            track['artist_name'].toString(),
                                                            style: const TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 13,
                                                              fontWeight:
                                                              FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),


                                                // Padding(
                                                //   padding: const EdgeInsets.only(bottom: 10.0),
                                                //   child: Builder(
                                                //       builder: (context) {
                                                //         return AnimatedSwitcher(
                                                //           duration: Duration(milliseconds: 500),
                                                //           child: isPlayingList[index] //&& model.playButtonOn
                                                //               ? Icon(CupertinoIcons.pause_solid, color: Colors.white, key: Key('pause'))
                                                //               : Icon(CupertinoIcons.play_arrow_solid,color: Colors.white, key: Key('play')),
                                                //           transitionBuilder: (child, animation) {
                                                //             return ScaleTransition(
                                                //               scale: animation,
                                                //               child: child,
                                                //             );
                                                //           },
                                                //         );
                                                //       }
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                              },
                            ),
                          ),
                          // Consumer<PlaylistProvider>(
                          //   builder: (context, playlistProvider, child) {
                          //     List<String> names = playlistProvider.youtube_playlists;
                          //     return Container(
                          //       height:MediaQuery.of(context).size.height-kBottomNavigationBarHeight-200,
                          //       child: buildRow(model.rows[widget.index], names[widget.index])
                          //     );
                          //
                          //   },
                          // )
                          /*FutureBuilder<List<Map<String, Object>>>(
                            future: accessPlaylist(ABmodel.playlistName),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(color: Colors.white),
                                );
                              } else {
                                List<Map<String, Object>>? playlistDetails =
                                    snapshot.data;

                                return Container(
                                  height: MediaQuery.of(context).size.height,
                                  //width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                    controller: _controller2,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    padding: EdgeInsets.zero,
                                    itemCount: playlistDetails?.length,
                                    itemBuilder: (context, index) {
                                      Map<String, Object>? songDetails =
                                      playlistDetails?[index];

                                      return GestureDetector(
                                        onTap: () async {
                                          final List path_dur = await DownloadVideo().downloadVideo(songDetails['vId'].toString());  // Download the audio file, return a list with file location and duration

                                          await _updateCardColor(
                                            songDetails['tUrl'].toString(),
                                              songDetails['songTitle'].toString(),
                                              songDetails['songAuthor'].toString(),
                                              path_dur[1].toInt()
                                          );

                                          updateRetain(songDetails['songTitle'].toString(), songDetails['songAuthor'].toString(), songDetails['tUrl'].toString(), path_dur[0], songDetails['tUrl'].toString());

                                          hplaylist = playlistDetails;
                                          strack = index;
                                          playback = 'linear';
                                          //totalDuration = Duration(seconds: path_dur[1].toInt());

                                          await AudioPlayerHandler().initializePlaylistAudioPlayer(playlistDetails,index,path_dur,0,'linear');

                                          audioHandler.play();

                                          setState(()  {

                                            isPlayingList[index] = !isPlayingList[index];
                                            if (currentlyPlayingIndex != index) {
                                              if (currentlyPlayingIndex != -1) { // If a new item is clicked, this stops the currently playing item
                                                isPlayingList[currentlyPlayingIndex] = false;
                                              }
                                              currentlyPlayingIndex = index; // Updating the currently playing index
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 3.0),
                                          child: Container(
                                            height: 70,
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 15.0),
                                                  child: FadeTransition(
                                                    opacity: _animation,
                                                    child: Container(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(0.8),
                                                            spreadRadius: 2,
                                                            blurRadius: 7,
                                                            offset: Offset(2, 3),
                                                          ),
                                                        ],
                                                        color: Colors.orange,
                                                        borderRadius:
                                                        BorderRadius.circular(2.0),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                        BorderRadius.circular(2),
                                                        child: PhotoView(
                                                          imageProvider: CachedNetworkImageProvider(
                                                            songDetails!['tUrl'].toString(),

                                                          ),
                                                          customSize: Size(120, 120),
                                                          enableRotation: true,
                                                          gaplessPlayback: true,
                                                          backgroundDecoration: BoxDecoration(
                                                            color: Theme.of(context).canvasColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 12.0,
                                                          left: 12,
                                                          right: 12
                                                      ),
                                                      child: Container(
                                                        width: 260,
                                                        child: Text(
                                                          songDetails['songTitle']
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5.0),
                                                      child: Container(
                                                        width: 220,
                                                        child: Text(
                                                          songDetails['songAuthor']
                                                              .toString(),
                                                          style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 13,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: 10,),

                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 10.0),
                                                  child: Builder(
                                                      builder: (context) {
                                                        return AnimatedSwitcher(
                                                          duration: Duration(milliseconds: 500),
                                                          child: isPlayingList[index] //&& model.playButtonOn
                                                              ? Icon(CupertinoIcons.pause_solid, color: Colors.white, key: Key('pause'))
                                                              : Icon(CupertinoIcons.play_arrow_solid,color: Colors.white, key: Key('play')),
                                                          transitionBuilder: (child, animation) {
                                                            return ScaleTransition(
                                                              scale: animation,
                                                              child: child,
                                                            );
                                                          },
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          )*/
                        ],
                      )),
                ),
              )
          )
        ],
      ),
    );
  }

  Future<void> addToPlaylist(
      String playlistName,
      String songTitle,
      String artist,
      String thumb,
      String audPath,
      String vId ,
      String tempUrl,
      int dur
      ) async {
    var playlistProvider =
    Provider.of<PlaylistProvider>(context, listen: false);
    //final nav = Provider.of<Playlists>(context, listen: false);
    final box = await Hive.openBox('playlists');

    List<dynamic> storedPlaylists = box.get('playlists', defaultValue: []);

    var mySongsPlaylist = storedPlaylists.firstWhere(
          (playlist) => playlist['name'] == playlistName,
      orElse: () => {
        'name': playlistName,
        'songs': []
      },
    );

    List<dynamic> songs = mySongsPlaylist['songs'];

    bool isSongAlreadyPresent = songs.any((song) =>
    song['songTitle'] == songTitle && song['songAuthor'] == artist);

    if (isSongAlreadyPresent) {
      print('Song is already present in $playlistName playlist.');
    } else {
      songs.add({
        'songTitle': songTitle,
        'songAuthor': artist,
        'tUrl': tempUrl,
        'vId': vId,
        'audPath': audPath,
        'thumbnail': thumb,
        'duration': dur,
      });

      box.put('playlists', storedPlaylists);
      await box.close();

      setState(() {
        //if (!nav.playlist.contains(playlistName)) {
        //  nav.playlist.add(playlistName);
        //  playlistProvider.updateLocalPlaylist(nav.playlist);
        //}
      });

      print('Song added to "My Songs" playlist successfully.');
    }
  }

  bool fileExists(String filePath) {
    var file = File(filePath);
    return file.existsSync();
  }

  download(
      String id,
      String title,
      String author,
      String thumbnail_url,
      String bottomplayer_thumbnail_url,
      Duration duration,
      String url
      ) async {
    final song_model = context.read<SongModel>();
    var color = await updateCardColor(bottomplayer_thumbnail_url);
    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDocDir.path}/$id.m4a';

    if(fileExists(filePath)){                                          // if file exist

      setState(() {
        song_model.CardVisibilityOn();
        song_model.id = id;
        song_model.url = url;
        song_model.playing = true;
        song_model.title = title;
        song_model.author = author;
        song_model.duration = duration.inSeconds;
        song_model.tUrl = thumbnail_url;
        song_model.filepath = filePath;
        //song_model.fileUrlPath = stream_link;
        song_model.accentColor = color;
        downloaded = true;
        clickedIndex = 999;
        downloaded = false;
      });
      MediaItem item = MediaItem(
        id: filePath,
        album: author,
        title: title,
        artist: author,
        duration: duration,
        artUri: Uri.parse(thumbnail_url),
        playable: true,
      );
      //await AudioPlayerHandler().initializeAudioPlayer(filepath);
      await audioHandler.seek(Duration(seconds: 0));
      await audioHandler.updateMediaItem(item);
      await audioHandler.play();                                      // play the file from local source
      print("file exist,playing");


    } else {                                                          // else, get the stream link
      print("getting stream link ");
      String stream_link = await DownloadVideo().getStreamLink(id);
      print("Got stream link !");
      setState(() {
        song_model.CardVisibilityOn();
        song_model.playing = true;
        song_model.title = title;
        song_model.author = author;
        song_model.duration = duration.inSeconds;
        song_model.tUrl = thumbnail_url;
        song_model.fileUrlPath = stream_link;
        song_model.accentColor = color;
        downloaded = true;
        clickedIndex = 999;
        downloaded = false;
      });
      MediaItem item = MediaItem(
        id: stream_link,
        album: author,
        title: title,
        artist: author,
        duration: duration,
        artUri: Uri.parse(thumbnail_url),
        playable: true,
      );
      //await AudioPlayerHandler().initializeAudioPlayer(filepath);
      await audioHandler.seek(Duration(seconds: 0));
      await audioHandler.updateMediaItem(item);
      await audioHandler.play();                                       // and play via stream link
      print("playing via stream link");

      String filePath = await DownloadVideo().downloadVideo(id);       // in the backgroun, download the song locally,
      song_model.id = id;
      song_model.url = url;
      song_model.filepath = filePath;
    }

    await updateRetain(                                                // then update the retainer box
      id,
      url,
      thumbnail_url,
      title,
      author,
      duration.inSeconds,
      filePath,
      '0',
    );
  }

  getRelatedVideos(String url) async {
    // Create an instance of YoutubeExplode
    final recomendation_model = Provider.of<RecomendationModel>(context, listen: false);
    var youtube = YoutubeExplode();

    try {
      // Get the video from the provided URL
      var video = await youtube.videos.get(url);

      // Clear the lists before adding new values
      recomendation_model.idList.clear();
      recomendation_model.songList.clear();
      recomendation_model.authorList.clear();
      recomendation_model.imgList.clear();
      recomendation_model.durationList.clear();

      // Get related videos
      var relatedVideos = await youtube.videos.getRelatedVideos(video);

      // Iterate over related videos and add the required information to the model lists
      for (var relatedVideo in relatedVideos!) {
        recomendation_model.idList.add(relatedVideo.id.value);
        recomendation_model.songList.add(relatedVideo.title);
        recomendation_model.authorList.add(relatedVideo.author);
        recomendation_model.imgList.add(relatedVideo.thumbnails.highResUrl);
        recomendation_model.durationList.add(relatedVideo.duration!.inSeconds.toString());
      }
    } catch (e) {
      print('Error occurred: $e');
      return [];
    } finally {
      // Close the YoutubeExplode instance
      youtube.close();
    }
  }

  updateRetain(
      String id,
      String url,
      String tUrl,
      String title,
      String author,
      int duration,
      String filepath,
      String fileUrlPath,
      ) async {
    final box = await Hive.openBox('retainer');
    box.put('id', id);
    box.put('url', url);
    box.put('tUrl', tUrl);
    box.put('title', title);
    box.put('author', author);
    box.put('duration', duration);
    box.put('filepath', filepath);
    box.put('fileUrlPath', fileUrlPath);
    print("updated retain");
  }

  Future<Color> updateCardColor(url) async {
    final box = await Hive.openBox('retain');
    PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(url));
    var color = paletteGenerator.dominantColor!.color;
    box.put('color', paletteGenerator.dominantColor!.color.toString());
    return color;
  }

}