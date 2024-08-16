import 'package:flutter/material.dart';

class SongModel extends ChangeNotifier {
  String id ='';
  String url ='';
  String tUrl ='';
  String title = '';
  String author = '';
  int duration = 0;
  String filepath = '';
  String fileUrlPath = '';
  bool playing = false;
  bool isFavorite = false;
  bool isCardVisible = false;
  Color accentColor = Colors.purple.shade900;


  void updateData({
    required String id,
    required String url,
    required String tUrl,
    required String title,
    required String author,
    required int duration,
    required String filepath,
    required String fileUrlPath,
    required bool playing,
    required bool isFavorite,
    required bool isCardVisible,
    required Color accentColor,

  }) {
    this.id = id;
    this.url = url;
    this.tUrl = tUrl;
    this.title = title;
    this.author = author;
    this.duration = duration;
    this.filepath = filepath;
    this.fileUrlPath = fileUrlPath;
    this.playing = playing;
    this.isCardVisible = isCardVisible;
    this.isFavorite = isFavorite;
    this.accentColor = accentColor;
    notifyListeners();
  }

  void CardVisibilityOn(){
    isCardVisible = true;
    notifyListeners();
  }

  void CardVisibilityOff(){
    isCardVisible = false;
    notifyListeners();
  }

}