import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'models.dart';
import 'models.dart';


class StudentDetail extends StatefulWidget{

  final String pk;

  const StudentDetail({Key key, this.pk}) : super(key: key);

  @override
  _StudentDetailState createState() => _StudentDetailState();

}

class _StudentDetailState extends State<StudentDetail>{

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final stuIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var students = Provider.of<AllModels>(context, listen: false).schItems;
    var schemes = Provider.of<AllModels>(context, listen: false).schItems;
    var student = Provider.of<AllModels>(context, listen: false).getStudent(widget.pk);

    nameController.text = student.name;
    stuIdController.text = student.id;
    Uint8List bytes = Base64Decoder().convert(student.img);

    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Student Mark"),
        ),
        body: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 100,
                                padding: EdgeInsets.only(left:5.0, right: 5.0),
                                child: Image.memory(bytes, fit: BoxFit.contain,width: 65),
                              ),
                              Expanded(
                                child: Padding(
                                    padding: EdgeInsets.only(left: 5, right: 5),
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          decoration: InputDecoration(labelText: "Student Name"),
                                          controller: nameController,
                                        ),
                                        TextFormField(
                                          decoration: InputDecoration(labelText: "Student ID"),
                                          controller: stuIdController,
                                        ),
                                      ],
                                    )
                                  )
                                )
                            ],
                          ),
                          ElevatedButton.icon(onPressed: () {
                            if (_formKey.currentState.validate())
                            {
                              //return to previous screen
                              Navigator.pop(context);
                            }
                          }, icon: Icon(Icons.save), label: Text("Save Values"))
                        ],
                      ),
                    ),
                  )
                ]
            )
        )
    );

  }

}