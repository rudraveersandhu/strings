import 'dart:async';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:strings/models/song_model.dart';
import '../audio_handler/audio_player_handler.dart';
import '../main.dart';
import '../models/bottom_player.dart';
import '../services/download_video.dart';

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> with TickerProviderStateMixin, ChangeNotifier {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _sliderValue = 0.0;
  var _totalValue = 0.0;
  late StreamSubscription<Duration> _positionSubscription;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    _positionSubscription = AudioPlayerHandler().player.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });


    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<SongModel>();

    return Material(
      color: Colors.transparent,
      child: StreamBuilder<MediaState>(
        stream: _mediaStateStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
              print("waiting");
              return _buildPlaceholderPlayer(audioHandler);
          } else if (snapshot.hasError) {
              print("error snapshot");
              return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white));

          } else if (snapshot.hasData && snapshot.data!.mediaItem != null) {
              _sliderValue = snapshot.data!.position.inSeconds.toDouble();
              _totalValue = snapshot.data!.mediaItem!.duration!.inSeconds.toDouble();
              if(_sliderValue >= _totalValue ){
                model.playing = false;
                AudioPlayerHandler().stopListeningToPositionStream();
              }

              return _buildMiniPlayer(snapshot.data!, audioHandler);

          } else if (model.isCardVisible && !snapshot.hasData) {
              print("placeholder thrown");
              return _buildPlaceholderPlayer(audioHandler);

          } else {
              print("Else case running");
              _sliderValue = 0.0; // Set default value for slider
              model.playing = false; // Update model state if needed
              return Container(); // Return an empty container or placeholder
          }
        },
      ),
    );
  }

  Stream<MediaState> get _mediaStateStream => Rx.combineLatest2<MediaItem?, Duration, MediaState>(
    audioHandler.mediaItem,
    AudioService.position,
        (mediaItem, position) => MediaState(mediaItem, position),
  );

  Widget _buildMiniPlayer(MediaState mediaState, AudioHandler audioHandler) {
    return Consumer<SongModel>(
      builder: (context, model, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          height: model.isCardVisible ? 70 : 0,
          width: MediaQuery.of(context).size.width * .985,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 15.0,
                spreadRadius: 2.8,
                offset: Offset(9, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000), // Adjust duration as needed
                child: Image.network(
                  width: MediaQuery.of(context).size.width,
                  model.tUrl, // Replace with your image URL
                  key: Key(model.tUrl), // Use key to ensure Flutter knows it's a new image
                  fit: BoxFit.cover,
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY:50), // Adjust sigmaX and sigmaY for the blur intensity
                child: Container(
                  color: Colors.transparent,
                ),
              ),
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
                                  text: mediaState.mediaItem!.title,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal,fontSize: 13),
                                ),
                                speed: 12,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 22.0, top: 2.5),
                              child: Center(
                                child: MarqueeText(
                                  text: TextSpan(
                                    text: mediaState.mediaItem!.artist!,
                                    style: TextStyle(color: Colors.white70,fontWeight: FontWeight.normal,fontSize: 12),
                                  ),
                                  speed: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Padding(
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
                    onTap: () async {
                      // print(model.filepath);
                      // if(model.filepath == ''){
                      //   print("filepath is empty");
                      //   if(model.fileUrlPath == ''){
                      //     print("fileUrlpath is empty");
                      //     await download(
                      //       model.id,
                      //       model.title,
                      //       model.author,
                      //       model.tUrl,
                      //       model.tUrl,
                      //       Duration(seconds: model.duration),
                      //       model.url,
                      //     );
                      //   }
                      // }
                      model.playing = true;
                      audioHandler.play();
                    },
                    child: Icon(Icons.play_arrow, size: 35.0, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 7,
                bottom: 7,
                left: 12,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Image.network(
                    height: 54,
                    model.tUrl, // Replace with your image URL
                    key: Key(model.tUrl), // Use key to ensure Flutter knows it's a new image
                    fit: BoxFit.cover, // Adjust the fit as per your requirement
                  ),
                ),
              ),
              Positioned(
                top: 70.2,
                left: -23,
                right: -23,
                bottom: MediaQuery.of(context).padding.bottom,
                child: GestureDetector(
                  child: SliderTheme(
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderPlayer(AudioHandler audioPlayerHandler) {
    return Consumer<SongModel>(
        builder: (context, model, child) {
          try{
            return Container(
              height: model.isCardVisible ? 70 : 0,
              width: MediaQuery.of(context).size.width * .985,
              decoration: const BoxDecoration(
                borderRadius:  BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 15.0,
                    spreadRadius: 2.8,
                    offset: Offset(9, 7),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300), // Adjust duration as needed
                    child: Image.network(
                      width: MediaQuery.of(context).size.width,
                      model.tUrl.isEmpty ? 'https://picsum.photos/seed/picsum/536/354' : model.tUrl, // Replace with your image URL
                      key: Key(model.tUrl), // Use key to ensure Flutter knows it's a new image
                      fit: BoxFit.cover,
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY:50), // Adjust sigmaX and sigmaY for the blur intensity
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
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
                                        text: model.title,
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal,fontSize: 13),
                                      ),
                                      speed: 12,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 22.0, top: 2.5),
                                    child: Center(
                                      child: MarqueeText(
                                        text: TextSpan(
                                          text: model.author,
                                          style: TextStyle(color: Colors.white70,fontWeight: FontWeight.normal,fontSize: 12),
                                        ),
                                        speed: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Padding(
                        padding: EdgeInsets.only(right: 15.0, bottom: 15),
                        child: model.playing
                            ? GestureDetector(
                          onTap: () {
                            setState(() {
                              model.playing = false;
                            });
                            audioHandler.pause();
                          },
                          child: Icon(Icons.pause, size: 35.0, color: Colors.white),
                        )
                            : GestureDetector(
                          onTap: () {
                            audioHandler.seek(Duration(seconds: 0));
                            setState(() {
                              model.playing = true;
                            });
                            audioHandler.play();
                          },
                          child: Icon(Icons.play_arrow, size: 35.0, color: Colors.white),
                        ),
                      )
                  ),
                  Positioned(
                    top: 7,
                    bottom: 7,
                    left: 12,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Image.network(
                        height: 54,
                        model.tUrl, // Replace with your image URL
                        key: Key(model.tUrl), // Use key to ensure Flutter knows it's a new image
                        fit: BoxFit.cover, // Adjust the fit as per your requirement
                      ),
                    ),
                  ),
                  Positioned(
                      top: 69,
                      bottom: MediaQuery.of(context).padding.bottom,
                      left: -15,
                      right: -15,
                      child: GestureDetector(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 1.0, // Adjust the track height if needed
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: model.accentColor.withBlue(100).withGreen(100).withRed(100), // Light red color for the total slider
                            overlayColor: Colors.red.withOpacity(0.2), // Optional: red overlay color
                            thumbShape: SliderComponentShape.noThumb,
                          ),
                          child: Slider(
                            value: 0,
                            min: 0,
                            max: 150,
                            onChanged: (value) {

                            },
                          ),
                        ),
                      )
                  ),
                ],
              ),
            );
          }catch(error){
            print('Error thrown on return placeholder mini player: $error');
            return Container();
          }

        });
  }

  Future<void> download(
      String id,
      String title,
      String author,
      String thumbnail_url,
      String bottomplayer_thumbnail_url,
      Duration duration,
      String url,
      ) async {
    print("starting download");

    final song_model = context.read<SongModel>();
    try {
      //var color = await updateCardColor(bottomplayer_thumbnail_url);
      //final appDocDir = await getApplicationDocumentsDirectory();
      //final filePath = '${appDocDir.path}/$id.m4a';
      String filePath = '';

      String stream_link = await DownloadVideo().getStreamLink(id);

      await updateRetain(
        id,
        url,
        thumbnail_url,
        title,
        author,
        duration.inSeconds,
        filePath,
        stream_link,
      );

      MediaItem item = MediaItem(
        id: stream_link,
        album: author,
        title: title,
        artist: author,
        duration: duration,
        artUri: Uri.parse(thumbnail_url),
        playable: true,
      );

      setState(() {
        song_model.playing = true;
        song_model.fileUrlPath = stream_link;
        //song_model.accentColor = color;
        //song_model.CardVisibilityOn();
      });
      await audioHandler.seek(Duration(seconds: 0));
      await audioHandler.updateMediaItem(item);
      await audioHandler.play();

      String downloadedFilePath = await DownloadVideo().downloadVideo(id);
      song_model.filepath = downloadedFilePath;

      await updateRetain(
        id,
        url,
        thumbnail_url,
        title,
        author,
        duration.inSeconds,
        downloadedFilePath,
        stream_link,
      );

    } catch (e) {
      print('Error in download function: $e');
      // Handle errors appropriately, possibly update the UI to show an error message
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
    try{
      print("retainer fetcehd url: $url");
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
    }catch(e){
      print("Error updating retain: $e");
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


}

