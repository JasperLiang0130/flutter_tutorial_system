
import 'package:assignment4/schemeListPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'studentListPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //added this line
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:

  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) //this functio is called every time the "future" updates
      {
        // Check for errors
        if (snapshot.hasError) {
          return FullScreenText(text:"Something went wrong");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done)
        {
          //BEGIN: the old MyApp builder from last week
          return ChangeNotifierProvider(
              create: (context) => AllModels(),
              child: MaterialApp(
                  title: 'Assignment4',
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                  ),
                  home: MyHomePage(title: 'Assignment4')
              ),
          );
          //END: the old MyApp builder from last week
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return FullScreenText(text:"Loading");
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
          title: const Text('KIT305 Tutorial (1pm - 3pm)'),
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
        body: TabBarView(
          children: <Widget> [
            StudentListPage(),
            SchemeListPage(),
            /*
            Center(
              child: Text("It's tutorial area"),
            ),
             */

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