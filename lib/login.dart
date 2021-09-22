import 'package:dhatnoon/admin.dart';
import 'package:dhatnoon/driver.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  String URL = "http://10.10.10.1:8000/api/auth/login";

  // @override
  // void initState() {
  //   super.initState();
  //   checkLoginStatus();
  // }

  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('token') == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Login()),
          (Route<dynamic> route) => false);
    }
    if (sharedPreferences.getString('user_id') == '1') {
      setState(() {
        _isLoading = false;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => AdminPage()),
            (Route<dynamic> route) => false);
      });
    } else if (sharedPreferences.getString('user_id') == '2') {
      setState(() {
        _isLoading = false;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => DriverPage()),
            (Route<dynamic> route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.red, Color(0xff7F2A3C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      width: double.infinity,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoginSection(),
              ],
            ),
    ));
  }

  Future<void> _showDialog(String status) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: SingleChildScrollView(
            child: Text(
              " $status",
              style: TextStyle(color: Colors.black, fontSize: 18.0),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Container LoginSection() {
    return Container(
        child: Column(
      children: [
        Text(
          'DHATNOON',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 50, color: Colors.white70),
        ),
        SizedBox(
          height: 50,
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: textEmail("Email", Icons.email),
        ),
        Padding(
            padding: EdgeInsets.all(10),
            child: textPassword("Password", Icons.lock)),
        SizedBox(
          height: 40,
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red)),
            onPressed: () {
              // Navigator.of(context)
              //     .push(MaterialPageRoute(builder: (context) => AdminPage()));
              setState(() {
                _isLoading = true;
              });
              signIn(emailController.text, passwordController.text);
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 30, color: Colors.white70),
              ),
            )),
        SizedBox(
          height: 50,
        ),
      ],
    ));
  }

  signIn(String email, password) async {
    Map data = {"email": email, "password": password};
    var jsonData = null;
    var usertype = null;
    SharedPreferences.setMockInitialValues({});
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.post(Uri.parse(URL), body: data);
    jsonData = json.decode(response.body);

    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      usertype = jsonData["usertype"];
      if (usertype == 1) {
        setState(() {
          _isLoading = false;
          sharedPreferences.setString("token", jsonData['access_token']);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => AdminPage()),
              (Route<dynamic> route) => false);
        });
      } else {
        setState(() {
          _isLoading = false;
          sharedPreferences.setString("token", jsonData['access_token']);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => DriverPage()),
              (Route<dynamic> route) => false);
        });
      }
    } else {
      print(response.body);
      _isLoading = false;

      _showDialog("Wrong Credentials");
    }
  }

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  FocusNode myFocusNode = new FocusNode();

  TextFormField textEmail(String title, IconData icon) {
    return TextFormField(
        controller: emailController,
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
          // icon: Icon(icon)
        ));
  }

  TextFormField textPassword(String title, IconData icon) {
    return TextFormField(
        controller: passwordController,
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
          // icon: Icon(icon)
        ));
  }
}
