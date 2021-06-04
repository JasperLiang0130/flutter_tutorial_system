import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'package:numberpicker/numberpicker.dart';


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
  //final scoreController = TextEditingController();
  final gradeController = TextEditingController();
  //var updateGrades;

  @override
  Widget build(BuildContext context) {
    var schemes = Provider.of<AllModels>(context, listen: false).schItems;
    var students = Provider.of<AllModels>(context, listen: false).stuItems;
    var student = Provider.of<AllModels>(context, listen: false).getStudent(widget.pk);
    nameController.text = student.name;
    stuIdController.text = student.id;
    gradeController.text = student.grades.join(";");
    Uint8List bytes = Base64Decoder().convert(student.img);
    final List<String> levelHD_items = <String>["HD+", "HD", "DN", "CR", "PP", "NN", ""];
    final List<String> levelA_items = <String>["A", "B", "C", "D", "F", ""];
    final List<String> attend_items = <String>["Absent", "Attend", ""];

    return StatefulBuilder(builder: (context, setState){
      return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text("Edit Student Mark"),
          ),
          body: Padding(
              padding: EdgeInsets.only(left: 5.0,
                  right: 5.0),
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
                                              validator: (value) {
                                                return value.isNotEmpty ? null : "Invalid Input";
                                              },
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Student ID"),
                                              controller: stuIdController,
                                              validator: (value) {
                                                return value.isNotEmpty ? null : "Invalid Input";
                                              },
                                            ),
                                          ],
                                        )
                                    )
                                )
                              ],
                            ),
                            SizedBox(
                              height: 448,
                              child: ListView.builder(
                                  itemBuilder: (BuildContext context, index){
                                    var scheme = schemes[index];
                                    var updateGrades = gradeController.text.split(";");
                                    List<String> checkbox;
                                    if(scheme.type == "checkbox"){
                                      checkbox = (updateGrades[scheme.week-1]).split(",");
                                    }
                                    return Padding(
                                        padding: EdgeInsets.only(left: 40, top: 5, right: 50, bottom: 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Week "+scheme.week.toString()+": "+scheme.type,
                                            style: TextStyle(fontSize: 18),),
                                            if(scheme.type == "level_HD")
                                              DropdownButton<String>(
                                                  value: updateGrades[scheme.week-1],
                                                  icon: const Icon(Icons.arrow_downward),
                                                  iconSize: 14,
                                                  elevation: 16,
                                                  style: const TextStyle(color: Colors.black, fontSize: 16),
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
                                                    gradeController.text = updateGrades.join(";");
                                                    print("gradeController: "+gradeController.text);
                                                  }
                                              ),
                                            if(scheme.type == "level_A")
                                              DropdownButton<String>(
                                                  value: updateGrades[scheme.week-1],
                                                  icon: const Icon(Icons.arrow_downward),
                                                  iconSize: 14,
                                                  elevation: 16,
                                                  style: const TextStyle(color: Colors.black, fontSize: 16),
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
                                                    gradeController.text = updateGrades.join(";");
                                                    print("gradeController: "+gradeController.text);
                                                  }
                                              ),
                                            if(scheme.type == "attendance")
                                              DropdownButton<String>(
                                                  value: updateGrades[scheme.week-1],
                                                  icon: const Icon(Icons.arrow_downward),
                                                  iconSize: 14,
                                                  elevation: 16,
                                                  style: const TextStyle(color: Colors.black, fontSize: 16),
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
                                                    gradeController.text = updateGrades.join(";");
                                                    print("gradeController: "+gradeController.text);
                                                  }
                                              ),
                                            if(scheme.type == "score")
                                              Container(
                                                height: 150,
                                                child:
                                                    NumberPicker.integer(
                                                      initialValue: updateGrades[scheme.week-1]==""?0:num.parse(updateGrades[scheme.week-1]),
                                                      minValue: 0,
                                                      maxValue: num.parse(scheme.extra),
                                                      step: 10,
                                                      onChanged: (num newScore){
                                                        setState((){
                                                          updateGrades[scheme.week-1] = newScore.toString();
                                                          gradeController.text = updateGrades.join(";");
                                                          print("gradeController: "+gradeController.text);
                                                        });
                                                      },
                                                      itemExtent: 50,
                                                      scrollDirection: Axis.vertical,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(color: Colors.black26),
                                                      ),
                                                    ),
                                              ),

                                            if(scheme.type == "checkbox")
                                              Column(
                                                children: [
                                                  for(int i=0; i<checkbox.length; i++)
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text("Task "+i.toString()),
                                                        Checkbox(value: (checkbox[i]=="0")?false:true, onChanged: (checked){
                                                          setState((){
                                                            checkbox[i] = (checked)?"1":"0";
                                                          });
                                                          updateGrades[scheme.week-1] = checkbox.join(",");
                                                          gradeController.text = updateGrades.join(";");
                                                          print("gradeController: "+gradeController.text);
                                                        })
                                                      ],
                                                    ),
                                                ],
                                              )
                                          ],
                                        ),
                                    );
                                  },
                                  itemCount: schemes.length,
                              )
                            ),
                            ElevatedButton.icon(onPressed: () {

                              if (_formKey.currentState.validate()) {
                                //return to previous screen
                                Navigator.pop(context);
                              }

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
