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
  final scoreController = TextEditingController();
  var updateGrades;

  @override
  Widget build(BuildContext context) {
    var students = Provider.of<AllModels>(context, listen: false).schItems;
    var schemes = Provider.of<AllModels>(context, listen: false).schItems;
    var student = Provider.of<AllModels>(context, listen: false).getStudent(widget.pk);
    updateGrades = student.grades;

    nameController.text = student.name;
    stuIdController.text = student.id;
    Uint8List bytes = Base64Decoder().convert(student.img);
    final List<String> levelHD_items = <String>["HD+", "HD", "DN", "CR", "PP", "NN", ""];
    final List<String> levelA_items = <String>["A", "B", "C", "D", "F", ""];
    final List<String> attend_items = <String>["Absent", "Attend", ""];

    return StatefulBuilder(builder: (context, setState){
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 100,
                                  padding: EdgeInsets.only(left: 5.0,
                                      right: 5.0),
                                  child: Image.memory(bytes,
                                      fit: BoxFit.contain, width: 65),
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Student Name"),
                                              controller: nameController,
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Student ID"),
                                              controller: stuIdController,
                                            ),
                                          ],
                                        )
                                    )
                                )
                              ],
                            ),
                            SizedBox(
                              height: 485,
                              child: ListView.builder(
                                  itemBuilder: (BuildContext context, index){
                                    var scheme = schemes[index];
                                    scoreController.text = updateGrades[scheme.week-1];
                                    return Padding(
                                        padding: EdgeInsets.only(left: 100, top: 10, right: 90, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Week "+scheme.week.toString()+": "+scheme.type),
                                            if(scheme.type == "level_HD")
                                              DropdownButton<String>(
                                                  value: updateGrades[scheme.week-1],
                                                  icon: const Icon(Icons.arrow_downward),
                                                  iconSize: 14,
                                                  elevation: 16,
                                                  style: const TextStyle(color: Colors.black),
                                                  underline: Container(
                                                    height: 1,
                                                    color: Colors.deepOrange,
                                                  ),
                                                  items: levelHD_items.map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String newValue){
                                                    setState(() {
                                                      updateGrades[scheme.week-1] = newValue;
                                                    });
                                                    print("dropdownValue: "+updateGrades[scheme.week-1]);
                                                  }
                                              ),
                                            if(scheme.type == "level_A")
                                              DropdownButton<String>(
                                                  value: updateGrades[scheme.week-1],
                                                  icon: const Icon(Icons.arrow_downward),
                                                  iconSize: 14,
                                                  elevation: 16,
                                                  style: const TextStyle(color: Colors.black),
                                                  underline: Container(
                                                    height: 1,
                                                    color: Colors.deepOrange,
                                                  ),
                                                  items: levelA_items.map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String newValue){
                                                    setState(() {
                                                      updateGrades[scheme.week-1] = newValue;
                                                    });
                                                    print("dropdownValue: "+updateGrades[scheme.week-1]);
                                                  }
                                              ),
                                            if(scheme.type == "attendance")
                                              DropdownButton<String>(
                                                  value: updateGrades[scheme.week-1],
                                                  icon: const Icon(Icons.arrow_downward),
                                                  iconSize: 14,
                                                  elevation: 16,
                                                  style: const TextStyle(color: Colors.black),
                                                  underline: Container(
                                                    height: 1,
                                                    color: Colors.deepOrange,
                                                  ),
                                                  items: attend_items.map<DropdownMenuItem<String>>((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String newValue){
                                                    setState(() {
                                                      updateGrades[scheme.week-1] = newValue;
                                                    });
                                                    print("dropdownValue: "+updateGrades[scheme.week-1]);
                                                  }
                                              ),
                                            if(scheme.type == "score")
                                              Container(
                                                width:50,
                                                child: TextField(
                                                  controller: scoreController,
                                                  decoration: InputDecoration(
                                                      hintText: "score",
                                                  ),
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (String newScore){
                                                    if(double.parse(scheme.extra)< double.parse(newScore)){
                                                      scoreController.text = scheme.extra;
                                                    }else{
                                                      scoreController.text = newScore;
                                                    }
                                                  },
                                                  onEditingComplete: () {

                                                  },
                                                ),
                                              ),
                                            if(scheme.type == "checkbox")
                                              Text("box"),
                                          ],
                                        ),
                                    );
                                  },
                                  itemCount: schemes.length,
                              )
                            ),
                            ElevatedButton.icon(onPressed: () {
                              /*
                              if (_formKey.currentState.validate()) {
                                //return to previous screen
                                Navigator.pop(context);
                              }
                               */
                            },
                                icon: Icon(Icons.save),
                                label: Text("Save Values"))
                          ],
                        ),
                      ),
                    )
                  ]
              )
          )
      );
    });
  }

}

/*
SingleChildScrollView(
                              physics: ScrollPhysics(),
                              child: Column(
                                children: [
                                  ListView.builder(
                                    itemBuilder: (_, index){
                                      var scheme = schemes[index];
                                      return ListTile(
                                        leading: Text("Week "+scheme.week.toString()),
                                        title: Text(scheme.type),
                                      );
                                    },
                                    itemCount: schemes.length,
                                  ),
                                ],
                              ),
                            ),
 */


/*
Expanded(
                                        child: ListView.builder(
                                          itemBuilder: (_, index){
                                            var grades = student.grades;
                                            var scheme = schemes[index];
                                            switch(scheme.type) {
                                              case "level_HD":
                                                final List<String> items = <String>["HD+","HD","DN","CR","PP","NN"];
                                                dropdownValue = grades[scheme.week - 1];
                                                return ListTile(
                                                  leading: Text("Week " + scheme.week.toString()),
                                                  title: Text(scheme.type),
                                                  trailing: DropdownButton<String>(
                                                      value: dropdownValue,
                                                      icon: const Icon(
                                                          Icons.arrow_downward),
                                                      iconSize: 14,
                                                      elevation: 16,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      underline: Container(
                                                        height: 1,
                                                        color: Colors.deepOrange,
                                                      ),
                                                      items: items.map<
                                                          DropdownMenuItem<String>>((
                                                          String value) {
                                                        return DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (String newValue) {
                                                        print("new value: " + newValue);
                                                        setState(() {
                                                          dropdownValue = newValue;
                                                        });
                                                        print("dropdownValue: " +
                                                            dropdownValue);
                                                      }
                                                  ),
                                                );
                                              case "level_A":
                                                return ListTile(
                                                  leading: Text("Week " + scheme.week.toString()),
                                                  title: Text(scheme.type),
                                                );
                                              case "attendance":
                                                return ListTile(
                                                  leading: Text("Week " + scheme.week.toString()),
                                                  title: Text(scheme.type),
                                                );
                                              case "checkbox":
                                                return ListTile(
                                                  leading: Text("Week " + scheme.week.toString()),
                                                  title: Text(scheme.type),
                                                );
                                              case "score":
                                                return ListTile(
                                                  leading: Text("Week " + scheme.week.toString()),
                                                  title: Text(scheme.type),
                                                );
                                            }
                                          },
                                        ),
                                    )

 */