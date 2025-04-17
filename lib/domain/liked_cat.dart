import '../models/cat.dart';

class LikedCat {
  final Cat cat;
  final DateTime likedAt;
  const LikedCat({required this.cat, required this.likedAt});
}
