import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/auth.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => new _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    _setUserLogInTime();
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
      ),
      body: _bodyWidgets(context),
    );
  }

  Widget _bodyWidgets(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          Card(
            elevation: 2.0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              width: 300.0,
              height: 270.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Hello You are now logged in :)',
                      style: TextStyle(
                          fontFamily: "WorkSansSemiBold",
                          fontSize: 15.0,
                          color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: MaterialButton(
                        color: Theme.of(context).buttonColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          child: Text(
                            "Log Out",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontFamily: "WorkSansBold"),
                          ),
                        ),
                        onPressed: () {
                          _setUserLogOutTime();
                        }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  void _setUserLogInTime() {
    Auth().currentUser().then((userID) {
      FirebaseDatabase.instance
          .reference()
          .child("Logs")
          .child(userID)
          .child('LogIns')
          .push()
          .child('timeStamp')
          .set(ServerValue.timestamp);
    });
  }

  void _setUserLogOutTime() {
    Auth().currentUser().then((userID) {
      FirebaseDatabase.instance
          .reference()
          .child("Logs")
          .child(userID)
          .child('LogOuts')
          .push()
          .child('timeStamp')
          .set(ServerValue.timestamp)
          .then((onValue) {
        Auth().signOut().then((onValue) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        });
      });
    });
  }
}
