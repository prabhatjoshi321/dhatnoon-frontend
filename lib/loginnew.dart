import 'dart:math';

import 'package:dhatnoon/admin.dart';
import 'package:dhatnoon/driver.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'constants.dart';
import 'mainpage.dart';

class LoginNew extends StatefulWidget {
  const LoginNew({Key? key}) : super(key: key);

  @override
  _LoginNewState createState() => _LoginNewState();
}

class _LoginNewState extends State<LoginNew>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isShowSignUp = false;
  // bool _isLogin = false;
  late AnimationController _animationController;
  late Animation<double> _animationTextRotate;

  //Form Fields
  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();
  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupPasswordcController = new TextEditingController();
  TextEditingController signupAdmincodeController = new TextEditingController();

  FocusNode myFocusNode = new FocusNode();

  void setUpAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: defaultDuration);
    _animationTextRotate =
        Tween<double>(begin: 0, end: 90).animate(_animationController);
  }

  void updateView() {
    setState(() {
      _isShowSignUp = !_isShowSignUp;
    });
    _isShowSignUp
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  void initState() {
    checkLoginStatus();
    setUpAnimation();
    super.initState();
  }

  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('token') != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => MainPage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(login_bg)))
            : AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: defaultDuration,
                        top: _size.height * 0.1,
                        left: 0,
                        right: _isShowSignUp
                            ? -_size.width * 0.06
                            : _size.width * 0.06,
                        child: _isShowSignUp
                            ? Text(
                                'DHATNOON',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text(
                                'DHATNOON',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                      AnimatedPositioned(
                        duration: defaultDuration,
                        width: _size.width * 0.88,
                        height: _size.height,
                        left: _isShowSignUp
                            ? -_size.width * 0.76
                            : _size.width * 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: updateView,
                          child: Container(
                            color: login_bg,
                            child: loginForm(),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                          duration: defaultDuration,
                          width: _size.width * 0.88,
                          height: _size.height,
                          left: _isShowSignUp
                              ? _size.width * 0.12
                              : _size.width * 0.88,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: updateView,
                            child: Container(
                              color: signup_bg,
                              child: signUpForm(),
                            ),
                          )),
                      AnimatedPositioned(
                          duration: defaultDuration,
                          bottom: _isShowSignUp
                              ? _size.height / 2
                              : _size.height * 0.3,
                          left: _isShowSignUp ? 0 : _size.width * 0.44 - 80,
                          child: AnimatedDefaultTextStyle(
                              duration: defaultDuration,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _isShowSignUp ? 20 : 32,
                                fontWeight: FontWeight.bold,
                                color: _isShowSignUp
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              child: Transform.rotate(
                                angle: -_animationTextRotate.value * pi / 180,
                                alignment: Alignment.topLeft,
                                child: InkWell(
                                  onTap: () {
                                    tempFunc();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: defaultPadding * 0.75),
                                    width: 160,
                                    child: Text(
                                      'LOG IN',
                                    ),
                                  ),
                                ),
                              ))),
                      AnimatedPositioned(
                          duration: defaultDuration,
                          bottom: !_isShowSignUp
                              ? _size.height / 2
                              : _size.height * 0.2,
                          right: _isShowSignUp ? _size.width * 0.44 - 80 : 0,
                          child: AnimatedDefaultTextStyle(
                              duration: defaultDuration,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: !_isShowSignUp ? 20 : 32,
                                fontWeight: FontWeight.bold,
                                color: !_isShowSignUp
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              child: Transform.rotate(
                                angle: (90 - _animationTextRotate.value) *
                                    pi /
                                    180,
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: defaultPadding * 0.75),
                                    width: 160,
                                    child: Text(
                                      'SIGN UP',
                                    ),
                                  ),
                                ),
                              )))
                    ],
                  );
                }),
      ),
    );
  }

  tempFunc() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => MainPage()),
        (Route<dynamic> route) => false);
  }

  //Login Section

  Container loginForm() {
    return Container(
        child: Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.13),
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(
              flex: 1,
            ),
            Text(
              'DHATNOON',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 45,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: loginTextEmail("Email", Icons.email),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: loginTextPassword("Password", Icons.lock),
            ),
            //
            //Forgot password section
            //
            // TextButton(
            //   onPressed: () {},
            //   child: Text(
            //     "Forgot Password?",
            //     style: TextStyle(color: Colors.white),
            //   ),
            // ),
            SizedBox(
              height: 0.0,
            ),
            Spacer(flex: 2),
          ],
        ),
      ),
    ));
  }

//Signup section
  Container signUpForm() {
    return Container(
        child: Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.13),
      child: Form(
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: signupTextEmail("Email", Icons.email),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: signupTextPassword("Password", Icons.email),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: signupTextPasswordc("Password Confirmation", Icons.email),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: signupAdmincode("Admin Code", Icons.email),
            ),
            Spacer(flex: 2)
          ],
        ),
      ),
    ));
  }

//Login Form Controller Logic
  TextFormField loginTextEmail(String title, IconData icon) {
    return TextFormField(
        controller: loginEmailController,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          labelText: title,
          labelStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.black : Colors.white70),
          hintText: "Enter valid mail id",
          hintStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.grey : Colors.white70),
        ));
  }

  TextFormField loginTextPassword(String title, IconData icon) {
    return TextFormField(
        controller: loginPasswordController,
        obscureText: true,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          labelText: title,
          labelStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.black : Colors.white70),
          hintText: "Enter valid password",
          hintStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.grey : Colors.white70),
        ));
  }

  //Signup Form Controller Logic
  TextFormField signupTextEmail(String title, IconData icon) {
    return TextFormField(
        controller: signupEmailController,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          labelText: title,
          labelStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.black : Colors.white70),
          hintText: "Enter valid mail id",
          hintStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.grey : Colors.white70),
        ));
  }

  TextFormField signupTextPassword(String title, IconData icon) {
    return TextFormField(
        controller: signupPasswordController,
        obscureText: true,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          labelText: title,
          labelStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.black : Colors.white70),
          hintText: "Enter valid password",
          hintStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.grey : Colors.white70),
        ));
  }

  TextFormField signupTextPasswordc(String title, IconData icon) {
    return TextFormField(
        controller: signupPasswordcController,
        obscureText: true,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          labelText: title,
          labelStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.black : Colors.white70),
          hintText: "Enter valid password",
          hintStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.grey : Colors.white70),
        ));
  }

  TextFormField signupAdmincode(String title, IconData icon) {
    return TextFormField(
        controller: signupAdmincodeController,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
          ),
          labelText: title,
          labelStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.black : Colors.white70),
          hintText: "Enter valid mail id",
          hintStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.grey : Colors.white70),
        ));
  }
}
