import 'dart:developer';
import 'dart:async';
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

class DriverPage extends StatefulWidget {
  const DriverPage({Key? key}) : super(key: key);

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int counter = 0;
  String _time1 = "Not set";
  String _time2 = "Not set";
  String _currentSettings = "Not Set";
  bool _isLoading = false;
  DateTime now = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Position? _currentPosition;
  @override
  void initState() {
    super.initState();
    Provider.of<LocationProvider>(context, listen: false).initialization();
    checkLoginStatus();

    Timer timer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => _getCurrentLocation());
  }

  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('token') == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Login()),
          (Route<dynamic> route) => false);
    }
  }

  static final CameraPosition initial =
      CameraPosition(target: LatLng(123.4, -122), zoom: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[400],
          title: Text("Location Live Settings",
              style: TextStyle(color: Colors.white)),
          actions: [
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
            // TimeSelect(),
            locationAllow(),
            SizedBox(
              height: 50.0,
            ),
            DataField(),
          ],
        )
        // body: TimeSelect(),
        // body: DataField()
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
        // googlemap(),
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
          padding: const EdgeInsets.all(30.0),
        ),
        Text(
          'Location Availability',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
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
              // locationUpdate(_time1, _time2);
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

  Container locationAllow() {
    return Container(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(30.0),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Text(
            'Allow Location Access from',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.red[600]),
          ),
        ),
        // SizedBox(
        //   height: 10.0,
        // ),
        Text(
          '$_time1',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.red[600]),
        ),
        Text(
          'to',
          textAlign: TextAlign.center,
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.red[600]),
        ),
        Text(
          '$_time2',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.red[600]),
        ),
        SizedBox(
          height: 40.0,
        ),
        Wrap(
          spacing: 25, // to apply margin in the main axis of the wrap
          runSpacing: 25,
          children: [
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red[50])),
                onPressed: () {
                  locationUpdateYes();
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Allow',
                    style: TextStyle(fontSize: 30, color: Colors.red[600]),
                  ),
                )),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.red[600])),
                onPressed: () {
                  locationUpdateNo();
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Deny',
                    style: TextStyle(fontSize: 30, color: Colors.red[50]),
                  ),
                )),
          ],
        ),
      ],
    ));
  }

  locationUpdateYes() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    var lat = _currentPosition!.latitude;
    var long = _currentPosition!.longitude;

    Map<String, dynamic> data = {
      "lat": lat.toString(),
      "long": long.toString(),
      "day_access": "1"
    };
    String URL = 'http://10.10.10.1:8000/api/auth/location_choice';
    var response = await http.post(Uri.parse(URL), body: data, headers: header);
    log('message: ${response.body}');
    if (response.statusCode == 201) {
      _showMyDialog();
    } else {
      print(response.body);
    }
  }

  locationUpdateNo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    var lat = _currentPosition!.latitude;
    var long = _currentPosition!.longitude;

    Map<String, dynamic> data = {
      "lat": lat.toString(),
      "long": long.toString(),
      "day_access": "0"
    };
    String URL = 'http://10.10.10.1:8000/api/auth/location_choice';
    var response = await http.post(Uri.parse(URL), body: data, headers: header);
    log('message: ${response.body}');
    if (response.statusCode == 201) {
      _showMyDialog();
    } else {
      print(response.body);
    }
  }

  locationUpdateBackground() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenCode = sharedPreferences.getString('token');
    Map<String, String> header = {
      "Accept": "application/json",
      "Authorization": "Bearer $tokenCode"
    };
    var lat = _currentPosition!.latitude;
    var long = _currentPosition!.longitude;

    Map<String, dynamic> data = {
      "lat": lat.toString(),
      "long": long.toString(),
    };
    String URL = 'http://10.10.10.1:8000/api/auth/location_save';

    var response = await http.post(Uri.parse(URL), body: data, headers: header);
    var json = jsonDecode(response.body);
    _currentSettings = json["status"].toString();
    _time1 = json["start_time"].toString();
    _time2 = json["end_time"].toString();
    log('status: $_currentSettings');
    if (response.statusCode == 201) {
    } else {
      print(response.body);
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Your Settings have been Updated.',
                    style: TextStyle(color: Colors.red)),
              ],
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

  _getCurrentLocation() {
    log('ref: $now');
    now = DateTime.now();
    locationUpdateBackground();

    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  Widget googlemap() {
    return Consumer<LocationProvider>(builder: (consumerContext, model, child) {
      // ignore: unnecessary_null_comparison
      if (model.locationpos != null)
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: initial,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController _controller) {},
        );
      else
        return Text('Errror');
    });
  }
}
