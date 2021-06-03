import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'dart:io';
import 'dart:convert';
import 'calculator.dart';
import 'package:camera/camera.dart';
import 'dart:async';


class StudentListPage extends StatefulWidget
{
  @override
  _StudentPageState createState() => _StudentPageState();

}

class _StudentPageState extends State<StudentListPage>{

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> showAddDialog(BuildContext context) async{
    showDialog(context: context,
    builder: (context){
      final TextEditingController _textNameController = TextEditingController();
      final TextEditingController _textStuIdController = TextEditingController();
      return StatefulBuilder(builder: (context, setState){
        return AlertDialog(
          content:Form(
              key: _formKey, //validate
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/camera.png'),
                      ),
                    ),
                    child: new FlatButton(
                        padding: EdgeInsets.all(0.0),
                        onPressed: () {
                          setState((){
                            print("change image is alert.");
                          });
                        },
                        child: null
                    ),
                  ),
                  TextFormField(
                    controller: _textNameController,
                    validator: (value){
                      return value.isNotEmpty ? null : "Invalid Input";
                    },
                    decoration: InputDecoration(hintText: "Enter Name"),
                  ),
                  TextFormField(
                    controller: _textStuIdController,
                    keyboardType: TextInputType.number,
                    validator: (value){
                      return value.isNotEmpty ? null : "Invalid Input";
                    },
                    decoration: InputDecoration(hintText: "Enter Student ID"),
                  )
                ],
              )
          ),
          actions: <Widget>[
            TextButton(
                onPressed: (){
                  print("confirm is click.");

                  if(_formKey.currentState.validate()){ //if it is validate
                    Navigator.of(context).pop();
                  }
                },
                child: Text("OK"))
          ],
        );
      });
    });
  }

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
        onPressed: () async {
          showAddDialog(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}

