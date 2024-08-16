import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:strings/models/song_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../audio_handler/audio_player_handler.dart';
import '../main.dart';
import '../models/bottom_player.dart';
import '../models/recomendation_model.dart';
import '../services/download_video.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  int currentlyPlayingIndex = -1;
  Map<String, bool> playmap = {
    "showCard": true,
    "songPlay": false,
  };
  int currentlydownloadingIndex = -1;
  int clickedIndex = 999;
  bool downloaded = false;
  List<Video> _searchResults = [];
  bool hasUserSearched = false;
  final FocusNode _focusNode = FocusNode();
  bool playButtonOn = true;
  TextEditingController _textEditingController = TextEditingController();
  late List<bool> isPlayingList;
  late List<bool> isInPlaylist;
  bool isPlaylistSelectorVisible = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void dispose() {
    _textEditingController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Consumer<SongModel>(
        builder: (context, model, child) {
          return Material(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    model.accentColor,
                    Colors.black,
                    Colors.black
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Stack(
                    children: [
                      SafeArea(
                        top: true,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 17, right: 17),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Search",
                                    style: GoogleFonts.urbanist(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 29,
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.watch_later_outlined,
                                        color: Colors.white,
                                        size: 29,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: Material(
                                child: TextField(
                                  controller: _textEditingController,
                                  focusNode: _focusNode,
                                  onTap: () {},
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == '') {
                                        hasUserSearched = false;
                                      } else {
                                        hasUserSearched = true;
                                        _searchYoutubeVideos(value);
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    hintText: 'What do you feel like listening to?',
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.only(left: 15, top: 0),
                                      child: Icon(Icons.search),
                                    ),
                                    suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _textEditingController.clear();
                                            hasUserSearched = false;
                                          });
                                        },
                                        child: hasUserSearched
                                            ? Icon(Icons.delete_outline)
                                            : const Icon(
                                          Icons.delete_outline,
                                          color: Colors.white,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            Divider(
                              color: Colors.grey.shade700,
                              height: 0,
                              indent: 0,
                            ),
                            GestureDetector(
                              onLongPress: () {
                                _focusNode.unfocus();
                              },
                              child: SizedBox(
                                height: 626, // height above bottom nav bar
                                child: hasUserSearched
                                    ? ListView.builder(
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    var id = _searchResults[index].id;
                                    var title = _searchResults[index].title;
                                    var author = _searchResults[index].author;
                                    var thumbnailUrl = _searchResults[index].thumbnails.highResUrl;
                                    var bottomPlayerThumbnailUrl = _searchResults[index].thumbnails.lowResUrl;
                                    var duration = _searchResults[index].duration;
                                    var url = _searchResults[index].url;
                                    _controller.forward();

                                    return Padding(
                                      padding: const EdgeInsets.only(left: 15, right: 15),
                                      child: GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            context.read<SongModel>().CardVisibilityOn();
                                            context.read<SongModel>().title = title;
                                            context.read<SongModel>().author = author;
                                            context.read<SongModel>().duration = duration!.inSeconds;
                                            context.read<SongModel>().tUrl = thumbnailUrl;
                                            clickedIndex = index;
                                            downloaded = false;
                                          });

                                          await download(id.toString(), title, author, thumbnailUrl, bottomPlayerThumbnailUrl, duration!,url);
                                          await getRelatedVideos(url);
                                          },
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: 95,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10.0),
                                                  child: FadeTransition(
                                                    opacity: _animation,
                                                    child: Container(
                                                      width: 60.0,
                                                      height: 60.0,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.8),
                                                            spreadRadius: 2,
                                                            blurRadius: 7,
                                                            offset: Offset(2, 3), // changes the shadow position
                                                          ),
                                                        ],
                                                        color: Colors.purple.shade900,
                                                        borderRadius: BorderRadius.circular(5.0),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(5),
                                                        child: PhotoView(
                                                          imageProvider: NetworkImage(bottomPlayerThumbnailUrl),
                                                          customSize: Size(110, 110),
                                                          enableRotation: true,
                                                          backgroundDecoration: BoxDecoration(
                                                            color: Theme.of(context).canvasColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20, top: 15),
                                                  child: Container(
                                                    width: 200,
                                                    padding: EdgeInsets.zero,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          _searchResults[index].title,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          _searchResults[index].author,
                                                          maxLines: 1,
                                                          style: const TextStyle(color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],),

                                              index == clickedIndex && downloaded == false ? Padding(
                                                padding: const EdgeInsets.only(right: 15.0),
                                                child: CircularProgressIndicator(color: Colors.purpleAccent,),
                                              ) : Container()

                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                                    : Container(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  _searchYoutubeVideos(String query) async {
    var yt = YoutubeExplode();
    try {
      var searchList = await yt.search(query);

      setState(() {
        //fetchData(searchList);
        _searchResults = searchList;
        isPlayingList = List.generate(_searchResults.length, (index) => false);
      });

    } catch (e) {
      print('Error fetching YouTube videos: $e');
    }
  }

  Future<void> fetchData(List<Video> searchResults) async {
    List<Future<bool>> futures = [];

    for (int i = 0; i < searchResults.length; i++) {
      futures.add(checkInPlaylist('My Songs', searchResults[i].id.toString()));
    }

    List<bool> results = await Future.wait(futures);

    setState(() {
      isInPlaylist = results;
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

  Future<Color> updateCardColor(url) async {
    final box = await Hive.openBox('retainer');
    PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(url));
    var color = paletteGenerator.dominantColor!.color;
    box.put('color', paletteGenerator.dominantColor!.color.toString());
    return color;
  }

  bool fileExists(String filePath) {
    var file = File(filePath);
    return file.existsSync();
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
    String stream_link = '';
    final song_model = context.read<SongModel>();
    try {
      var color = await updateCardColor(bottomplayer_thumbnail_url);
      final appDocDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDocDir.path}/$id.m4a';

      if (await fileExists(filePath)) { // Ensure fileExists is an async function
        await updateRetain(
          id,
          url,
          thumbnail_url,
          title,
          author,
          duration.inSeconds,
          filePath,
          '',
        );
        MediaItem item = MediaItem(
          id: filePath,
          album: author,
          title: title,
          artist: author,
          duration: duration,
          artUri: Uri.parse(thumbnail_url),
          playable: true,
        );
        setState(() {
          song_model.playing = true;
          clickedIndex = 9999;
          downloaded = true;
          song_model.id = id;
          song_model.url = url;
          song_model.filepath = filePath;
          song_model.accentColor = color;
        });

        await audioHandler.seek(Duration(seconds: 0));
        await audioHandler.updateMediaItem(item);
        await audioHandler.play();



      } else {
        stream_link = await DownloadVideo().getStreamLink(id);
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
          clickedIndex = 9999;
          downloaded = true;
          song_model.fileUrlPath = stream_link;
          song_model.accentColor = color;
          song_model.CardVisibilityOn();
        });

        await audioHandler.seek(Duration(seconds: 0));
        await audioHandler.updateMediaItem(item);
        await audioHandler.play();



        // Download the video in the background
        String downloadedFilePath = await DownloadVideo().downloadVideo(id);
        song_model.id = id;
        song_model.url = url;
        song_model.filepath = downloadedFilePath;
      }

      // Update the retainer box
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
    } catch (e) {
      print('Error in download function: $e');
      // Handle errors appropriately, possibly update the UI to show an error message
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
