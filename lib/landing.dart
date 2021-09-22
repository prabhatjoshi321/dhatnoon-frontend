import 'package:dhatnoon/admin.dart';
import 'package:dhatnoon/driver.dart';
import 'package:flutter/material.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff261C2C),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AdminPage()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Admin',
                    style: TextStyle(fontSize: 34),
                  ),
                )),
            SizedBox(
              height: 50,
            ),
            OutlinedButton(
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(2),
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => DriverPage()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Driver',
                    style: TextStyle(color: Colors.white, fontSize: 35),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
