import 'dart:ffi';
import 'dart:math';

import 'package:dhatnoon/admin.dart';
import 'package:dhatnoon/driver.dart';
import 'package:dhatnoon/loginnew.dart';
import 'package:dhatnoon/viewpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'constants.dart';
import 'userlist.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isShowRequested = false;
  bool _isLogin = false;
  int _currentIndex = 0;
  String URL = "http://10.10.10.1:8000/api/auth/user_get";

  late Size _size;
  late AnimationController _animationController;
  late Animation<double> _animationTextRotate;

  void setUpAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: defaultDuration);
    _animationTextRotate =
        Tween<double>(begin: 0, end: 90).animate(_animationController);
  }

  void updateView() {
    setState(() {
      _isShowRequested = !_isShowRequested;
    });
    _isShowRequested
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  void initState() {
    setUpAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: _isShowRequested ? signup_bg : login_bg,
        title: _isShowRequested
            ? Text("Requested Menu", style: TextStyle(color: Colors.white))
            : Text("Requests Menu", style: TextStyle(color: Colors.white)),
        actions: [
          !_isShowRequested
              ? Column()
              : OutlinedButton(
                  onPressed: () {
                    // logOut();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.supervised_user_circle,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        Text(
                          'Add User',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ],
                    ),
                  )),
          OutlinedButton(
              onPressed: () {
                logOut();
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              )),
        ],
      ),
      body: Container(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(login_bg)))
              : bodyContent()),
      bottomNavigationBar: bottomNav(),
    );
  }

//Body builder content

  bodyContent() {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return Stack(
            children: [
              AnimatedPositioned(
                  duration: defaultDuration,
                  top: _size.height * 0,
                  left: 0,
                  right: _isShowRequested
                      ? -_size.width * 0.06
                      : _size.width * 0.06,
                  child: Column()),
              AnimatedPositioned(
                duration: defaultDuration,
                width: _size.width * 1,
                height: _size.height,
                left: _isShowRequested ? -_size.width * 1 : _size.width * 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: null,
                  child: Container(
                    color: login_bg_light,
                    child: requests(),
                  ),
                ),
              ),
              AnimatedPositioned(
                  duration: defaultDuration,
                  width: _size.width * 1,
                  height: _size.height,
                  left: _isShowRequested ? _size.width * 0 : _size.width * 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: null,
                    child: Container(
                      color: signup_bg_lignt,
                      child: requested(),
                    ),
                  )),
            ],
          );
        });
  }

//Requested Section

  Future<List<Data>> getUserRequested() async {
    // late List<dynamic> userData;
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // var token = sharedPreferences.getString('token');
    // Map<String, String> data = {
    //   "Accept": "application/json",
    //   "Authorization": "Bearer $token"
    // };
    // try {
    //   var response = await http.get(Uri.parse(URL), headers: data);
    //   // jsonData = json.decode(response.body) as List<dynamic>;
    //   Map<String, dynamic> map = json.decode(response.body);
    //   userData = map["data"];
    //   // log('token: $userData');
    // } catch (error) {
    //   // log('error: $error');
    // }
    // return userData.map((e) => Data.fromJson(e)).toList();

//Dummy Data Injection

    List<Data> userData = <Data>[
      Data(
        id: "1",
        name: 'user1',
        email: "ads@sd.cd",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
      Data(
        id: "1",
        name: 'user2',
        email: "ads@sd.cd",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
      Data(
        id: "1",
        name: 'user3',
        email: "ads@sd.cd",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
    ];

    return userData;
  }

  FutureBuilder requested() {
    return FutureBuilder(
      future: getUserRequested(),
      builder: (context, data) {
        if (data.hasError) {
          return Center(child: Text("${data.error}"));
        } else if (data.hasData) {
          var items = data.data as List<Data>;
          return ListView.builder(
              itemCount: items == null ? 0 : items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  items[index].name.toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: signup_bg,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  items[index].email.toString(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: signup_bg,
                                      fontWeight: FontWeight.normal),
                                ),
                              )
                            ],
                          ),
                        )),
                        OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              primary: signup_bg_lignt,
                              backgroundColor: signup_bg_lignt,
                              side: BorderSide(color: signup_bg, width: 1),
                            ),
                            onPressed: () => permissionPage(items[index].id),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                'View Status',
                                style:
                                    TextStyle(fontSize: 20, color: signup_bg),
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(signup_bg)),
          );
        }
      },
    );
  }

  permissionPage(user_id) async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // sharedPreferences.setString("user_id", user_id);
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => ViewPage()),
          (Route<dynamic> route) => false);
    });
  }

