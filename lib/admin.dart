import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'driver.dart';
import 'login.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'userlist.dart';
import 'map.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String URL = "http://10.10.10.1:8000/api/auth/user_get";
  var items;
  var jsonData = null;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();

    getUsers();
  }

  checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('token') == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Login()),
          (Route<dynamic> route) => false);
    }
  }

  Future<List<Data>> getUsers() async {
    late List<dynamic> userData;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString('token');
    Map<String, String> data = {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    try {
      var response = await http.get(Uri.parse(URL), headers: data);
      // jsonData = json.decode(response.body) as List<dynamic>;
      Map<String, dynamic> map = json.decode(response.body);
      userData = map["data"];
      log('token: $userData');
    } catch (error) {
      log('error: $error');
    }
    return userData.map((e) => Data.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[400],
          title: Text("List of Drivers", style: TextStyle(color: Colors.white)),
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
        body: FutureBuilder(
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
                            // Container(
                            //   width: 50,
                            //   height: 50,
                            //   child: Image(
                            //     image:
                            //         NetworkImage(items[index].imageURL.toString()),
                            //     fit: BoxFit.fill,
                            //   ),
                            // ),

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
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    child: Text(
                                      items[index].email.toString(),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  )
                                ],
                              ),
                            )),
                            OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  primary: Colors.white,
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.red, width: 1),
                                ),
                                onPressed: () => viewPage(items[index].id),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    'View',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.red[600]),
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
        ));
  }

  viewPage(user_id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setString("user_id", user_id);
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => MapPage()),
          (Route<dynamic> route) => false);
    });
  }

  logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => Login()),
        (Route<dynamic> route) => false);
  }
}
