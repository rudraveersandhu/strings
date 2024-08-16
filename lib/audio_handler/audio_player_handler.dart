import 'dart:async';

import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';

import '../main.dart';
import '../services/download_video.dart';

var hplaylist;
var strack;
List<bool> showCard = [false, false];
String playback = 'linear';

/// An [AudioHandler] for playing a single item.
class AudioPlayerHandler extends BaseAudioHandler with SeekHandler, ChangeNotifier {
  late var playlist;
  String playbac = 'repeat';
  late StreamSubscription<Duration> subscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  MediaItem currentItem = MediaItem(id: "0", title: "title");

  Map<String, bool> playmap = {
    "showCard": false,
    "songPlay": false,
  };

  final _player = AudioPlayer();
  AudioPlayer get player => _player;

  /// Initialise our audio handler.
  AudioPlayerHandler() {
    // Broadcast media item and playback state updates
    // _player.currentIndexStream.listen((index) {
    //   if (index != null && index < _queue.length) {
    //     mediaItem.add(_queue[index]);
    //   }
    // });

    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // _player.playbackEventStream.listen((event) {
    //   playbackState.add(playbackState.value.copyWith(
    //     controls: [
    //       MediaControl.skipToPrevious,
    //       _player.playing ? MediaControl.pause : MediaControl.play,
    //       MediaControl.stop,
    //       MediaControl.skipToNext,
    //     ],
    //     systemActions: const {
    //       MediaAction.seek,
    //       MediaAction.seekForward,
    //       MediaAction.seekBackward,
    //     },
    //     androidCompactActionIndices: const [0, 1, 3],
    //     playing: _player.playing,
    //     updatePosition: _player.position,
    //     bufferedPosition: _player.bufferedPosition,
    //     speed: _player.speed,
    //     queueIndex: event.currentIndex,
    //   ));
    //
    //   // Check if the song has finished playing
    //   if (event.processingState == ProcessingState.completed) {
    //     stopAndReset();
    //   }
    // });
  }

  Future<void> stopAndReset() async {
    print("stioppppppppedddd");
    // Stop playback
    await _player.stop();
    // Reset position to the beginning
    await _player.seek(Duration.zero);
  }

  bool isPlaying = false;

  Future<void> initializeAudioPlayer(String filePath) async {
    playbac = "repeat";
    await _player.setFilePath(filePath);
    notifyListeners();
  }

  Future<void> initializePlaylistAudioPlayer(rplaylist, int index, List path_dur, int check, String pmode) async {
    playbac = pmode;
    strack = index;
    playlist = rplaylist;
    String? color = await updateCardColor(playlist[index].url);
    MediaItem item = MediaItem(
      id: path_dur[0].toString(),
      album: rplaylist[index].author,
      title: rplaylist[index].title,
      artist: playlist[index].author,
      duration: Duration(seconds: path_dur[1].toInt()),
      artUri: Uri.parse(playlist[index].url),
      genre: color,
      playable: true,
      extras: playmap = {
        "showCard": true,
        "songPlay": true,
      },
    );
    await audioHandler.updateMediaItem(item);
    await audioHandler.play();
    notifyListeners();
  }

  Future<String?> updateCardColor(url) async {
    final box = await Hive.openBox('retain');
    PaletteGenerator paletteGenerator =
    await PaletteGenerator.fromImageProvider(NetworkImage(url));
    String color = paletteGenerator.dominantColor!.color.toString();
    box.put('color', paletteGenerator.dominantColor!.color.toString());
    return color;
  }

  Future<void> loadNextFromPlaylist(int index, String mode) async {
    switch (mode) {
      case 'linear':
        index = index + 1;
        var filepath =
        await DownloadVideo().downloadVideo(hplaylist[index]['vId'].toString());
        await initializePlaylistAudioPlayer(hplaylist, index, [], 1, playbac);
        notifyListeners();
        break;
      case 'shuffle':
        index = getRandomNumber(0, hplaylist.length);
        var filepath =
        await DownloadVideo().downloadVideo(hplaylist[index]['vId'].toString());
        await initializePlaylistAudioPlayer(hplaylist, index, [], 1, playbac);
        notifyListeners();
        break;
      case 'repeat':
        var filepath =
        await DownloadVideo().downloadVideo(hplaylist[index]['vId'].toString());
        await initializePlaylistAudioPlayer(hplaylist, index, [], 1, playbac);
        notifyListeners();
        break;
      case '':
        await _player.seek(Duration(seconds: 0));
        await _player.play();
        break;
    }
  }

  int getRandomNumber(int min, int max) {
    Random random = Random();
    return min + random.nextInt(max - min + 1);
  }

  @override
  Future<void> play() async {
    await _player.play();
    //playmap = {"showCard": true,"songPlay": true};


    notifyListeners();
  }

  @override
  Future<void> pause() async {
    await _player.pause();

    notifyListeners();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    notifyListeners();
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) {
    // TODO: implement playFromUri
    return super.playFromUri(uri, extras);
  }

  @override
  Future<void> updateMediaItem(MediaItem myItem) async {
    if (isFilePath(myItem.id)) {
      print('File is a path');
      mediaItem.add(myItem);
      currentItem = myItem;
      await _player.setAudioSource(AudioSource.file(myItem.id));

    } else if (isURL(myItem.id)) {
      print('File is a url');
      mediaItem.add(myItem);
      currentItem = myItem;
      await _player.setAudioSource(AudioSource.uri(Uri.parse(myItem.id)));
    }
  }

  bool isURL(String input) {
    final urlPattern = r'^(http|https|ftp)://';
    final urlRegExp = RegExp(urlPattern);
    return urlRegExp.hasMatch(input);
  }

  bool isFilePath(String input) {
    final filePathPatternUnix = r'^/'; // Unix-based systems
    final filePathPatternWindows = r'^[a-zA-Z]:\\'; // Windows-based systems
    final filePathRegExpUnix = RegExp(filePathPatternUnix);
    final filePathRegExpWindows = RegExp(filePathPatternWindows);
    return filePathRegExpUnix.hasMatch(input) || filePathRegExpWindows.hasMatch(input);
  }

  void checkInput(String input) {
    if (isURL(input)) {
      print('The input is a URL.');
    } else if (isFilePath(input)) {
      print('The input is a file path.');
    } else {
      print('The input is neither a URL nor a recognizable file path.');
    }
  }




  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  Future<void> stopListeningToPositionStream() async {

    print("unsubscribed!!!");
    await audioHandler.stop();
    audioHandler.seek(Duration.zero);
    audioHandler.pause();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

}
