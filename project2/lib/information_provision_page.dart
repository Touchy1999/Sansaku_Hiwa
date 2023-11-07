import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProvidePage extends StatefulWidget {
  const ProvidePage();

  @override
  _ProvidePageState createState() => _ProvidePageState();
}

class _ProvidePageState extends State<ProvidePage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  LatLng? _selectedLocation;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _nameController1 = TextEditingController();
  TextEditingController _nameController2 = TextEditingController();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _name1FocusNode = FocusNode();
  FocusNode _name2FocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _nameController.dispose();
    _nameController1.dispose();
    _nameController2.dispose();
    _nameFocusNode.dispose();
    _name1FocusNode.dispose();
    _name2FocusNode.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result != LocationPermission.whileInUse &&
          result != LocationPermission.always) {
        print('位置情報へのアクセス許可が拒否されました');
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _submitPost() {
    final String name = _nameController.text;
    final String place = _nameController1.text;
    final String details = _nameController2.text;
    final LatLng position = _selectedLocation ?? LatLng(0.0, 0.0);
    // 投稿の処理を実行
    // ここでデータを送信したり保存したりするなどの操作を行います

    final data = {
      'name': place,
      'lat': _selectedLocation?.latitude, // LatLngオブジェクトをJSONに変換
      'lng': _selectedLocation?.longitude, // LatLngオブジェクトをJSONに変換
      'description': details,
      'relation': name,
    };

    final jsonData = jsonEncode(data);

    // URLを自分のサーバーのエンドポイントに置き換えてください
    final url = 'http://20.210.139.133/spot/';

    // 認証情報（'admin:password123'）を適切な値に更新してください
    final headers = {
      //'Authorization': 'Basic ' + base64Encode(utf8.encode('admin:password123')),
      'Content-Type': 'application/json; charset=utf-8',
    };

    http.post(Uri.parse(url), headers: headers, body: jsonData).then((response) {
      if (response.statusCode == 200) {
        // データを正常に送信しました
        // 必要に応じてここでレスポンスを処理してください
        print('POSTリクエストが成功しました');
      } else {
        // データの送信に失敗しました
        print('POSTリクエストの送信に失敗しました: ${response.statusCode}');
      }
    }).catchError((error) {
      // POSTリクエストの送信中にエラーが発生しました
      print('POSTリクエストの送信エラー: $error');
    });

    // フォームをリセット
    _nameController.clear();
    _nameController1.clear();
    _nameController2.clear();
    _nameFocusNode.requestFocus();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('情報提供ページ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '場所の名前',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextField(
                      controller: _nameController1,
                      decoration: InputDecoration(
                        hintText: '場所の名前を入力してください',
                      ),
                      focusNode: _name1FocusNode,
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(_name1FocusNode);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '偉人の名前',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: '偉人の名前を入力してください',
                      ),
                      focusNode: _nameFocusNode,
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(_name2FocusNode);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '現在地と偉人の詳細な関連',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextField(
                      controller: _nameController2,
                      decoration: InputDecoration(
                        hintText: '現在地と偉人の詳細な関連を入力してください',
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      focusNode: _name2FocusNode,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _selectedLocation != null
                  ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation!,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('selected_location'),
                    position: _selectedLocation!,
                  ),
                },
                onTap: (LatLng location) {
                  _selectLocation(location);
                },
              )
                  : Container(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('投稿する'),
            ),
          ],
        ),
      ),
    );
  }
}