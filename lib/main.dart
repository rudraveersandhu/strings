import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:strings/auth/firebase_options.dart';
import 'package:strings/models/recomendation_model.dart';
import 'package:strings/models/song_model.dart';
import 'package:strings/models/user_model.dart';
import 'package:strings/playlist_provider.dart';
import 'package:strings/introScreen.dart';
import 'package:strings/auth/splashScreen.dart';


import 'audio_handler/audio_player_handler.dart';
import 'models/album.dart';
import 'models/bottom_player.dart';

late AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //WidgetsFlutterBinding.ensureInitialized();


  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.strings.player.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Hive.initFlutter('Verve/Database');
  } else if (Platform.isIOS) {
    await Hive.initFlutter('Verve/Database');
  } else {
    await Hive.initFlutter();
  }


  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AudioPlayerHandler>(
            create: (context) => AudioPlayerHandler() as AudioPlayerHandler,
          ),
          ChangeNotifierProvider<SongModel>(
            create: (context) => SongModel(),
          ),
          ChangeNotifierProvider<BottomPlayerModel>(
            create: (context) => BottomPlayerModel(),
          ),
          ChangeNotifierProvider<UserModel>(
            create: (context) => UserModel(),
          ),
          ChangeNotifierProvider<RecomendationModel>(
            create: (context) => RecomendationModel(),
          ),
        ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strings',
      debugShowCheckedModeBanner: false,
      home: Splashscreen(),
    );
  }


}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}


