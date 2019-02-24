import 'dart:async';
import 'firebase.dart';

export 'firebase.dart';

const baseUrl = 'https://ez-pay.app';

abstract class DocMixin {
  /// The Firebase DocumentID;
  String get id;

  String get _docPath;
  DocumentSnapshot _doc;

  /// The raw data fetched from the Firebase Document.
  Map<String, dynamic> get data => _doc?.data ?? {};

  /// Update [data] from Firebase.
  Future<void> refresh() async => _doc = await db.document(_docPath).get();
}

class User with DocMixin {
  User(this.auth) : profile = Profile(uid: auth.uid) {
    refresh();
  }

  User._(this.auth, this.profile);

  final FirebaseUser auth;
  final Profile profile;

  String get id => auth.uid;
  String get _docPath => 'users/$id';

  String get username => profile.username;

  Future<List<UserTransaction>> get transactions async =>
      _transactions ??= (await db
              .collection('$_docPath/transactions')
              // .where('removed', isEqualTo: false)
              .getDocuments())
          .documents
          .where((doc) => doc.data['status'] != 'removed')
          .map((doc) => UserTransaction.fromSnapshot(doc))
          .toList();
  List<UserTransaction> _transactions;
}

class Profile with DocMixin {
  Profile({String uid, String username})
      : assert(uid != null || username != null) {
    if (uid?.isNotEmpty ?? false) {
      _uid = uid;
      refresh();
    } else {
      fetchDoc('usernames/$username').then((doc) {
        _uid = doc['uid'];
        refresh();
      });
    }
  }

  String get id => _uid;
  String _uid;
  String get _docPath => 'profiles/$id';

  String get anonId => data['anonId'];
  String get username => data['username'];
  String get name => data['name'];

  Future<List<ProfileWallet>> get wallets async => _wallets ??= (await db
          .collection('$_docPath/wallets')
          .where('accepted', isEqualTo: true)
          .getDocuments())
      .documents
      .map((doc) => ProfileWallet.fromSnapshot(doc))
      .toList();
  List<ProfileWallet> _wallets;
}

class ProfileWallet with DocMixin {
  ProfileWallet.fromSnapshot(DocumentSnapshot doc) {
    _doc = doc;
  }

  String get id => _doc.documentID;
  String get _docPath => _doc.reference.path;

  String get type => data['type'];
  String get username => data['username'];
  bool get preferred => data['preferred'];
}

class UserTransaction with DocMixin {
  UserTransaction.fromSnapshot(DocumentSnapshot doc) {
    _doc = doc;
  }

  String get id => _doc.documentID;
  String get _docPath => _doc.reference.path;

  bool get amSender => data['amSender'];
  String get uid => data['uid'];
  String get username => data['username'];
  String get walletId => data['walletId'];
  String get walletType => data['walletType'];
  double get amount => data['amount'];
  int get timestamp => data['timestamp'];
  TransactionStatus get status => data['status'] == null
      ? TransactionStatus.none
      : data['status'] == 'confirmed'
          ? TransactionStatus.confirmed
          : TransactionStatus.removed;
}

class DummyUserTransaction extends UserTransaction {
  DummyUserTransaction() : super.fromSnapshot(null);
  String get id => 'abc123';
  String get _docPath => '/dummy/transaction';

  bool get amSender => true;
  String get uid => 'uid_fm303fa93mf';
  String get username => 'user123';
  String get walletId => 'walletId';
  String get walletType => 'walletType';
  double get amount => 123.45;
  int get timestamp => 39852019;
  TransactionStatus get status => TransactionStatus.none;
}

enum TransactionStatus { none, confirmed, removed }
