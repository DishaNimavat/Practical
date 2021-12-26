
import 'package:get_it/get_it.dart';

import 'custom/network_utility.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerFactory(() => NetworkUtility());
}
