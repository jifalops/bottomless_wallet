import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'backend.dart';
import 'package:async_resource_flutter/async_resource_flutter.dart';
import 'package:locales/currency_codes.dart';
import 'package:locales/locales.dart';
import 'package:display/display.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User user;
  Display display;
  final getPaidAmount = TextEditingController();
  final findUser = TextEditingController();

  String get userLink => '$baseUrl/${user.username}/${getPaidAmount.text}';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    display = Display(height: size.height, width: size.width);
    return Scaffold(
      body: Builder(
        builder: (context) => SafeArea(
              child: FutureHandler(
                future: getUser(),
                handler: (ctx, u) {
                  user = User(u);
                  return Container(
                    color: Colors.grey,
                    child: Center(
                      child: Container(
                        color: Colors.white,
                        constraints: BoxConstraints(maxWidth: 400),
                        // child: ScrollConfiguration(
                        //   behavior: ScrollBehavior(),
                        child: ListView(
                          children: <Widget>[
                            profileButton(context),
                            getPaidTile(context),
                            activityTile(context),
                            findUserTile(context),
                            shareApp()
                          ],
                        ),
                        // ),
                      ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }

  Widget profileButton(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.only(top: 48, bottom: 40),
          child: FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text(user.username ?? 'Profile'),
            padding: EdgeInsets.symmetric(horizontal: 48),
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () {
              Navigator.of(context).pushNamed('profile');
            },
          ),
        ),
      );

  Widget getPaidTile(BuildContext context) => _uiSectionTile(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Get Paid', style: TextStyle(fontSize: 20)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 192,
                child: TextField(
                  controller: getPaidAmount,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefix: Text('\$'),
                    // prefixIcon: Icon(Icons.attach_money),
                    helperText: 'Amount optional',
                    // border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.content_copy),
                label: Text('Copy Link'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: userLink));
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard')));
                },
              ),
              FlatButton.icon(
                icon: Icon(Icons.share),
                label: Text('Share'),
                onPressed: () {
                  Share.share('pay me however you\'d like $userLink');
                },
              )
            ],
          ),
        ]),
      );

  Widget activityTile(BuildContext context) {
    Widget activityRow(UserTransaction t) => Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Tooltip(
                message: t.amSender ? 'sent' : 'received',
                child: Text(
                  t.amSender ? '→' : '←',
                  style: TextStyle(fontSize: 24, height: .5),
                )),
            // Icon(t.amSender ? Icons.arrow_forward_ios : Icons.arrow_back_ios),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(t.username),
                          Text(
                            '${t.timestamp}',
                            style: TextStyle(height: 1.5),
                          ),
                        ]),
                    Column(
                      children: <Widget>[
                        Text('\$${t.amount}'),
                        Icon(Icons.payment)
                      ],
                    )
                  ],
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                PopupMenuButton(
                    icon: Icon(Icons.more_horiz),
                    itemBuilder: (context) => _overflowItems(t, context)),
                t.status == TransactionStatus.confirmed
                    ? Icon(Icons.check_circle_outline)
                    : Container(
                        height: 1,
                        width: 1,
                      ),
                // Container(
                //     // decoration: _outline(),
                //     child: IconButton(
                //         icon: Icon(Icons.check),
                //         onPressed: () => _confirm(t))),
              ],
            )
          ],
        );
    return _uiSectionTile(
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Activity', style: TextStyle(fontSize: 20)),
        FutureHandler<List<UserTransaction>>(
          future: user.transactions,
          handler: (context, transactions) => Column(
                children: transactions.isEmpty
                    ? [activityRow(DummyUserTransaction())]
                    : transactions.map(activityRow).toList(),
              ),
        )
      ]),
    );
  }

  Widget findUserTile(BuildContext context) => _uiSectionTile(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('Find user', style: TextStyle(fontSize: 20)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 256,
                child: TextField(
                  controller: findUser,
                  style: TextStyle(fontSize: 22),
                  decoration: InputDecoration(
                    hintText: 'Username',
                    suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          final profile = Profile(username: findUser.text);
                          print(profile);
                        }),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );

  Widget shareApp() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
            child: Text('FB'),
            onPressed: () => print('TODO'),
          ),
          FlatButton(
            child: Text('Tw'),
            onPressed: () => print('TODO'),
          ),
          FlatButton(
            child: Text('Rdt'),
            onPressed: () => print('TODO'),
          ),
        ],
      );
}

BoxDecoration _outline() => BoxDecoration(
    border: Border.all(width: 1),
    borderRadius: BorderRadius.all(Radius.circular(8)));

Widget _uiSectionTile(Widget child) => Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: _outline(),
        child: Padding(padding: EdgeInsets.all(16), child: child),
      ),
    );

List<PopupMenuEntry> _overflowItems(UserTransaction t, BuildContext context) {
  final list = List<PopupMenuEntry>();
  list.add(PopupMenuItem(
    child: t.status == TransactionStatus.confirmed
        ? FlatButton.icon(
            icon: Icon(Icons.undo),
            label: Text('Unconfirm'),
            onPressed: () => _confirm(t))
        : FlatButton.icon(
            icon: Icon(Icons.check),
            label: Text('Confirm'),
            onPressed: () => _confirm(t)),
  ));
  list.add(PopupMenuItem(
    child: FlatButton.icon(
      label: Text('Remove'),
      icon: Icon(Icons.close),
      onPressed: () => _tryDelete(t),
    ),
  ));
  return list;
}

void _confirm(UserTransaction t) {}
void _tryDelete(UserTransaction t) {}
