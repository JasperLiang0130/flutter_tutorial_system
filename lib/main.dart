import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized(); //added this line
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
// Create the initialization Future outside of `build`:
  final Future<String> Function() test = () async
  {
    //wait some time
    await Future.delayed(Duration(seconds: 5));

    //then return the result
    return "done";
  };

  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder<String>(
      // Initialize FlutterFire:
      future: test(),
      builder: (context, snapshot) //this functio is called every time the "future" updates
      {
        if (snapshot.hasData == false)
          return FullScreenText(text:"Loading...");
        return MaterialApp(
          title: "home page",
          home: MyHomePage()
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tutorial Marking'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.people_alt),
                text: "Students",
              ),
              Tab(
                icon: Icon(Icons.grading_outlined),
                text: "Tutorials",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            //Center(
            //  child: Text("It's cloudy here"), // This trailing comma makes auto-formatting nicer for build methods.
            //),
            Scaffold(
             body: Center(
               child: Text("It's student area"),
             ),
             floatingActionButton: FloatingActionButton(
               //onPressed: _incrementCounter,
               tooltip: 'Increment',
               child: Icon(Icons.add),
             ), // This trailing comma makes auto-formatting nicer for build methods.
            ),
            Center(
              child: Text("It's tutorial area"),
            ),
          ],
        ),
      ),

    );
  }
}



class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection:TextDirection.ltr, child: Column(children: [ Expanded(child: Center(child: Text(text))) ]));
  }
}