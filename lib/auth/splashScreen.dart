
import 'package:audio_service/audio_service.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:strings/introScreen.dart';
import 'package:strings/models/bottom_player.dart';
import 'package:strings/models/song_model.dart';
import 'package:strings/models/recomendation_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../main.dart';
import '../main_screens/main_screen.dart';
import '../models/user_model.dart';
import '../services/download_video.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  List<String> cid = [];

  @override
  void initState() {
    _checkAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Image.asset('assets/splash.jpeg',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          BlurryContainer(
            blur:6,
              child: Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 400),
                    child: Text(
                      'Strings',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                ),
              )),
          Center(
            child: LoadingAnimationWidget.dotsTriangle(
              color: Colors.white,
              size: 200,
            ),
          ),
        ],
      ),
    );
  }

  void _checkAuth() async {
    //await Future.delayed(const Duration(milliseconds: 1500));
    final model = context.read<UserModel>();
    //final recoModel = context.read<RecomendationModel>();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {

        final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userData.exists) {
          model.id             = userData['id'];
          model.name           = userData['name'];
          model.profilePicture = userData['profile_pic'];
          model.email          = userData['email'];
          model.pass           = userData['password'];
          model.number         = userData['phone'];
          model.joinedOn       = userData['joined_on'];
          await getRetain();

          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }

        else {
          // Handle case where document does not exist
          print('User data does not exist for user: ${user.uid}');
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Introscreen()),
          );
        }
      } catch (e) {
        print('Error fetching user data: $e');
        // Handle error, e.g., show error message or retry logic
      }
    } else {
      print("intro screen");
      WidgetsBinding.instance.addPostFrameCallback((_) {
         Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Introscreen()),
        );
      });

    }
  }

  getRetain() async {
    final song_model = context.read<SongModel>();
    final box = await Hive.openBox('retainer');

    try{
      var id = box.get('id').toString() ?? '';
      var url = box.get('url').toString() ?? '';
      var tUrl = box.get('tUrl').toString() ?? '';
      var title = box.get('title').toString() ?? '';
      var author = box.get('author').toString() ?? '';
      var duration = box.get('duration') ?? 0;
      var filepath = box.get('filepath').toString() ?? '';
      var fileUrlPath = box.get('fileUrlPath').toString() ?? '';

      print("filepath: $filepath");
      print("fileUrlpath: $fileUrlPath");

      if(id != "null"){
        if(filepath != "" && fileUrlPath != ""){
          print("filepath is empty");
          print("fileUrlpath is empty");
          await download(
            id,
            title,
            author,
            tUrl,
            tUrl,
            Duration(seconds: duration),
            url,
          );


        }else{

        }
        song_model.isCardVisible = true;
        print("URL BEINg PASSED: $url");
        await getRelatedVideos(url);
        setState(() {
          context.read<BottomPlayerModel>().CardVisibilityOn();
          song_model.id = id;
          song_model.url = url;
          song_model.tUrl = tUrl;
          song_model.title = title;
          song_model.author = author;
          song_model.duration = duration;
          song_model.filepath = filepath;
          song_model.fileUrlPath = fileUrlPath;
        });

        MediaItem item = MediaItem(
          id: filepath,
          album: author,
          title: title,
          artist: author,
          duration: Duration(seconds: duration),
          artUri: Uri.parse(tUrl),
          //genre: color.toString(),
          playable: true,
        );
        //await AudioPlayerHandler().initializeAudioPlayer(filepath);
        await audioHandler.seek(Duration(seconds: 0));
        await audioHandler.updateMediaItem(item);
      } else{
        song_model.isCardVisible = false;
        await getRelatedVideos('https://youtu.be/LK7-_dgAVQE?si=VOT5VsKsoV10fvgJ');
      }
      print("box detailed fetched sucessfully");

    }catch(e){
      print("Box Error hehe: $e");
    }
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
        recomendation_model.urlList.add(relatedVideo.url);
        cid.add(relatedVideo.channelId.toString());
      }

      print("fetched videos successfully!");
    } catch (e) {
      print('Error occurred: $e');
      return [];
    } finally {
      // Close the YoutubeExplode instance
      youtube.close();
    }
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
      //await audioHandler.play();

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


}
