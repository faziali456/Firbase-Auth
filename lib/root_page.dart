import 'package:flutter/material.dart';
import 'auth.dart';
import 'check_connection_page.dart';
import './ui/login_page.dart';
import './ui/dashboard.dart';

class RootPage extends StatefulWidget {
  RootPage({Key key, this.auth}) : super(key: key);
  final BaseAuth auth;
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  checking,
  notSignedIn,
  signedIn,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.checking;
  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        if (userId != null) {
          _updateAuthStatus(AuthStatus.signedIn);
        } else {
          _updateAuthStatus(AuthStatus.notSignedIn);
        }
      });
    });
  }

  void _updateAuthStatus(AuthStatus status) {
    setState(() {
      authStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.checking:
        return new LoadingPage(
          title: 'Firebase Auth',
          auth: widget.auth,
        );
      case AuthStatus.notSignedIn:
        return new LoginPage();
      case AuthStatus.signedIn:
       return new DashboardPage();
    }
  }
}
