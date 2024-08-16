import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:strings/models/song_model.dart';
import 'package:strings/models/user_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../main.dart';
import '../models/album.dart';
import '../models/bottom_player.dart';
import '../models/recomendation_model.dart';
import '../playlist_provider.dart';
import '../secondary_screens/album_collection.dart';
import '../services/download_video.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  List<Video> playlistVideos = [];
  List<List<dynamic>> rows = [];
  Map<int, bool?> isPressedMap = {};
  bool isPressed = false;
  bool isBlurred = false;
  bool track1 = false;
  double opacity = 1.0;
  double containerPosition = 0.0;
  String selectedPlaylist = "";
  String name = "Guest";

  final List<String> imgList = [];
  final List<String> idList = [];
  final List<String> songList = [];
  final List<String> authorList = [];
  final List<String> durationList = [];

  int clickedIndex = 999;
  bool downloaded = false;

  //final StreamController<List<SongModel>> _playlistVideosController = StreamController<List<SongModel>>();

  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isFirstBuild = true;

  void _onScrollEvent() {
    _scrollController.jumpTo(_scrollController2.offset);
    track1 = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      // getRecomendations();
      _isFirstBuild = false;
    }
  }

  @override
  initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _scrollController2.addListener(_onScrollEvent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print(imgList.length);

    final user = context.read<UserModel>();

    _controller.forward();

    final recomendation_model = Provider.of<RecomendationModel>(context);

    return Consumer<SongModel>(
      builder: (context, model, child) {
        return Material(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [model.accentColor, Colors.black, Colors.black],
              ),
            ),
            child: Stack(
              children: [
                NestedScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollController,
                    headerSliverBuilder: (
                      BuildContext context,
                      bool innerBoxScrolled,
                    ) {
                      //nav.local_playlists.length % 2 != 0 ? nav.local_playlists.length + 1 : nav.local_playlists.length
                      //print()
                      return <Widget>[
                        SliverAppBar(
                          expandedHeight: 300,
                          //nav.local_playlists.length == 0 ? 250 : ((nav.local_playlists.length%2) == 1 ? (nav.local_playlists.length/2)*(170) : (nav.local_playlists.length+1)/2) * (170),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          //pinned: true,
                          toolbarHeight: 65,
                          //floating: true,
                          automaticallyImplyLeading: false,
                          flexibleSpace: LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) {
                              //("Main section height: ${((containerHeight + 10) * checkNumber(nav.local_playlists.length))}");
                              return FlexibleSpaceBar(
                                background: GestureDetector(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 60,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Welcome back,",
                                                    style: GoogleFonts.urbanist(
                                                        color: Colors.white,
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.w800)),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 3.0),
                                                  child: Text(user.name,
                                                      style:
                                                          GoogleFonts.urbanist(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 27,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.notifications_outlined,
                                                  color: Colors.white,
                                                  size: 29,
                                                ),
                                                SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () {
                                                    //_showPlaylistImporter();
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons
                                                        .arrow_down_square,
                                                    color: Colors
                                                        .purpleAccent.shade200,
                                                    size: 29,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, top: 10),
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: EdgeInsets.zero,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        height: 30,
                                                        width: 55,
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.3),
                                                              spreadRadius: .1,
                                                              blurRadius: 6.0,
                                                              offset:
                                                                  Offset(2, 9),
                                                            ),
                                                          ],
                                                          gradient:
                                                              const LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomCenter,
                                                            colors: [
                                                              Colors.white,
                                                              Colors.white60
                                                            ],
                                                          ),
                                                        ),
                                                        child: const Center(
                                                          child: Text(
                                                            'All',
                                                            style: TextStyle(
                                                                fontSize: 17,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 30,
                                                        width: 55,
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.3),
                                                              spreadRadius: .1,
                                                              blurRadius: 6.0,
                                                              offset:
                                                                  Offset(2, 9),
                                                            ),
                                                          ],
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomCenter,
                                                            colors: [
                                                              model.accentColor
                                                                  .withOpacity(
                                                                      0.99),
                                                              model.accentColor
                                                                  .withOpacity(
                                                                      0.7)
                                                            ],
                                                          ),
                                                        ),
                                                        child: const Center(
                                                          child: Text(
                                                            'All',
                                                            style: TextStyle(
                                                                fontSize: 17,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    height: 30,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                          spreadRadius: .1,
                                                          blurRadius: 6.0,
                                                          offset: Offset(2, 9),
                                                        ),
                                                      ],
                                                      color: Colors.grey[900],
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'Music',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    height: 30,
                                                    width: 105,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                          spreadRadius: .1,
                                                          blurRadius: 6.0,
                                                          offset: Offset(2, 9),
                                                        ),
                                                      ],
                                                      color: Colors.grey[900],
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        'Podcasts',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 13),
                                      localPlaylists()
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text(
                              "Recommended",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200.0, // Adjust height if needed
                              enlargeCenterPage: true,
                              autoPlay: true,
                              //aspectRatio: 16 / 9,
                              autoPlayInterval: Duration(seconds: 3),
                              autoPlayAnimationDuration:
                                  Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              pauseAutoPlayOnTouch: true,
                              viewportFraction:
                                  0.6, // Increase this value to make the items bigger
                            ),
                            items: recomendation_model.imgList
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              String item = entry.value;
                              //print(recomendation_model.durationList[index]);

                              return GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    context.read<SongModel>().CardVisibilityOn();
                                    context.read<SongModel>().title = recomendation_model.songList[index];
                                    context.read<SongModel>().author = recomendation_model.authorList[index];
                                    context.read<SongModel>().duration = int.parse(recomendation_model.durationList[index]);
                                    context.read<SongModel>().tUrl = recomendation_model.imgList[index];
                                    context.read<SongModel>().id = recomendation_model.idList[index];
                                    context.read<SongModel>().url = recomendation_model.urlList[index];

                                    clickedIndex = index;
                                    downloaded = false;
                                  });
                                  updateRetain(
                                    recomendation_model.songList[index],
                                    recomendation_model.urlList[index],
                                    recomendation_model.imgList[index],
                                    recomendation_model.songList[index],
                                    recomendation_model.authorList[index],
                                    int.parse(recomendation_model.durationList[index]),
                                    '',
                                    '',
                                  );
                                  download(
                                    recomendation_model.idList[index],
                                    recomendation_model.songList[index],
                                    recomendation_model.authorList[index],
                                    recomendation_model.imgList[index],
                                    recomendation_model.imgList[index],
                                    Duration(seconds: int.parse(recomendation_model.durationList[index])),
                                    recomendation_model.urlList[index],
                                  );
                                  //await getRelatedVideos(recomendation_model.urlList[index]);

                                  //print("${recomendation_model.idList[index]},\n${recomendation_model.songList[index]},\n${recomendation_model.authorList[index]},\n${recomendation_model.imgList[index]},\n${recomendation_model.imgList[index]},\n${Duration(seconds: int.parse(recomendation_model.durationList[index]))},\n${recomendation_model.urlList[index]},");
                                },
                                child: Stack(
                                  children: [
                                    Positioned(
                                        top: 10,
                                        left: 0,
                                        right: 0,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.5,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  5.5,
                                              // decoration: _buildBoxShadow(),
                                              child: PhotoView(
                                                imageProvider:
                                                    CachedNetworkImageProvider(
                                                        item),
                                                customSize: Size(
                                                    MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.5 +
                                                        50,
                                                    MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            5.5 +
                                                        50),
                                                enableRotation: true,
                                                gaplessPlayback: true,
                                                backgroundDecoration:
                                                    BoxDecoration(
                                                        color: Theme.of(context)
                                                            .canvasColor),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 0,
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 100.0,
                                                    sigmaY: 100.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.5,
                                                  height: 80,
                                                  color: Colors.black.withOpacity(
                                                      0), // Transparent color to allow blur effect
                                                ),
                                              ),
                                            ),
                                            Text(
                                              recomendation_model
                                                  .songList[index],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w300,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )),
                                    index == clickedIndex && downloaded == false
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15.0),
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
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              "Today",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Container(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    10, // Change this as per your requirement
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.purpleAccent,
                                    ),
                                    width: 250,
                                    height: 150,
                                    margin: EdgeInsets.all(10),
                                    child: Center(
                                        child: Image.asset(
                                      'assets/vervesplash1.jpg',
                                      fit: BoxFit.fitWidth,
                                      width: 250,
                                      height: 150,
                                    )),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              "Discover artists",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Container(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    10, // Change this as per your requirement
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                      width: 85,
                                      height: 100,
                                      margin: EdgeInsets.all(10),
                                      child: Center(
                                          child: Container(
                                        height: 80,
                                        width: 80,
                                        child: Image.asset(
                                          'assets/vervesplash2.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      )));
                                },
                              ),
                            ),
                          ),
                          Consumer<BottomPlayerModel>(
                            builder: (context, model, _) {
                              return Container(
                                height: 100,
                                child: ListView.builder(
                                  //controller: _scrollController2,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: model.rows.length,
                                  itemBuilder: (context, rowIndex) {
                                    print(
                                        "Model row length: ${model.rows.length}");
                                    return buildRow(rowIndex);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildRow(int x) {
    //final playlistProvider = context.read<PlaylistProvider>();
    return Consumer<BottomPlayerModel>(
      builder: (context, model, child) {
        return Container(
          color: Colors.transparent,
          height: 270,
          child: ListView.builder(
            controller: _scrollController2,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: model.rows[x].length,
            itemBuilder: (context, index) {
              index = model.rows[x].length - index;
              final ABmodel = context.watch<AlbumModel>();
              List<dynamic> items = model.rows[x];

              return GestureDetector(
                onTap: () async {
                  //await _updateAlbumBgColor(model.rows[x][Random.secure().nextInt(3)].url);
                  setState(() {
                    ABmodel.ab1 = model.rows[x][0].url;
                    ABmodel.ab2 = model.rows[x][1].url;
                    ABmodel.ab3 = model.rows[x][2].url;
                    ABmodel.ab4 = model.rows[x][3].url;
                    ABmodel.playlistLength = model.rows[x].length;
                  });
                  var tracks = await fetchMusicTracks();

                  pushScreen(
                    context,
                    screen: AlbumCollection(
                      musicTracks: tracks,
                    ),
                    withNavBar: true,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10.0, left: 4, right: 4, top: 5),
                  child: Container(
                    color: Colors.transparent,
                    height: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Text(
                            model.names[x],
                            style: TextStyle(color: Colors.white, fontSize: 22),
                            maxLines: 1,
                          ),
                        ),
                        Consumer<PlaylistProvider>(
                          builder: (context, playlistProvider, child) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                //color: Colors.white,// Adjust the height as needed
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    //final video = items[index];
                                    // Check if the video has the 'url' property
                                    //print("running${playlistProvider.url.length}");
                                    return Padding(
                                      padding:
                                          EdgeInsets.only(right: 0, left: 11),
                                      child: Column(
                                        children: [
                                          FadeTransition(
                                            opacity: _animation,
                                            child: Container(
                                              width: 150.0,
                                              height: 150.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: PhotoView(
                                                  imageProvider:
                                                      CachedNetworkImageProvider(
                                                    items[index].url,
                                                  ),
                                                  customSize: Size(280, 280),
                                                  enableRotation: true,
                                                  gaplessPlayback: true,
                                                  backgroundDecoration:
                                                      BoxDecoration(
                                                    color: Theme.of(context)
                                                        .canvasColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Container(
                                            width: 150,
                                            child: Center(
                                              child: Text(
                                                items[index].title,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: Center(
                                              child: Text(
                                                items[index].author,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditDialog(String Name) {
    _nameController.text = Name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.orange.shade800,
          title: Text(
            'Edit Name',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Enter your name',
              labelStyle: TextStyle(color: Colors.white),
            ),
            style: TextStyle(color: Colors.white60),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  setName(_nameController.text.toString());
                });
                Navigator.of(context).pop();
              },
              child: Container(
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  getName() async {
    final box = await Hive.openBox('User');
    var x = box.get('name').toString();
    setState(() {
      name = x;
    });
  }

  setName(String name) async {
    final model = context.read<BottomPlayerModel>();
    final box = await Hive.openBox('User');
    box.put('name', name);
    setState(() {
      model.user = name;
    });
  }

  localPlaylists() {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 1, // Change this as per your requirement
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () async {
              var tracks = await fetchMusicTracks();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => AlbumCollection(
                            musicTracks: tracks,
                          )));
            },
            child: Container(
              width: 130,
              height: 150,
              margin: EdgeInsets.all(10),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/mysongs.png', // Replace this with the path to your image
                    width: 150, // Adjust the width as needed
                    height: 150, // Adjust the height as needed
                    fit:
                        BoxFit.cover, // Choose a fitting strategy for the image
                  ),
                  Positioned(
                    bottom: 0,
                    child: BlurryContainer(
                      height: 130,
                      width: 130,
                      child: Center(
                        child: Text(
                          'My Songs',
                          style: GoogleFonts.urbanist(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(0),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> fetchMusicTracks() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('my_songs')
          .orderBy('added_at', descending: true)
          .get();

      return snapshot.docs;
    } catch (e) {
      print('Error fetching music tracks: $e');
      return [];
    }
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

      if (await fileExists(filePath)) {
        // Ensure fileExists is an async function
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
    final recomendation_model =
        Provider.of<RecomendationModel>(context, listen: false);
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
        recomendation_model.durationList
            .add(relatedVideo.duration!.inSeconds.toString());
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
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(NetworkImage(url));
    var color = paletteGenerator.dominantColor!.color;
    box.put('color', paletteGenerator.dominantColor!.color.toString());
    return color;
  }
}
