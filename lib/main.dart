import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedometer/pedometer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _stepCountValue = "Unknown";
  String _km = "Unknown";
  String _calories = "Unknown";
  StreamSubscription<StepCount>? _subscription;

  double? _numerox; // step count
  double? _kmx; // num kilometer
  double? burnedx; // calories burned

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus activityRecognitionStatus = await Permission.activityRecognition.request();
    if (activityRecognitionStatus == PermissionStatus.granted) {
      setUpPedometer();
    } else {
      // Maneja el caso en el que no se otorgaron los permisos
      print("Permission not granted.");
    }
  }

  void setUpPedometer() {
    _subscription = Pedometer.stepCountStream.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  void _onDone() {}

  void _onError(error) {
    print("Flutter Pedometer error: $error");
  }

  void _onData(StepCount stepCountValue) {
    print(stepCountValue.steps);
    setState(() {
      _stepCountValue = "${stepCountValue.steps}";
    });

    double distance = stepCountValue.steps.toDouble();

    setState(() {
      _numerox = distance;
    });

    double long3 = distance / 100;
    long3 = double.parse(long3.toStringAsFixed(4));
    long3 = long3 / 1000;
    getDistanceRun(distance);
  }

  void getDistanceRun(double numerox) {
    double distance = (numerox * 78) / 100000;
    distance = double.parse(distance.toStringAsFixed(2));
    setState(() {
      _km = "$distance";
      print(_km);
      _kmx = distance * 30;
    });
  }

  void getBurnedRun() {
    setState(() {
      _calories = "$_km";
      print(_calories);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Step Count App'),
          backgroundColor: Colors.pinkAccent,
        ),
        body: Container(
          color: Colors.white24,
          child: ListView(
            padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10.0),
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFFA9F5F2), Color(0xFF01DFD7)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(27.0)),
                ),
                child: CircularPercentIndicator(
                  radius: 150.0,
                  lineWidth: 13.0,
                  animation: true,
                  center: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.walking,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '$_stepCountValue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.purpleAccent,
                        ),
                      )
                    ],
                  ),
                  percent: _numerox != null ? (_numerox! / 10000) : 0.0, // Assuming 10000 steps is 100%
                  progressColor: Colors.purpleAccent,
                  backgroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
