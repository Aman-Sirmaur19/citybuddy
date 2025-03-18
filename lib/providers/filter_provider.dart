import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  String _filterType = 'latest';

  String get filterType => _filterType;

  void setFilter(String newFilter) {
    _filterType = newFilter;
    notifyListeners();
  }
}
