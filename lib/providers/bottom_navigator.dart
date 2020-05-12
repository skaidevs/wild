import 'package:flutter/foundation.dart';

class BottomNavigation with ChangeNotifier {
  int _currentIndex = 0;
  get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
