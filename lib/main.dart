import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sindarin Translator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: "Desktop Sindarin Translator"),
      debugShowCheckedModeBanner: false,
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
  Future<String> translated_text = Future.value('');

  Future<String> _translateSindarin(String original_text) async {
    var url = 'https://api.funtranslations.com/translate/sindarin';

    try {
      var response = await http.post(url, body: {'text': original_text});

      String body = response.body;
      Map<String, dynamic> decoded_body = jsonDecode(body);

      if (decoded_body.containsKey('contents')) {
        return decoded_body['contents']['translated'];
      } else {
        return 'Free limit reached! Please try again in an hour.';
      }
    } catch (e) {
      return 'Something went wrong, please restart the app and try again!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Write your text here...',
                  ),
                  onSubmitted: (String value) async {
                    translated_text = _translateSindarin(value);
                    setState(() {});
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FutureBuilder<String>(
                future: translated_text,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData) {
                    children = <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Result:',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${snapshot.data}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]),
                      )
                    ];
                  } else if (snapshot.hasError) {
                    children = <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('Error: ${snapshot.error}'),
                      )
                    ];
                  } else {
                    children = <Widget>[
                      SizedBox(
                        child: CircularProgressIndicator(),
                        width: 20,
                        height: 20,
                      ),
                    ];
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
