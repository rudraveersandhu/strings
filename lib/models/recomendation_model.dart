import 'package:flutter/material.dart';

class RecomendationModel extends ChangeNotifier {
  List<String> imgList = [];
  List<String> idList = [] ;
  List<String> songList =[];
  List<String> authorList =[] ;
  List<String> durationList = [];
  List<String> urlList = [];

  void updateData({

    required List<String> imgList,
    required List<String> idList,
    required List<String> songList,
    required List<String> authorList,
    required List<String> durationList,
    required List<String> urlList,

}) {
    this.imgList = imgList;
    this.idList = idList;
    this.songList = songList;
    this.authorList = authorList;
    this.durationList = durationList;
    this.durationList = urlList;
    notifyListeners();
  }

}