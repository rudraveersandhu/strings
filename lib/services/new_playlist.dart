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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../models/bottom_player.dart';


class NewPlaylist extends StatefulWidget {
  const NewPlaylist({super.key});

  @override
  State<NewPlaylist> createState() => _NewPlaylistState();
}

class _NewPlaylistState extends State<NewPlaylist> {
  String userInput = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String generateRandomId() {
    const String charset =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#\$%^&*()-_+=<>?/.,';

    Random random = Random();
    String id = '';
    for (int i = 0; i < 15; i++) {
      int randomIndex = random.nextInt(charset.length);
      id += charset[randomIndex];
    }
    return id;
  }

  Future<void> makePlaylist( String playlistName  ) async {
    //final nav = Provider.of<Playlists>(context, listen: false);
    //var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    final model  = context.read<BottomPlayerModel>();

    try{
      final box = await Hive.openBox('playlists');
      List<dynamic> playlists = box.get('playlists', defaultValue: []);
      bool playlistExists = playlists.any((playlist) => playlist['name'] == playlistName);
      List<String> local_names = await box.get('local_names') ?? <String>[];

      if (!playlistExists) {

        setState((){
          local_names.add(playlistName);
          //nav.playlist.add(playlistName);
          //playlistProvider.updateLocalPlaylist(nav.playlist);
        });

        String id = generateRandomId();

        playlists.add({
          'name': playlistName,
          'id' : id,
          'author': model.user,
          'description' : '',
          'NumOfSongs': 0,
          'songs': [],
        });

        await box.put('local_names', local_names);
        await box.put('playlists', playlists);
        await box.close();

      } else {
        print('Playlist $playlistName already exists.');
      }
    } catch (e) {
      print("Error accessing Hive box: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    //var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);

   // print("Start: ${playlistProvider.local_playlists.length}");
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 33,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black,
              Colors.grey.shade700,
            ],
            stops: [0.1, 1.0],
          ),
        ),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Center(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Lets name your playlist",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.only(left: 40.0,right: 40),
              child: TextField(
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                cursorColor: Colors.orange.shade700,
                onChanged: (value) {
                  setState(() {
                    userInput = value;
                  });
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 45.0,
                  fontWeight: FontWeight.w800,
                ),
                decoration: const InputDecoration(
                  hintText: 'My playlist ',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(top:40.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: ()  async {
                    if(userInput.isNotEmpty){
                      await makePlaylist(userInput);
                      setState(() {
                        Navigator.pop(context);
                      });
                    }else{
                      SnackBar(content: Text('Playlist needs to have a name.'));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0), // Curved edges
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 18.0,right: 18,top: 19,bottom: 19),
                    child: Text(
                      'Create',
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black, // Text color
                        fontWeight: FontWeight.bold, // More font weight
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////
/*ListView.builder(
//shrinkWrap: true,
itemCount: _searchResults.length,
itemBuilder: (context, index) {
var vId = _searchResults[index].id;
var thumbnailUrl = _searchResults[index].thumbnails.highResUrl ;
var tempUrl = _searchResults[index].thumbnails.lowResUrl ;
//fetchData(_searchResults);
//isInPlaylist = List.generate(_searchResults.length, (index) => checkInPlaylist('My Songs', _searchResults[index].id.toString()));
//isInPlaylist = checkInPlaylist('My Songs', vId.toString()) as List<bool>;
return Padding(
padding: const EdgeInsets.only(
left: 15, right: 15),
child: GestureDetector(
onTap: () async {
String? color = await updateCardColor(tempUrl);
final List path_dur = await DownloadVideo().downloadVideo(vId.toString());  // Download the audio file, return a list with file location and duration
setState(() {
model.isCardVisible = true;
model.currentTitle = _searchResults[index].title;
model.currentAuthor = _searchResults[index].author;
model.currentDuration = path_dur[1].toInt();
model.tUrl = thumbnailUrl;
model.vId = _searchResults[index].id.toString();
model.tUrl = thumbnailUrl;
model.filePath = path_dur[0];
});
await _updateCardColor(
thumbnailUrl,
_searchResults[index].title,
_searchResults[index].author,
path_dur[1].toInt());
updateRetain(
_searchResults[index].title,
_searchResults[index].author,
thumbnailUrl,
path_dur,
tempUrl,
path_dur[1].toInt(),
_searchResults[index].id.toString()
);
MediaItem item = MediaItem(
id: path_dur[0].toString(),
album: _searchResults[index].author,
title: _searchResults[index].title,
artist: _searchResults[index].author,
duration: Duration(seconds: path_dur[1].toInt()),
artUri: Uri.parse(thumbnailUrl),
genre: color,
playable: true,
extras: playmap = {
"showCard": true,
"songPlay": true,
}
);



await AudioPlayerHandler().initializeAudioPlayer(path_dur[0].toString());
audioHandler.updateMediaItem(item);
audioHandler.play();

},
child: Container(
width: MediaQuery.of(context).size.width,
height: 95,
child: Row(
children: [
Padding(
padding: const EdgeInsets.only(
left: 10.0),
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
offset: Offset(2,
3), // changes the shadow position
),
],
color: Colors.orange,
borderRadius:
BorderRadius.circular(
5.0),
),
child: ClipRRect(
borderRadius:
BorderRadius.circular(
5),
child: PhotoView(
imageProvider:
NetworkImage(tempUrl),
customSize: Size(110, 110),
enableRotation: true,
backgroundDecoration:
BoxDecoration(
color: Theme.of(context)
    .canvasColor,
),
),
),
),
),
),
Padding(
padding: const EdgeInsets.only(
left: 20,
top: 15,
//bottom: 15,
),
child: Container(
width: 200,
padding: EdgeInsets.zero,
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
_searchResults[index]
    .title,
maxLines: 2,
overflow: TextOverflow
    .ellipsis,
style: const TextStyle(
color: Colors.white,
fontSize: 14,
//fontWeight: FontWeight.w700,
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
//SizedBox(width: 5,),
Padding(
padding: const EdgeInsets.only(
left: 20.0),
child: Container(
width: 90,
child: Stack(
children: [
Positioned(
right: 15,
top: 30,
child: GestureDetector(
// Like actions
onTap: () async {
isPlayingList[index] = !isPlayingList[index];
if (currentlydownloadingIndex != index) {
if (currentlydownloadingIndex != -1) {
isPlayingList[currentlydownloadingIndex] = false;
}
currentlydownloadingIndex = index;
}
List path_dur = await DownloadVideo().downloadVideo(vId.toString());
await addToPlaylist(
'vjv_dsc_Sdc_SDc_Dvds_Vd',
_searchResults[index].title,
_searchResults[index].author,
thumbnailUrl,
path_dur[0],
vId.toString() ,
tempUrl,
path_dur[1].toInt());


setState(() {
//print("Running fetch data final part");
fetchData(_searchResults);
});
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
Text('Added to "My Songs" successfully !', style: TextStyle(fontSize: 12)),
SizedBox(width: 10),
ElevatedButton(
onPressed: () async {
await removeFromPlaylist(
"vjv_dsc_Sdc_SDc_Dvds_Vd",
_searchResults[index].title,
_searchResults[index].author,
thumbnailUrl,
path_dur[0],
thumbnailUrl,
vId.toString(),
path_dur[1].toInt()
);
setState(() {
showPlaylistSelector();

});
},
child: Container(
width: 50,
child: Text('Change', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
),
),
],
),
behavior: SnackBarBehavior.floating,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10.0),
),
backgroundColor: Colors.orange.withAlpha(900),
duration: Duration(seconds: 1),
),
);
},
/*child: isInPlaylist[index]
                                                              ? Icon(CupertinoIcons.heart_fill, color: Colors.deepOrange, /*key: Key('${index}heart_filled')*/)
                                                              : Icon(CupertinoIcons.heart, color: Colors.white, /*key: Key('heart')*/),*/

),
),
],),
),
),
],
),
),
),
);
},
)


 */
