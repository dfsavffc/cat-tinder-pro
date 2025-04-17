import 'package:flutter/material.dart';
import '../data/cat_service.dart';
import 'liked_cat.dart';
import '../models/cat.dart';
import '../di/service_locator.dart';

class CatController with ChangeNotifier {
  final CatService _catService = getIt();

  final List<Cat> _cats = [];
  final List<LikedCat> _likedCats = [];
  bool _isLoading = false;
  bool _hasError = false;
  int _likesCount = 0;

  List<Cat> get cats => _cats;
  List<LikedCat> get likedCats => _likedCats;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  int get likesCount => _likesCount;

  Future<void> initialize() async {
    _setError(false);
    _setLoading(true);
    await _loadInitialCats();
    _setLoading(false);
  }

  Future<void> _loadInitialCats() async {
    try {
      final cat = await _catService.fetchRandomCat();
      if (cat != null) {
        _cats.add(cat);
        notifyListeners();
      } else {
        _setError(true);
      }
    } catch (_) {
      _setError(true);
    }
  }

  Future<void> _fillBuffer() async {
    if (_isLoading) return;
    _setLoading(true);
    while (_cats.length < 5 && !_hasError) {
      try {
        final cat = await _catService.fetchRandomCat();
        if (cat != null) {
          _cats.add(cat);
          notifyListeners();
        } else {
          _setError(true);
          break;
        }
      } catch (_) {
        _setError(true);
        break;
      }
    }
    _setLoading(false);
  }

  void handleSwipe(bool liked) {
    if (_cats.isEmpty) return;

    if (liked) {
      _likesCount++;
      _likedCats.add(LikedCat(cat: _cats.first, likedAt: DateTime.now()));
    }
    _cats.removeAt(0);
    notifyListeners();

    if (_cats.length <= 2) _fillBuffer();
  }

  void removeLikedCat(LikedCat cat) {
    _likedCats.remove(cat);
    notifyListeners();
  }

  void reset() {
    _cats.clear();
    _likedCats.clear();
    _likesCount = 0;
    _hasError = false;
    notifyListeners();
    initialize();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(bool v) {
    _hasError = v;
    notifyListeners();
  }
}
