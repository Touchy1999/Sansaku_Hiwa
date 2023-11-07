import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:geolocator_2/geolocator_2.dart;
import 'dart:math' show cos, sqrt, asin, atan2, pi;
import 'give_up_page.dart';
import 'success_page.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dart:convert' show utf8;


//final LatLng destination = LatLng(35.0036519, 135.7785508);

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

class Hint {
  final String name;
  final LatLng location;
  final String description;
  bool found;
  Hint({required this.name, required this.location, required this.description, required this.found});

  void setFound(bool value) {
    found = value;
  }
}

class ComingPage extends StatefulWidget {
  final LatLng destination;
  final String goal_name;
  final String goal_description;
  final String goal_relation;
  final Map<String, dynamic> res_data;
  ComingPage({required this.destination, required this.goal_name, required this.goal_description, required this.goal_relation, required this.res_data});
  /*
  Future<Map<String, dynamic>> _loadData() async {
    final jsonString = await rootBundle.loadString('assets/data2.json');
    return json.decode(jsonString);
  }
  */

  @override
  _ComingPageState createState() => _ComingPageState();
}

class _ComingPageState extends State<ComingPage> {
  late Map<String, dynamic> res_data;
  late LatLng destination; // 追加
  GoogleMapController? mapController;
  LatLng? currentLocation;
  LatLng initialLocation = LatLng(0, 0); // 初期の緯度経度
  Set<Marker> markers = Set<Marker>();
  String distanceText = '';
  List<LatLng> routePoints = []; //ユーザの移動経路
  List<CameraDescription> cameras = [];
  late CameraController _controller;
  late Future<void> _initializeCameraControllerFuture = _initializeCamera();
  TextEditingController _memoController = TextEditingController();
  List<Hint> hints = [];

  Future<List<Hint>> _loadHints() async {

    final jsonData = widget.res_data;
    List<Hint> hints = [];

    if (jsonData['hints'] is List) {
      (jsonData['hints'] as List).forEach((value) {
        final name = value['name'];
        final latitude = value['lat'];
        final longitude = value['lng'];
        final description = value['description'];
        bool found = false;

        final hint = Hint(
          name: name,
          location: LatLng(latitude, longitude),
          description: description,
          found: found,
        );

        hints.add(hint);
      });
    }

    return hints;
  }



  StreamSubscription<Position>? positionStreamSubscription;

  @override

  Future<void> _startLocationUpdates() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        double distance = calculateDistance(currentLocation!, destination);
        String direction = calculateDirection(currentLocation!, destination);
        //distanceText = '${currentLocation?.latitude.toStringAsFixed(12)}';
        distanceText = '目的地まで約 ${distance.toStringAsFixed(10)} kmです。方角は ${direction} です。';
        markers.add(
          Marker(
            markerId: MarkerId('スタート位置'),
            position: initialLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(180),
            infoWindow: InfoWindow(
              title: 'スタート位置',
              snippet: '初期位置',
            ),
          ),
        );


