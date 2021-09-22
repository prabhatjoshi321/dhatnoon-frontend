import 'dart:developer';
import 'dart:async';
import 'dart:ffi';
import 'package:dhatnoon/admin.dart';
import 'package:dhatnoon/locationprovider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  int counter = 0;
  var user_id = null;
  String _time1 = "Not set";
  String _time2 = "Not set";
  double lat = 0;
  double long = 0;
  var jsonData;
  String _currentSettings = "Not Set";
  bool _isLoading = false;
  DateTime now = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Position? _currentPosition;
  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    Provider.of<LocationProvider>(context, listen: false).initialization();
    checkLoginStatus();
    checkLocationStatus();
  }

  checkLocationStatus() async {
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
    log("rew: ${response.body}");
    _currentSettings = jsonData['day_access'];
  }

  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('token') == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Login()),
          (Route<dynamic> route) => false);
    }
    user_id = sharedPreferences.getString('user_id');
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
    log("rew: $lat");
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

  static final CameraPosition initial =
      CameraPosition(target: LatLng(123.4, -122), zoom: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[400],
        title: Text("Request", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()),
              );
            },
          ),
          OutlinedButton(
              onPressed: () {
                logOut();
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ))
        ],
      ),
      body: Column(
        children: [
          TimeSelect(),
          //  DataField()
        ],
      ),
      // Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       if (_currentPosition != null)
      //         Text(
      //             "LAT: ${_currentPosition!.latitude}, LNG: ${_currentPosition!.longitude}"),
      //       FlatButton(
      //         child: Text("Get location"),
      //         onPressed: () {
      //           log('ref: $now');

      //           _getCurrentLocation();
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

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

  logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => Login()),
        (Route<dynamic> route) => false);
  }

  Container TimeSelect() {
    return Container(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
        ),
        Text(
          'Location Availability',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.red[600]),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Start Time",
                  style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () {
                    DatePicker.showTimePicker(context,
                        theme: DatePickerTheme(
                          containerHeight: 210.0,
                        ),
                        showTitleActions: true, onConfirm: (time1) {
                      print('confirm $time1');
                      _time1 =
                          '${time1.hour} : ${time1.minute} : ${time1.second}';
                      setState(() {});
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.access_time,
                                    size: 18.0,
                                    color: Colors.red[600],
                                  ),
                                  Text(
                                    " $_time1",
                                    style: TextStyle(
                                        color: Colors.red[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Text(
                          "  Change",
                          style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  "End Time",
                  style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  onPressed: () {
                    DatePicker.showTimePicker(context,
                        theme: DatePickerTheme(
                          containerHeight: 210.0,
                        ),
                        showTitleActions: true, onConfirm: (time2) {
                      print('confirm $time2');
                      _time2 =
                          '${time2.hour} : ${time2.minute} : ${time2.second}';
                      setState(() {});
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                    setState(() {});
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.access_time,
                                    size: 18.0,
                                    color: Colors.red[600],
                                  ),
                                  Text(
                                    " $_time2",
                                    style: TextStyle(
                                        color: Colors.red[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Text(
                          "  Change",
                          style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 40.0,
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red[50])),
            onPressed: () {
              // Navigator.of(context)
              //     .push(MaterialPageRoute(builder: (context) => AdminPage()));
              // setState(() {
              //   _isLoading = true;
              // });
              timeUpdate(_time1, _time2);
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Update',
                style: TextStyle(fontSize: 30, color: Colors.red[600]),
              ),
            )),
      ],
    ));
  }

  timeUpdate(String time1, time2) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    var id = sharedPreferences.getString('user_id');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };

    Map<String, dynamic> data = {
      "user_id": id,
      "start_time":
          "${now.year}-${now.month}-${now.day} " + time1.replaceAll(' ', ''),
      "end_time":
          "${now.year}-${now.month}-${now.day} " + time2.replaceAll(' ', ''),
      "day_access": "1"
    };
    String URL = 'http://10.10.10.1:8000/api/auth/location_request';
    log("month: ${now.year}-${now.month}-${now.day} ");
    var response = await http.post(Uri.parse(URL), body: data, headers: header);
    log('message: ${response.body}');
    var json = jsonDecode(response.body);
    if (response.statusCode == 201) {
      _currentSettings = json["status"].toString();
      log('message: $_currentSettings');

      _showDialog("Request Sent Successfully");
      // DataField();
    } else {
      print(response.body);
      _showDialog("Time not Set");
    }
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

  Container DataField() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentPosition != null)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    Text(
                      "LAT: ${_currentPosition!.latitude}\nLONG: ${_currentPosition!.longitude}\nTIME: $now",
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Current Status: ",
              style: TextStyle(color: Colors.red, fontSize: 15),
            ),
            if (_currentSettings == "0") Text("Denied"),
            if (_currentSettings == "1") Text(" Allowed")
          ],
        ),
      ),
    );
  }
}
