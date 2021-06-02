import 'dart:typed_data';

import 'package:assignment4/scheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'student.dart';
import 'dart:io' as Io;
import 'dart:convert';
import 'calculator.dart';
import 'scheme.dart';

class StudentListPage extends StatefulWidget
{
  @override
  _StudentPageState createState() => _StudentPageState();

}

class _StudentPageState extends State<StudentListPage>{
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentModel>(
      builder: buildScaffold,
    );
  }

  Scaffold buildScaffold(BuildContext context, StudentModel studentModel, _) {
    var calculate = Calculator();
    var schemeModel = SchemeModel();
    List<Scheme> schemes = schemeModel.items;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            if (studentModel.loading && schemeModel.loading) CircularProgressIndicator() else Expanded(
              child: ListView.builder(
                itemBuilder: (_, index) {
                  var student = studentModel.items[index];
                  print(schemes.length.toString()+" is scheme length");
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
                itemCount: studentModel.items.length,
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