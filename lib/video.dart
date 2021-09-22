import 'dart:ffi';
import 'dart:math';

import 'package:dhatnoon/admin.dart';
import 'package:dhatnoon/driver.dart';
import 'package:dhatnoon/loginnew.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'constants.dart';
import 'userlist.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isShowCamera = false;
  bool _isLogin = false;
  int _currentIndex = 0;
  String URL = "http://10.10.10.1:8000/api/auth/user_get";

  //Location Variables
  var user_id = null;
  var jsonData;

  double lat = 0;
  double long = 0;
  Position? _currentPosition;
  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};

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
      _isShowCamera = !_isShowCamera;
    });
    _isShowCamera
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
        backgroundColor: _isShowCamera ? signup_bg : login_bg,
        title: _isShowCamera
            ? Text("Camera And Audio", style: TextStyle(color: Colors.white))
            : Text("Location", style: TextStyle(color: Colors.white)),
        actions: [
          OutlinedButton(
              onPressed: () {
                // logOut();
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.timelapse,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    Text(
                      'Request',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              )),
          OutlinedButton(
              onPressed: () {
                // logOut();
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
                  right:
                      _isShowCamera ? -_size.width * 0.06 : _size.width * 0.06,
                  child: Column()),
              AnimatedPositioned(
                duration: defaultDuration,
                width: _size.width * 1,
                height: _size.height,
                left: _isShowCamera ? -_size.width * 1 : _size.width * 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: updateView,
                  child: Container(
                    color: login_bg_light,
                    child: location(),
                  ),
                ),
              ),
              AnimatedPositioned(
                  duration: defaultDuration,
                  width: _size.width * 1,
                  height: _size.height,
                  left: _isShowCamera ? _size.width * 0 : _size.width * 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: updateView,
                    child: Container(
                      color: signup_bg_lignt,
                      child: cameraAndAudio(),
                    ),
                  )),
            ],
          );
        });
  }

//Requested Section

  Future<List<Data>> getUsers() async {
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
        name: 'Camera',
        email: "View Camera",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
      Data(
        id: "1",
        name: 'Video',
        email: "Live Video Feed",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
      Data(
        id: "1",
        name: 'Audio',
        email: "Live Audio Feed",
        usertype: "1",
        created_at: "1234",
        updated_at: "asdf",
      ),
    ];

    return userData;
  }

  FutureBuilder cameraAndAudio() {
    return FutureBuilder(
      future: getUsers(),
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
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  "Denied",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.red,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
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
                                'View',
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          );
        }
      },
    );
  }

  permissionPage(user_id) async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // sharedPreferences.setString("user_id", user_id);
    // setState(() {
    //   Navigator.of(context).pushAndRemoveUntil(
    //       MaterialPageRoute(builder: (BuildContext context) => ViewPage()),
    //       (Route<dynamic> route) => false);
    // });
  }

//Location section

  Container map() {
    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };

    Map<String, dynamic> data = {
      "user_id": user_id,
    };

    String URL = 'http://10.10.10.1:8000/api/auth/user_check';
    var response = await http.post(Uri.parse(URL), body: data, headers: header);
    jsonData = jsonDecode(response.body);
    lat = double.parse(jsonData['lat']);
    long = double.parse(jsonData['long']);
    // log("rew: $lat");
    DateTime start_time = DateTime.parse(jsonData["start_time"]);
    DateTime end_time = DateTime.parse(jsonData["end_time"]);
    String status = jsonData["day_access"].toString();

    // log("rwwwwew: $status, $start_time, $end_time");

    if (status == "0") {
      // _showDialog("User Has not given Location Access");
    } else {
      setState(() {
        mapController = controller;
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 270.0,
              target: LatLng(lat, long),
              tilt: 30.0,
              zoom: 18.0,
            ),
          ),
        );
        _markers.clear();
        final marker = Marker(
          markerId: MarkerId("User"),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: "Location",
            snippet: "office.address",
          ),
        );
        _markers["User"] = marker;
      });
    }
  }

  Container location() {
    return map();
  }

  // Bottom Nav Section

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 0) {
        _isShowCamera = false;
      } else {
        _isShowCamera = true;
      }
    });
  }

  bottomNav() {
    return BottomNavigationBar(
      fixedColor: Colors.black,
      backgroundColor: _isShowCamera ? signup_bg_lignt : login_bg_light,
      // selectedItemColor: _isShowCamera ? signup_bg : login_bg,
      // unselectedItemColor: _isShowCamera ? login_bg : signup_bg,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
      currentIndex: _currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.location_history,
            color: login_bg,
          ),
          label: 'Location',
        ),
        BottomNavigationBarItem(
          icon: new Icon(
            Icons.camera_alt_rounded,
            color: signup_bg,
          ),
          label: 'Camera & Audio',
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
