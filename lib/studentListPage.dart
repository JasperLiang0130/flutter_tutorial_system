import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'dart:io' as Io;
import 'dart:convert';
import 'calculator.dart';


class StudentListPage extends StatefulWidget
{
  @override
  _StudentPageState createState() => _StudentPageState();

}

class _StudentPageState extends State<StudentListPage>{
  @override
  Widget build(BuildContext context) {
    return Consumer<AllModels>(
        builder: buildScaffold,
    );
  }

  Scaffold buildScaffold(BuildContext context, AllModels allModels, _) {
    var calculate = Calculator();
    List<Scheme> schemes = allModels.schItems;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            if (allModels.loading) CircularProgressIndicator() else Expanded(
              child: ListView.builder(
                itemBuilder: (_, index) {
                  var student = allModels.stuItems[index];
                  Uint8List bytes = Base64Decoder().convert(student.img);
                  return Dismissible(
                    child: ListTile(
                      title: Text(student.name),
                      subtitle: Text(student.id),
                      leading: Container(
                        width: 70,
                        child: Image.memory(bytes, fit: BoxFit.contain, ),
                      ),
                      trailing: Text(calculate.calculateStudentAvg(student.grades, schemes).toString()+"%"),
                      onTap: () {
                        print(student.name+" is tapped!");
                      },
                    ),
                    background: Container(
                      color: Colors.red,
                    ),
                    key: ValueKey<Student>(student),
                    onDismissed: (DismissDirection direction) {
                      setState(() {
                        print("Delete but not impelment it yet.");
                      });
                    },
                  );
                },
                itemCount: allModels.stuItems.length,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        //onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}

