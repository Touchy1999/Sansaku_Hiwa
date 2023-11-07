import 'package:flutter/material.dart';
import 'package:project2/home_page.dart';
import 'package:project2/information_provision_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('散策秘話'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/test3.jpg'), // 画像ファイルのパスを指定します
            fit: BoxFit.cover, // 画像をウィジェットに合わせて調整します
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '散策秘話',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // テキストの色を指定します
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: '検索条件')),
                  );
                },
                child: Text('始める'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProvidePage()),
                  );
                },
                child: Text('情報提供'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}