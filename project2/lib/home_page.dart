import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'second_page.dart';
import 'welcome_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


int parseInt(String value) {
  return int.parse(value);
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _selectedItem;
  LatLng? _selectedLocation;
  String? _errorText;
  bool _isLoading = false;
  late Map<String, dynamic> responseData = {}; // ここにresponseDataを追加

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getCurrentLocation() async {
    // 現在の位置情報を取得
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

    // マップの初期位置を現在位置に設定
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });
  }


  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _onSubmitButtonPressed() {
    if (_selectedItem == null) {
      setState(() {
        _errorText = '距離を指定してください';
      });
    } else if (_selectedLocation == null) {
      setState(() {
        _errorText = '地図上で目的地を選択してください';
      });
    } else {
      int selectedDistance = parseInt(_selectedItem!);
      setState(() {
        _isLoading = true;
        _errorText = null;
      });

      // POSTリクエストで送信するデータ
      final data = {
        'range': selectedDistance,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      };

      // データをJSON形式に変換
      final jsonData = jsonEncode(data);

      // URLを自分のサーバーのエンドポイントに置き換えてください
      final url = 'http://20.210.139.133/story/';

      // 認証情報（'admin:password123'）を適切な値に更新してください
      final headers = {
        //'Authorization': 'Basic ' + base64Encode(utf8.encode('admin:password123')),
        'Content-Type': 'application/json; charset=utf-8',
      };

      http.post(Uri.parse(url), headers: headers, body: jsonData).then((response) {
        if (response.statusCode == 200) {
          // データを正常に送信しました
          // 必要に応じてここでレスポンスを処理してください
          /*print('tanaka');
          print(response.body);
          print("==============decoded===============");
          print(utf8.decode(response.bodyBytes));
          print("==============hex=======================");
          print(response.bodyBytes.map((e) => e.toRadixString(16).padLeft(2,'0')).join());*/
          responseData = jsonDecode(utf8.decode(response.bodyBytes));


          print('POSTリクエストが成功しました');
        } else {
          // データの送信に失敗しました
          print('POSTリクエストの送信に失敗しました: ${response.statusCode}');
        }

        // リクエストが完了した後、セカンドページに移動します
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SecondPage(responseData: responseData)),
              (route) => route.isFirst,
        ).then((value) {
          setState(() {
            _isLoading = false;
          });
        });
      }).catchError((error) {
        // POSTリクエストの送信中にエラーが発生しました
        print('POSTリクエストの送信エラー: $error');

        // ローディング状態をリセットし、エラーメッセージを表示します
        setState(() {
          _isLoading = false;
          _errorText = 'エラーが発生しました。後でもう一度お試しください。';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _selectedItem,
              onChanged: (newValue) {
                setState(() {
                  _selectedItem = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: '1',
                  child: Text('1'),
                ),
                DropdownMenuItem(
                  value: '2',
                  child: Text('2'),
                ),
                DropdownMenuItem(
                  value: '3',
                  child: Text('3'),
                ),
                DropdownMenuItem(
                  value: '4',
                  child: Text('4'),
                ),
                DropdownMenuItem(
                  value: '5',
                  child: Text('5'),
                ),
              ],
              decoration: InputDecoration(
                labelText: '移動距離(km)',
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
                  : Center(
                child: CircularProgressIndicator(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSubmitButtonPressed,
              child: _isLoading
                  ? SpinKitRing(
                color: Colors.grey,
                size: 50.0,
                lineWidth: 3.0,
              )
                  : Text('検索する'),
            ),
            if (_errorText != null) // 追加: エラーメッセージの表示
              Text(
                _errorText!,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

}