import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _events = [];//宣告一個列表

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Scrollbar(
        child: RefreshIndicator(
          //下拉刷新
          onRefresh: () async {//因為這邊要求回傳的是一個Future, 所以使用async/await
            await _refresh();
          },

          child: ListView(
            children: _events.map<Widget>((event) {
              return Dismissible(
                confirmDismiss: (_) async {
                  //確認刪除匡
                  return showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text("Are you sure?"),
                          content: Text("Do you want to delete this item?"),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text("Cancel")),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          ],
                        );
                      });
                  // return false;
                },
                onDismissed: (_) {//不在意滑動方向, 所以使用(_)
                  //真的把項目移除
                  setState(() {
                    _events.removeWhere((e) => e.id == event.id);
                  });
                },
                key: ValueKey(event.id),
                child: ListTile(
                  leading: Image.network(event.avatarurl),
                  title: Text("${event.userName}"),
                  subtitle: Text("${event.repoName}"),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final res = await http.get("https://api.github.com/events");
      //     if (res.statusCode == 200) {
      //       // print(res.body);
      //       final json = convert.jsonDecode(res.body);
      //       // print(json); //在flutter, Dart 裡面的表現形式：Mao<dynamic, dynamic>
      //       // json.forEach((item) => print(item));//因為裡面是列表的樣式, 所以透過json.forEach的方式來把資料列印出來
      //       _events.addAll(json.map((item) => GitEvent(item)));
      //       print(_events);
      //     }
      //   },
    );
  }

  _refresh() async {
    final res = await http.get("https://api.github.com/events");
    if (res.statusCode == 200) {
      final json = convert.jsonDecode(res.body);
      setState(() {
        _events.clear(); //先把舊的清除, 再把新的加進來
        _events.addAll(json.map((item2) => GitEvent(item2)));
      });

      // print(_events);
    }
  }
}

class GitEvent {
  String id;
  String userName;
  String avatarurl;
  String repoName;

  // GitEvent(this.id, this.userName, this.avatarurl, this.repoName);
  //不使用一般的建構子, 改要求程式傳入item細項

  GitEvent(json) {
    this.id = json["id"];
    this.userName = json["actor"]["login"];
    this.avatarurl = json["actor"]["avatar_url"];
    this.repoName = json["repo"]["name"];
  }

  @override
  String toString() {
    return 'GitEvent{id: $id, userName: $userName, avatarurl: $avatarurl, repoName: $repoName}';
  }
}
