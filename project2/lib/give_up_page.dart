import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'welcome_page.dart'; // WelcomePageへの遷移先
import 'destination.dart';

class GiveUpPage extends StatefulWidget {
  final List<LatLng> routePoints;
  final LatLng destination;
  final List<Hint> hints;
  final String goal_name;
  final String goal_description;
  final String goal_relation;
  const GiveUpPage({
    Key? key,
    required this.routePoints,
    required this.destination,
    required this.hints,
    required this.goal_name,
    required this.goal_description,
    required this.goal_relation,
  }) : super(key: key);

  @override
  _GiveUpPageState createState() => _GiveUpPageState();
}

class _GiveUpPageState extends State<GiveUpPage> {
  late GoogleMapController _mapController;
  final MarkerId currentLocationMarkerId = MarkerId('current_location');
  List<Hint> _updatedHints = []; // ヒントの状態を保持するリスト
  Timer? _timer;
  bool _isOrangePinVisible = true;

  @override
  void initState() {
    super.initState();
    _updatedHints = List.from(widget.hints); // ヒントリストをコピーして初期化
    _startPinAnimation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Set<Polyline> polylines = Set<Polyline>.from([
      Polyline(
        polylineId: PolylineId('route'),
        points: widget.routePoints,
        color: Colors.blue,
        width: 30,
      ),
    ]);

    void _updateHintStatus(int hintIndex) {
      setState(() {
        List<Hint> updatedHints = List.from(widget.hints); // ヒントリストのコピーを作成
        updatedHints[hintIndex] = Hint(
          name: widget.hints[hintIndex].name,
          location: widget.hints[hintIndex].location,
          description: widget.hints[hintIndex].description,
          found: true, // foundをtrueに設定
        );

        // _updatedHintsを更新したヒントリストで置き換える
        _updatedHints = updatedHints;
      });
    }

    // ピンのリストを作成
    List<Marker> markers = [
      Marker(
        markerId: MarkerId('destination'),
        position: widget.destination,
        icon: _isOrangePinVisible
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(widget.goal_name),
                content: SingleChildScrollView(
                  child: Text(widget.goal_description),
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
        },
      ),
    ];

    // ヒントからピンを作成し、リストに追加
    for (var hint in _updatedHints) {
      markers.add(
        Marker(
          markerId: MarkerId(hint.name),
          position: hint.location,
          icon: hint.found
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : BitmapDescriptor.defaultMarker,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(hint.name),
                  content: SingleChildScrollView(
                    child: Text(hint.description),
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
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('探索失敗!'),
        automaticallyImplyLeading: false, // 戻るボタンを非表示にする
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.routePoints.first,
          zoom: 15,
        ),
        markers: Set<Marker>.from(markers), // ピンのリストを設定
        polylines: polylines,
        onMapCreated: (controller) {
          _mapController = controller;
          _showRoute();
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
          },
          child: Text('最初に戻る'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('テーマとなった人物'),
                content: Text(widget.goal_relation),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.info),
      ),
    );
  }

  void _startPinAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _isOrangePinVisible = !_isOrangePinVisible;
      });
    });
  }

  void _showRoute() {
    for (var point in widget.routePoints) {
      print('Latitude: ${point.latitude}, Longitude: ${point.longitude}');
    }
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: widget.routePoints.first,
          northeast: widget.routePoints.last,
        ),
        50,
      ),
    );
  }

  void _updateHintStatus(int hintIndex) {
    setState(() {
      _updatedHints[hintIndex].found = true;
    });
  }
}