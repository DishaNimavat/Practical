import 'package:connectivity/connectivity.dart';


/// Purpose : Custom Class
/// This is to check whether network is available or not before calling api

class NetworkUtility {
  Future<bool> getConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return Future<bool>.value(true);
      // I am connected to a mobile network.
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
    //  return AppGlobal.isInternet;
  }
}
