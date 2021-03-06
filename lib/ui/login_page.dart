import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import '../helper/check_connectivity.dart';
import '../utils/bubble_indication_painter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../auth.dart';
import './forgot_password.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  //google sign
  GoogleSignIn googleauth = new GoogleSignIn();

  static final loginformKey = new GlobalKey<FormState>();
  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;
  bool _loading = false;

  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupConfirmPasswordController =
      new TextEditingController();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        body: ModalProgressHUD(
            opacity: 0.6,
            dismissible: false,
            color: Colors.deepPurple,
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
              },
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height >= 680.0
                      ? MediaQuery.of(context).size.height
                      : 680.0,
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Theme.of(context).buttonColor,
                          Theme.of(context).primaryColor
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: new Text(
                            "Firebase Auth",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30.0),
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: _buildMenuBar(context),
                      ),
                      Expanded(
                        flex: 2,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) {
                            if (i == 0) {
                              setState(() {
                                right = Colors.white;
                                left = Colors.black;
                              });
                            } else if (i == 1) {
                              setState(() {
                                right = Colors.black;
                                left = Colors.white;
                              });
                            }
                          },
                          children: <Widget>[
                            new ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: _buildSignIn(context),
                            ),
                            new ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: _buildSignUp(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            inAsyncCall: _loading));
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
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
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Log-In",
                  style: TextStyle(
                      color: left,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "Register",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: right,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
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
              height: 360.0,
              child: Form(
                key: loginformKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                      child: TextFormField(
                        validator: (value) {
                          Pattern pattern =
                              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
                          RegExp regex = new RegExp(pattern);
                          if (!regex.hasMatch(value.trim()))
                            return 'Please enter a valid email';
                          else
                            return null;
                        },
                        focusNode: myFocusNodeEmailLogin,
                        controller: loginEmailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                            fontFamily: "WorkSansSemiBold",
                            fontSize: 16.0,
                            color: Colors.black),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            FontAwesomeIcons.envelope,
                            color: Colors.black,
                            size: 22.0,
                          ),
                          hintText: "Email Address",
                          hintStyle: TextStyle(
                              fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                        ),
                      ),
                    ),
                    Container(
                      width: 250.0,
                      height: 1.0,
                      color: Colors.grey[400],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                      child: TextFormField(
                        focusNode: myFocusNodePasswordLogin,
                        controller: loginPasswordController,
                        obscureText: _obscureTextLogin,
                        validator: (value) {
                          if (value.trim().length < 6)
                            return 'Password must be atleast 6 characters';
                          else
                            return null;
                        },
                        style: TextStyle(
                            fontFamily: "WorkSansSemiBold",
                            fontSize: 16.0,
                            color: Colors.black),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            FontAwesomeIcons.lock,
                            size: 22.0,
                            color: Colors.black,
                          ),
                          hintText: "Password",
                          hintStyle: TextStyle(
                              fontFamily: "WorkSansSemiBold", fontSize: 17.0),
                          suffixIcon: GestureDetector(
                            onTap: _toggleLogin,
                            child: _obscureTextLogin
                                ? Icon(
                                    FontAwesomeIcons.eyeSlash,
                                    size: 15.0,
                                    color: Colors.black,
                                  )
                                : Icon(
                                    FontAwesomeIcons.eye,
                                    size: 15.0,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: Theme.of(context).buttonColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25.0,
                                  fontFamily: "WorkSansBold"),
                            ),
                          ),
                          onPressed: () => _loginUser()),
                    ),
                    Text(
                      'OR',
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        OutlineButton(
                            child: Image(
                                image: AssetImage("assets/img/google1.png"),
                                height: 28.0,
                                fit: BoxFit.fitHeight),
                            onPressed: () {
                              setState(() {
                                _loading = true;
                              });
                              googleauth.signIn().then((result) {
                                result.authentication.then((googleuser) {
                                  FirebaseAuth.instance
                                      .signInWithGoogle(
                                          idToken: googleuser.idToken,
                                          accessToken: googleuser.accessToken)
                                      .then((user) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil('/',
                                            (Route<dynamic> route) => false);
                                  }).catchError((e) {
                                    print(e);
                                  });
                                }).catchError((e) {
                                  print(e);
                                });
                              }).catchError((e) {
                                print(e);
                              });
                            }),
                        OutlineButton(
                            child: Image(
                                image: AssetImage("assets/img/facebook.png"),
                                height: 28.0,
                                fit: BoxFit.fitHeight),
                            onPressed: () {
                              _initiateFacebookLogin();
                            }),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    /*   Expanded(
                      flex: 1,
                      child: 
                    ), */
                    new GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ForgotPasswordPage()));
                      },
                      child: new Text(
                        "Forgot Password?",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 380.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          maxLength: 25,
                          focusNode: myFocusNodeName,
                          controller: signupNameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                            ),
                            hintText: "Name",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmail,
                          controller: signupEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                            ),
                            hintText: "Email Address",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePassword,
                          controller: signupPasswordController,
                          obscureText: _obscureTextSignup,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.black,
                            ),
                            hintText: "Password",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignup,
                              child: _obscureTextSignup
                                  ? Icon(
                                      FontAwesomeIcons.eyeSlash,
                                      size: 15.0,
                                      color: Colors.black,
                                    )
                                  : Icon(
                                      FontAwesomeIcons.eye,
                                      size: 15.0,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: signupConfirmPasswordController,
                          obscureText: _obscureTextSignupConfirm,
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.black,
                            ),
                            hintText: "Confirmation",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignupConfirm,
                              child: _obscureTextSignupConfirm
                                  ? Icon(
                                      FontAwesomeIcons.eyeSlash,
                                      size: 15.0,
                                      color: Colors.black,
                                    )
                                  : Icon(
                                      FontAwesomeIcons.eye,
                                      size: 15.0,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 360.0),
                child: MaterialButton(
                    color: Theme.of(context).buttonColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "WorkSansBold"),
                      ),
                    ),
                    onPressed: () => _signUpCompany()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  void _signUpCompany() {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp mEmailRegex = new RegExp(pattern);
    if (signupNameController.text.length < 5) {
      showDialog(
        context: context,
        builder: (ctxt) => new AlertDialog(
              title: Text("Invalid Name"),
              content: Text("Name must be atleast 5 characters"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            ),
      );
    } else if ((!mEmailRegex.hasMatch(signupEmailController.text.trim()))) {
      showDialog(
        context: context,
        builder: (ctxt) => new AlertDialog(
              title: Text("Invalid Email"),
              content: Text("Please enter a valid email."),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            ),
      );
    } else if (signupPasswordController.text.trim().length < 6) {
      showDialog(
        context: context,
        builder: (ctxt) => new AlertDialog(
              title: Text("Invalid Password"),
              content: Text("Password must be atleast 6 characters"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            ),
      );
    } else if (signupPasswordController.text.trim() !=
        signupConfirmPasswordController.text.trim()) {
      showDialog(
        context: context,
        builder: (ctxt) => new AlertDialog(
              title: Text("Match Failed"),
              content: Text("Password does not match. Please re-enter!"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            ),
      );
    } else {
      Conn().connectivityResult().then((connected) {
        if (connected) {
          setState(() {
            _loading = true;
          });
          Auth()
              .createUser(signupEmailController.text.trim(),
                  signupPasswordController.text.trim())
              .then((user) {
            user.sendEmailVerification();
            var data = {
              "userID": user.uid,
              "userName": signupNameController.text,
              "email": signupEmailController.text,
            };
            FirebaseDatabase.instance
                .reference()
                .child('Users')
                .child(user.uid)
                .set(data)
                .then((onValue) {
              showInSnackBar(
                  "You are registered Successfully! Verify your email and login the app to continue.");
              Auth().signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            }).catchError((onError) {
              print(onError.toString());
            });
          }).catchError((error) {
            print(error.toString());
            _showErrorDialogAccordingly(error.toString());
          });
        } else {
          showInSnackBar("You are not connected to internet!");
        }
      });
    }
  }

  void _loginUser() {
    FocusScope.of(context).requestFocus(new FocusNode());
    final form = loginformKey.currentState;
    if (form.validate()) {
      form.save();
      Conn().connectivityResult().then((connected) {
        if (connected) {
          setState(() {
            _loading = true;
          });
          Auth()
              .signInViaEmail(
                  loginEmailController.text, loginPasswordController.text)
              .then((user) async {
            if (user.isEmailVerified) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            } else {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: const Text('Email Not Verified'),
                    content: const Text(
                      'You haven\'t verfied your email yet. Please Verify your email by clicking the link we sent you and try login again.',
                    ),
                    actions: [
                      new FlatButton(
                        child: Text(
                          "Resend Email",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          user.sendEmailVerification();
                          showInSnackBar(
                              "Verification email sent. Please check your mail");
                        },
                      ),
                      new FlatButton(
                        child: Text(
                          "Okay",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ],
                  );
                },
              ).then((onValue) {
                setState(() {
                  _loading = false;
                });
                Auth().signOut();
              });
            }
          }).catchError((onError) {
            print(onError);
            _showErrorDialogAccordingly(onError.toString());
          });
        } else {
          showInSnackBar("You are not connected to the internet.");
        }
      });
    }
  }

  void _showErrorDialogAccordingly(String error) {
    setState(() {
      _loading = false;
    });
    if (error.contains('There is no user record ')) {
      _showCustomAlertDialog("Log in Failed!",
          'There is no user found corresponding to this email. Check your email and try again.');
    } else if (error.contains('password is invalid')) {
      _showCustomAlertDialog("Invalid Password!",
          'The password entered is incorrect or the user does not have a password. Check your credentials and try again.');
    } else if (error.contains('network error')) {
      _showCustomAlertDialog("Log in Failed!",
          'Network error has occured. The request timed out. Try again in a while');
    } else if (error.contains('email address is already in use')) {
      _showCustomAlertDialog("Sign Up Failed!",
          'The email you are trying to register with, already exists. Please sign up using a different email.');
    } else {
      _showCustomAlertDialog(
          "Log in Failed!", 'something went wrong please try again!');
    }
  }

  void _showCustomAlertDialog(String title, String message) {
    Alert(
      context: context,
      type: AlertType.error,
      title: title,
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            "Okay",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          width: 120,
        )
      ],
    ).show();
  }

  void _initiateFacebookLogin() async {
    setState(() {
      _loading = true;
    });
    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        setState(() {
          _loading = false;
        });
        _showCustomAlertDialog('Error', 'Something went wrong!');
        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(() {
          _loading = false;
        });
        _showCustomAlertDialog('Acess Denied', 'You didn\'t allow us to read your data!');
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        FirebaseAuth.instance
            .signInWithFacebook(
                accessToken: facebookLoginResult.accessToken.token)
            .then((onValue) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        });
        break;
    }
  }
}
