import 'package:get_it/get_it.dart';
import '../data/cat_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  if (!getIt.isRegistered<CatService>()) {
    getIt.registerLazySingleton<CatService>(() => CatService());
  }
}