//Requeests section

  Future<List<Data>> getUserRequests() async {
    // late List<dynamic> userData;
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // var token = sharedPreferences.getString('token');
    // Map<String, String> data = {
    //   "Accept": "application/json",
    //   "Authorization": "Bearer $token"
    // };
    // try {
    //   var response = await http.get(Uri.parse(URL), headers: data);
    //   // jsonData = json.decode(response.body) as List<dynamic>;
    //   Map<String, dynamic> map = json.decode(response.body);
    //   userData = map["data"];
    //   // log('token: $userData');
    // } catch (error) {
    //   // log('error: $error');
    // }
    // return userData.map((e) => Data.fromJson(e)).toList();

//Dummy Data Injection

    List<Data> userData = <Data>[
      Data(
        id: "1",
        name: 'User1',
        email: "ads@sd.cd",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
      Data(
        id: "1",
        name: 'User2',
        email: "ads@sd.cd",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
      Data(
        id: "1",
        name: 'User3',
        email: "ads@sd.cd",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
      Data(
        id: "1",
        name: 'User4',
        email: "ads@sd.cd",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
      Data(
        id: "1",
        name: 'User5',
        email: "ads@sd.cd",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
    ];

    return userData;
  }

  FutureBuilder requests() {
    return FutureBuilder(
      future: getUserRequests(),
      builder: (context, data) {
        if (data.hasError) {
          return Center(child: Text("${data.error}"));
        } else if (data.hasData) {
          var items = data.data as List<Data>;
          return ListView.builder(
              itemCount: items == null ? 0 : items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  items[index].name.toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  // items[index].email.toString(),
                                  "Asked for Location access between 12.00 to 16.00",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  // items[index].email.toString(),
                                  "Denied",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.red,
                                      fontWeight: FontWeight.normal),
                                ),
                              )
                            ],
                          ),
                        )),
                        Wrap(
                          spacing:
                              25, // to apply margin in the main axis of the wrap
                          runSpacing: 25,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                primary: login_bg,
                                backgroundColor: login_bg_light,
                                side: BorderSide(color: login_bg, width: 1),
                                shape: StadiumBorder(),
                              ),
                              onPressed: null,
                              child: Icon(
                                Icons.check,
                                color: login_bg,
                                size: 30.0,
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                primary: login_bg,
                                backgroundColor: Colors.red[50],
                                side: BorderSide(color: Colors.red, width: 1),
                                shape: StadiumBorder(),
                              ),
                              onPressed: null,
                              child: Icon(
                                Icons.block,
                                color: Colors.red[600],
                                size: 30.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(login_bg)),
          );
        }
      },
    );
  }

  // Bottom Nav Section

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 0) {
        _isShowRequested = false;
      } else {
        _isShowRequested = true;
      }
    });
  }

  bottomNav() {
    return BottomNavigationBar(
      fixedColor: Colors.black,
      backgroundColor: _isShowRequested ? signup_bg_lignt : login_bg_light,
      // selectedItemColor: _isShowRequested ? signup_bg : login_bg,
      // unselectedItemColor: _isShowRequested ? login_bg : signup_bg,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
      currentIndex: _currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.verified,
            color: login_bg,
          ),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.notifications,
            color: signup_bg,
          ),
          label: 'Requested',
        )
      ],
    );
  }

  //Logout function
  logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => LoginNew()),
        (Route<dynamic> route) => false);
  }
}
