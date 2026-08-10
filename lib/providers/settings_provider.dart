import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  String _namaToko = 'NASUHA LAUNDRY';
  String _emailToko = 'owner@lndr.com';
  String _userRole = 'OWNER';

  String get namaToko => _namaToko;
  String get emailToko => _emailToko;
  String get userRole => _userRole;

  void updateNamaToko(String namaBaru) {
    _namaToko = namaBaru;
    notifyListeners();
  }
}
