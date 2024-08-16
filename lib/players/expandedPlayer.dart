import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:strings/models/song_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../main.dart';
import '../models/bottom_player.dart';
import '../models/recomendation_model.dart';
import '../services/download_video.dart';

class Expandedplayer extends StatefulWidget {
  Animation<double> animation;
  Expandedplayer({super.key, required this.animation});

  @override
  State<Expandedplayer> createState() => _ExpandedplayerState();
}

class _ExpandedplayerState extends State<Expandedplayer> with TickerProviderStateMixin{
  double _sliderValue = 0.0;
  double _totalValue = 0.0;
  bool _isExpanded = false;
  late AnimationController _controller;
  bool isFavorite = false;
  bool _isFirstBuild = true;
  int clickedIndex = 999;
  bool downloaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      //getRelatedVideos();
      //getRecomendations();
      _isFirstBuild = false;
    }
  }



  @override
  void initState()  {
    // TODO: implement initState
    //await getRelatedVideos();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    widget.animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final recoModel = Provider.of<RecomendationModel>(context);
    return Consumer<SongModel>(
        builder: (context, model, child) {
    return Stack(
      children: [
        StreamBuilder(
          stream: _mediaStateStream,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildPlaceholderExpandedPlayer(model, audioHandler);

            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white));

            } else if (snapshot.hasData && snapshot.data!.mediaItem != null) {
              //_sliderValue = snapshot.data!.position.inSeconds.toDouble();
              //_totalValue = snapshot.data!.mediaItem!.duration!.inSeconds.toDouble();
              _sliderValue = snapshot.data!.position.inSeconds.toDouble();
              _totalValue = snapshot.data!.mediaItem!.duration!.inSeconds.toDouble();
              return _buildExpandedPlayer(snapshot.data!, model, audioHandler);

            } else if (model.isCardVisible && !snapshot.hasData) {
              print("placeholder");
              model.playing = false;
              return _buildPlaceholderExpandedPlayer(model, audioHandler);
            } else {
              //print("bhang bhosda");
              _sliderValue = 0.0;
              model.playing = false;
              return Container();
            }
          },
        ),

        Positioned(
          bottom: 0,
          height: widget.animation.value * MediaQuery.of(context).size.height,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: DraggableScrollableSheet(
              initialChildSize: 0.08,
              minChildSize: 0.08,
              expand: true,
              builder: (BuildContext context, ScrollController scrollController) {


                return SingleChildScrollView(
                  controller: scrollController,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40) ,
                            topRight: Radius.circular(40)
                        ),
                      ),
                      child:  Padding(
                        padding: const EdgeInsets.only(top: 70,left: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Recommended songs",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 20,),
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 140.0 * 1.2, // Adjust height if needed
                                enlargeCenterPage: true,
                                autoPlay: true,
                                aspectRatio: 16 / 9,
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayAnimationDuration: Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                pauseAutoPlayOnTouch: true,
                                viewportFraction: 0.8, // Increase this value to make the items bigger
                              ),
                              items: recoModel.imgList.asMap().entries.map((entry) {
                                int index = entry.key;
                                String item = entry.value;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      clickedIndex = index;
                                    });
                                    download(
                                      recoModel.idList[index],
                                      recoModel.songList[index],
                                      recoModel.authorList[index],
                                      recoModel.imgList[index],
                                      recoModel.imgList[index],
                                      Duration(seconds: int.parse(recoModel.durationList[index])),
                                      recoModel.urlList[index],
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 250 * 1.5, // Increase width to make images larger
                                        height: 200,
                                        margin: const EdgeInsets.symmetric(horizontal: 5.0), // Adjust margin if needed
                                        child: Center(
                                          child: Image.network(
                                            item,
                                            fit: BoxFit.cover,
                                            width: 250 * 1.5, // Ensure width matches the container
                                            height: 200,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 5,
                                        child: BlurryContainer(
                                          borderRadius: BorderRadius.zero,
                                          blur: 15,
                                          height: 50,
                                          width: 250 * 1.21, // Ensure width matches the container
                                          child: Text(
                                            recoModel.songList[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      index == clickedIndex && downloaded == false
                                          ? Padding(
                                        padding: const EdgeInsets.only(right: 15.0),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.purpleAccent,
                                          ),
                                        ),
                                      )
                                          : Container(),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                          ],
                        ),
                      )
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
        });
  }



  Widget _buildAlbumArt(String artUri, double size) {
    return Container(
      width: size,
      height: size,
      decoration: _buildBoxShadow(),
      child: ClipRRect(
        //borderRadius: BorderRadius.circular(5),
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(artUri),
          customSize: size == 55 ? Size(size+40, size+40) : Size(size+300, size+300),
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
          offset: const Offset(2, 3),
        ),
      ],
      //borderRadius: BorderRadius.circular(5.0),
    );
  }

  Widget _buildExpandedPlayer(MediaState mediaState, SongModel model, AudioHandler audioPlayerHandler) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          const SizedBox(height: 80,),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _toggleExpansion,
                child: Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Icon(CupertinoIcons.chevron_down,color: Colors.white,size: 20,),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 25.0),
                child: Icon(Icons.more_horiz,color: Colors.white,size: 25,),
              ),
            ],
          ),
          const SizedBox(height: 60,),
          _buildAlbumArt(mediaState.mediaItem!.artUri.toString(), MediaQuery.of(context).size.width-70),
          const SizedBox(height: 40),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.shuffle,size: 25,color: Colors.white,),
              ),
              Padding(
                padding: EdgeInsets.only(right: 25),
                child: Icon(Icons.repeat,size: 25,color: Colors.white,),
              )
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 1.0, // Adjust the track height if needed
              activeTrackColor: Colors.white,
              inactiveTrackColor: model.accentColor.withBlue(100).withGreen(100).withRed(100), // Light red color for the total slider
              overlayColor: Colors.red.withOpacity(0.2), // Optional: red overlay color
              thumbShape: SliderComponentShape.noThumb,
            ),
            child: Slider(
              value: _sliderValue <= mediaState.mediaItem!.duration!.inSeconds.toDouble() ? _sliderValue : 0,
              min: 0,
              max: mediaState.mediaItem!.duration!.inSeconds.toDouble(),
              onChanged: (value) {
                if (value <= mediaState.mediaItem!.duration!.inSeconds.toDouble()) {
                  setState(() {
                    _sliderValue = value;

                  });
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _buildMediaInfo(mediaState),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.library_add_outlined,size: 25,color: Colors.white,),
              ),
              const Icon(CupertinoIcons.backward_end,size: 35,color: Colors.white,),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 13),
                child: model.playing
                    ? GestureDetector(
                  onTap: () {
                    model.playing = false;
                    audioHandler.pause();
                  },
                  child: const Icon(Icons.pause_circle_filled_rounded, size: 70.0, color: Colors.white),
                )
                    : GestureDetector(
                  onTap: () {
                    model.playing = true;
                    audioHandler.play();
                  },
                  child: const Icon(Icons.play_circle_fill_rounded, size: 70.0, color: Colors.white),
                ),
              ),
              const Icon(CupertinoIcons.forward_end,size: 35,color: Colors.white,),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: model.isFavorite ? GestureDetector(
                  onTap: () {
                      removeMusicTrack();
                  },
                  child: Icon(
                    CupertinoIcons.heart_fill,
                    size: 25,
                    color: Colors.white,
                  ),
                ) : GestureDetector(
                  onTap: () {
                    addMusicTrack();
                  },
                  child: const Icon(
                    CupertinoIcons.heart,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSlider(MediaState mediaState, SongModel model, AudioHandler audioPlayerHandler) {
    _totalValue = mediaState.mediaItem!.duration!.inSeconds.toDouble();
    return GestureDetector(
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2.0,

          activeTrackColor: Colors.white,
          inactiveTrackColor: model.accentColor.withBlue(100).withGreen(100).withRed(100), // Light red color for the total slider
          overlayColor: Colors.red.withOpacity(0.2), // Optional: red overlay color
          thumbShape: SliderComponentShape.noThumb,
        ),
        child: Slider(
          value: _sliderValue <= mediaState.mediaItem!.duration!.inSeconds.toDouble() ? _sliderValue : 0,
          min: 0,
          max: mediaState.mediaItem!.duration!.inSeconds.toDouble(),
          onChanged: (value) {
            // if (value < mediaState.mediaItem!.duration!.inSeconds.toDouble()) {
              setState(() {
                _sliderValue = value;
                audioHandler.seek(Duration(seconds: value.toInt()));
                // audioHandler.pause();
              });
            // }
          },
          allowedInteraction: SliderInteraction.tapAndSlide,

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
          style: const TextStyle(color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500
          ),
          textAlign: TextAlign.center,
        ),
        Text(mediaState.mediaItem!.artist!, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildPlaceholderExpandedPlayer(SongModel model, AudioHandler audioPlayerHandler) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          const SizedBox(height: 80,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: GestureDetector(
                    onTap: _toggleExpansion,
                    child: Icon(CupertinoIcons.chevron_down,color: Colors.white,size: 20,)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: Icon(Icons.more_horiz,color: Colors.white,size: 25,),
              ),
            ],
          ),
          const SizedBox(height: 60,),
          _buildAlbumArt(model.tUrl, MediaQuery.of(context).size.width-70),
          const SizedBox(height: 40),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.shuffle,size: 25,color: Colors.white,),
              ),
              Padding(
                padding: EdgeInsets.only(right: 25),
                child: Icon(Icons.repeat,size: 25,color: Colors.white,),
              )
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.0,
              activeTrackColor: Colors.white,
              inactiveTrackColor: model.accentColor.withBlue(100).withGreen(100).withRed(100), // Light red color for the total slider
              overlayColor: Colors.red.withOpacity(0.2), // Optional: red overlay color
              thumbShape: SliderComponentShape.noThumb,
            ),
            child: Slider(
              value: _sliderValue,
              min: 0,
              max: _totalValue, onChanged: (double value) {  },

            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(model.title,
                  style: const TextStyle(color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(model.author, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.library_add_outlined,size: 25,color: Colors.white,),
              ),
              const Icon(CupertinoIcons.backward_end,size: 35,color: Colors.white,),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 13),
                child: model.playing
                    ? GestureDetector(
                  onTap: () {
                    model.playing = false;
                    audioHandler.pause();
                  },
                  child: const Icon(Icons.pause_circle_filled_rounded, size: 70.0, color: Colors.white),
                )
                    : GestureDetector(
                  onTap: () {
                    model.playing = true;
                    audioHandler.play();
                  },
                  child: const Icon(Icons.play_circle_fill_rounded, size: 70.0, color: Colors.white),
                ),
              ),
              const Icon(CupertinoIcons.forward_end,size: 35,color: Colors.white,),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: model.isFavorite ? GestureDetector(
                  onTap: () {
                    removeMusicTrack();
                  },
                  child: Icon(
                    CupertinoIcons.heart_fill,
                    size: 25,
                    color: Colors.white,
                  ),
                ) : GestureDetector(
                  onTap: () {
                    addMusicTrack();



                  },
                  child: const Icon(
                    CupertinoIcons.heart,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Future<void> addMusicTrack() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final model = context.read<SongModel>();

    try {
      QuerySnapshot existingTracks = await firestore.collection('users')
          .doc(userId)
          .collection('my_songs')
          .where('id', isEqualTo: model.id)
          .where('url', isEqualTo: model.url)
          .get();

      if (existingTracks.docs.isEmpty) {
        await firestore.collection('users')
            .doc(userId)
            .collection('my_songs')
            .add({
          'id':model.id,
          'url': model.url,
          'track_name': model.title,
          'artist_name': model.author,
          'track_url': model.fileUrlPath,
          'thumbnail_url': model.tUrl,
          'track_local_path': model.filepath,
          'duration' : model.duration,
          'card_color': model.accentColor.toString(),
          'added_at': Timestamp.now(),
        });
        print('Music track added successfully!');
        setState(() {
          model.isFavorite = true;
        });
      } else {
        print('This track is already in the database.');
      }
    } catch (e) {
      print('Error adding music track: $e');
    }
  }

  Future<void> removeMusicTrack() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final model = context.read<SongModel>();

    try {
      QuerySnapshot existingTracks = await firestore.collection('users')
          .doc(userId)
          .collection('my_songs')
          .where('id', isEqualTo: model.id)
          .where('url', isEqualTo: model.url)
          .get();

      if (existingTracks.docs.isNotEmpty) {
        // Get the reference to the document and delete it
        String docId = existingTracks.docs.first.id;
        await firestore.collection('users')
            .doc(userId)
            .collection('my_songs')
            .doc(docId)
            .delete();

        print('Music track removed successfully!');
        setState(() {
          model.isFavorite = false;
        });
      } else {
        print('This track is not in the database.');
      }
    } catch (e) {
      print('Error removing music track: $e');
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

    } else {                                                          // else, get the stream link
      String stream_link = await DownloadVideo().getStreamLink(id);
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




  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  Stream<MediaState> get _mediaStateStream => Rx.combineLatest2<MediaItem?, Duration, MediaState>(
    audioHandler.mediaItem,
    AudioService.position,
        (mediaItem, position) => MediaState(mediaItem, position),
  );

}
