import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String id = '';
  String name = '';
  String email = '';
  String pass = '';
  String number = '';
  String profilePicture = '';
  Timestamp joinedOn = Timestamp(0, 0);

  void updateData({
    required String id,
    required String name,
    required String email,
    required String pass,
    required String number,
    required String profilePicture,
    required Timestamp joinedOn,
  }) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.pass = pass;
    this.number = number;
    this.profilePicture = profilePicture;
    this.joinedOn= joinedOn;
    notifyListeners();
  }
}
