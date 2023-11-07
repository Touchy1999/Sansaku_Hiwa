import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:project2/destination.dart';
import 'package:project2/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'second_page.dart';
import 'welcome_page.dart';
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' show cos, sqrt, asin, atan2, pi;
import 'package:http/http.dart' as http;
import 'dart:convert';

String calculateDirection(LatLng start, LatLng end) {
  double lat1 = start.latitude;
  double lon1 = start.longitude;
  double lat2 = end.latitude;
  double lon2 = end.longitude;

  double dLon = lon2 - lon1;

  if (dLon > 180) {
    dLon -= 360;
  } else if (dLon < -180) {
    dLon += 360;
  }

  double angle = (180 / pi) * atan2(dLon, lat2 - lat1);
  if (angle < 0) {
    angle += 360;
  }

  if ((angle >= 315 && angle <= 360) || (angle >= 0 && angle < 45)) {
    return "北";
  } else if (angle >= 45 && angle < 135) {
    return "東";
  } else if (angle >= 135 && angle < 225) {
    return "南";
  } else {
    return "西";
  }
}

double calculateDistance(LatLng start, LatLng end) {
  double lat1 = start.latitude;
  double lon1 = start.longitude;
  double lat2 = end.latitude;
  double lon2 = end.longitude;

  double p = 0.017453292519943295; // 1度あたりのラジアン値

  double a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) *
          cos(lat2 * p) *
          (1 - cos((lon2 - lon1) * p)) /
          2;

  double distance = 2 * 6371 * asin(sqrt(a)); // 地球の直径 * asinの結果

  return distance;
}

class SecondPage extends StatelessWidget {
  /*
  Future<Map<String, dynamic>> _loadData() async {
    final jsonString = await rootBundle.loadString('assets/data2.json');
    return json.decode(jsonString);
  }
  */
  final Map<String, dynamic> responseData;
  SecondPage({required this.responseData});
  /*
  Future<Map<String, dynamic>> _loadData() async {
    var url = "http://20.210.139.133/story/"; // サーバーのURLに変更する
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // レスポンスがOKの場合はJSONをデコードして返す
      return json.decode(response.body);
    } else {
      // エラーの場合は例外をスロー
      throw Exception('Failed to load data from server');
    }
  }
  */
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: Future.value(responseData),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('データの読み込みエラー'),
            );
          } else {
            final res_data = snapshot.data!;
            // データの取り出し
            final goal = res_data['goal'];
            print(goal);
            print('ssss');
            final latitude = goal['lat'];
            final longitude = goal['lng'];
            LatLng destination = LatLng(latitude, longitude);
            final String goal_name = goal['name'];
            final String goal_description = goal['description'];
            final String goal_relation = goal['relation'];

            return FutureBuilder<Position>(
              future: Geolocator.getCurrentPosition(),
              builder: (context, currentPositionSnapshot) {
                if (currentPositionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (currentPositionSnapshot.hasError) {
                  return Center(
                    child: Text('現在位置の取得エラー'),
                  );
                } else {
                  final currentPosition = currentPositionSnapshot.data!;
                  LatLng currentLocation = LatLng(
                    currentPosition.latitude,
                    currentPosition.longitude,
                  );

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '目的地が決定しました。',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '距離は${calculateDistance(currentLocation, destination).toStringAsFixed(2)}kmです。',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '方角は${calculateDirection(currentLocation, destination)}です。',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            _navigateToComingPage(context, destination, goal_name, goal_description, goal_relation, res_data);
                          },
                          child: Text('この目的地に向かう'),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _navigateToSecondPage(context);
                          },
                          child: Text('再度検索しなおす'),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToComingPage(BuildContext context, LatLng destination, String goal_name, String goal_description, String goal_relation, Map<String, dynamic> res_data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComingPage(
          destination: destination,
          goal_name: goal_name,
          goal_description: goal_description,
          goal_relation: goal_relation,
          res_data: res_data,
        ),
      ),
    );
  }


  void _navigateToSecondPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
    );
  }
}