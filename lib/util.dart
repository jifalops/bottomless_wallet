import 'dart:async';
import 'package:connectivity/connectivity.dart';

export 'package:connectivity/connectivity.dart' show ConnectivityResult;

final _connectivity = Connectivity();

/// Check whether the device is connected to a WiFi or mobile network, although
/// even if connected the Internet may not be reachable.
Future<bool> hasNetworkConnection() async =>
    (await _connectivity.checkConnectivity()) != ConnectivityResult.none;

StreamSubscription<ConnectivityResult> onConnectivityChanged(
        void Function(ConnectivityResult) listener) =>
    _connectivity.onConnectivityChanged.listen(listener);