        int hintCount = hints.length;
        for (int i = 0; i < hintCount; i++) {
          String hintTitle = 'ヒント' + (i + 1).toString();
          _changeMarker(i, hints[i].location, hintTitle, BitmapDescriptor.defaultMarker, hints[i].found);
        }


      });
    });
  }

  void initState() {
    super.initState();
    _getCurrentLocation();
    //_initializeCameraControllerFuture = _initializeCamera();// カメラの初期化
    destination = widget.destination; // 追加
    _startLocationUpdates();
    _loadHints().then((loadedHints) {
      setState(() {
        hints = loadedHints;
      });
    });
    int hintCount = hints.length;
    for (int i = 0; i < hintCount; i++) {
      String hintTitle = 'ヒント' + (i + 1).toString();
      _addMarker(i, hints[i].location, hintTitle, BitmapDescriptor.defaultMarker, hints[i].found);
    }
  }



  @override
  void dispose() {
    _controller.dispose();
    positionStreamSubscription?.cancel();
    super.dispose();
  }



  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      await _controller.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      initialLocation = currentLocation!;
      routePoints = [initialLocation];
    });
  }


  void _addMarker(int i, LatLng location, String title, BitmapDescriptor icon, bool found) {
    double dis = calculateDistance(location, currentLocation!);
    String snippetText = 'あと ${dis.toStringAsFixed(10)} kmです';
    Widget snippet = SingleChildScrollView(
      child: Column(
        children: [
          Text(snippetText),
          SizedBox(height: 16),
        ],
      ),
    );


    markers.add(
      Marker(
        markerId: MarkerId(title),
        position: location,
        icon: icon,
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: snippet,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        },
        infoWindow: InfoWindow(
          title: title,
          snippet: snippetText,
        ),
      ),
    );
  }

  void _changeMarker(int i, LatLng location, String title, BitmapDescriptor icon, bool found) {
    double dis = calculateDistance(location, currentLocation!);
    String snippetText = "";


    if(found || dis < 0.5) {
      title = hints[i].name;
      snippetText = hints[i].description;
      found = true;
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      Widget snippet = SingleChildScrollView(
        child: Column(
          children: [
            Text(snippetText),
            SizedBox(height: 16),
          ],
        ),
      );

      markers.add(
        Marker(
          markerId: MarkerId(title),
          position: location,
          icon: icon,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(title),
                  content: snippet,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          infoWindow: InfoWindow(
            title: title,
            snippet: "タップして詳細を確認",//snippetText,
          ),
        ),
      );

    }
    // ヒントがまだ解放されていない場合のみ、解放処理を行います
    else if (dis <= 0.5 && found == false /*&& !markers.any((marker) => marker.markerId.value == title)*/) {
      hints[i].setFound(true);
      //routePoints.add(currentLocation!);
      title = hints[i].name;
      found = true;
      snippetText = hints[i].description;
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue); // マーカーの色を青色に変更します
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ヒントに到着しました'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text('ヒント${(i+1).toString()} が解放されました'),
                  SizedBox(height: 16),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    else if (!found){
      snippetText = 'あと ${dis.toStringAsFixed(10)} kmです';
      Widget snippet = SingleChildScrollView(
        child: Column(
          children: [
            Text(snippetText),
            SizedBox(height: 16),
          ],
        ),
      );


      markers.add(
        Marker(
          markerId: MarkerId(title),
          position: location,
          icon: icon,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(title),
                  content: snippet,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          infoWindow: InfoWindow(
            title: title,
            snippet: snippetText,
          ),
        ),
      );

    }


  }

  void _handleDestinationReached() {
    double distance = calculateDistance(currentLocation!, destination);

    if (distance < 0.5) {
      // 距離が100m未満なので成功とみなす
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(routePoints: routePoints, destination: destination, hints: hints, goal_name: widget.goal_name, goal_description: widget.goal_description, goal_relation: widget.goal_relation),
        ),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('おめでとうございます！'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('目的地に到着しました。'),
                SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // 距離が100m以上なので距離差を表示する
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('残念！'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('目的地まで約 ${distance.toStringAsFixed(2)} kmです。'),
                SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


  Future<void> _showConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('操作を選択してください'),
          actions: [
            TextButton(
              onPressed: _handleDestinationReached,
              child: Text('ここが目的地である'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GiveUpPage(routePoints: routePoints, destination: destination, hints: hints, goal_name: widget.goal_name, goal_description: widget.goal_description, goal_relation: widget.goal_relation)),
                );
              },
              child: Text('途中だがあきらめる'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('目的地に向かう'),
        leading: Container(), // 戻るボタンを無効化
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('自由メモ欄'),
                    content: TextField(
                      controller: _memoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'ここにメモを入力してください',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          String memo = _memoController.text;
                          // メモの内容を利用するなどの処理を行うことができます
                          print('メモ: $memo');
                          Navigator.of(context).pop();
                        },
                        child: Text('保存'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('キャンセル'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              distanceText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: currentLocation != null
                ? GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  mapController = controller;
                });
              },
              myLocationEnabled: true,
              markers: markers,
            )
                : Container(),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // ボタンの位置を右下に設定
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 56.0,
          child: ElevatedButton(
            onPressed: () {
              _showConfirmationDialog();
            },
            child: Text(
              '終了する',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}