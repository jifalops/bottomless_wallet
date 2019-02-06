import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

export 'package:connectivity/connectivity.dart' show ConnectivityResult;

final auth = FirebaseAuth.instance;
final db = Firestore.instance;
final _googleAuthService = GoogleSignIn();
final _connectivity = Connectivity();

/// Check whether the device is connected to a WiFi or mobile network, although
/// even if connected the Internet may not be reachable.
Future<bool> hasNetworkConnection() async =>
    (await _connectivity.checkConnectivity()) != ConnectivityResult.none;

StreamSubscription<ConnectivityResult> onConnectivityChanged(
        void Function(ConnectivityResult) listener) =>
    _connectivity.onConnectivityChanged.listen(listener);

/// Generate's the ID for a new document.
/// [path] points to the document's parent collection.
String generateDocID([String path = '']) =>
    db.collection(path).document().documentID;

/// Gets the current user or signs in anonymously.
/// If `null` is returned, there was likely a network error.
Future<FirebaseUser> getUser() async {
  var user = await auth.currentUser();
  if (user == null) {
    try {
      user = await auth.signInAnonymously();
    } catch (e) {
      print(e);
    }
    if (user == null) {
      print(
          'Unable to sign in anonymously. Are you connected to the Internet?');
    } else {
      print('Signed in anonymously. ${user.uid}');
    }
  } else
    return linkAccountToGoogle(); //TODO remove
  return user;
}

/// Upgrade an anonymous account by linking it to a Google account.
Future<FirebaseUser> linkAccountToGoogle() async {
  final credential = await _getGoogleAuthCredential();
  if (credential != null) {
    print('Credential: $credential');
    try {
      return auth.linkWithCredential(credential);
    } catch (e) {
      print(e);
    }
  }
  return null;
}

/// Tries to sign-in silently first. May return `null`.
Future<AuthCredential> _getGoogleAuthCredential() async {
  GoogleSignInAccount account;
  try {
    account = await _googleAuthService.signInSilently() ??
        await _googleAuthService.signIn();
  } catch (e) {
    print(e);
  }
  final googleAuth = await account?.authentication;
  if (account == null) {
    print('Unable to retrieve Google account.');
  } else if (googleAuth == null) {
    print('Unable to authenticate to Google account (${account.email}).');
  } else {
    // print(
    //     'accessToken: ${googleAuth.accessToken}, idToken: ${googleAuth.idToken}');
    return GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  }
  return null;
}
