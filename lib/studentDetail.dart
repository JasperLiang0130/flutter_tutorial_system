import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'calculator.dart';
import 'models.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:share/share.dart';



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
  final gradeController = TextEditingController();
  final avgController = TextEditingController();
  final calculater = Calculator();

  @override
  Widget build(BuildContext context) {
    var schemes = Provider.of<AllModels>(context, listen: false).schItems;
    var student = Provider.of<AllModels>(context, listen: false).getStudent(widget.pk);
    nameController.text = student.name;
    stuIdController.text = student.id;
    gradeController.text = student.grades.join(";");
    avgController.text = calculater.calculateStudentAvg(student.grades, schemes).toString();
    Uint8List bytes = Base64Decoder().convert(student.img);
    final List<String> levelHD_items = <String>["HD+", "HD", "DN", "CR", "PP", "NN"];
    final List<String> levelA_items = <String>["A", "B", "C", "D", "F"];
    final List<String> attend_items = <String>["Attend", "Absent"];

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
                                  padding: EdgeInsets.only(left: 5.0, top: 5,
                                      right: 5.0),
                                  child: Image.memory(bytes,
                                      fit: BoxFit.contain, width: 65),
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Student Name",
                                                  suffixIcon: Icon(Icons.perm_identity)
                                              ),
                                              controller: nameController,
                                              validator: (value) {
                                                return value.isNotEmpty ? null : "Invalid Input";
                                              },
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Student ID",
                                                  suffixIcon: Icon(Icons.school_outlined)
                                              ),
                                              controller: stuIdController,
                                              keyboardType: TextInputType.number,
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
                            Padding(
                              padding: EdgeInsets.only(top: 5, left: 10, bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Average Grade:  ",
                                  style: TextStyle(fontSize: 20),),
                                  Text(avgController.text+"%",
                                    style: TextStyle(fontSize: 20, backgroundColor: Colors.amber),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 467,
                              child: ListView.builder(
                                  itemBuilder: (BuildContext context, index){
                                    var scheme = schemes[index];
                                    var updateGrades = gradeController.text.split(";");

                                    if(scheme.type == "level_HD" && updateGrades[scheme.week-1]=="")
                                    {
                                      updateGrades[scheme.week-1] = levelHD_items.last;
                                      gradeController.text = updateGrades.join(";");
                                    }else
                                    if(scheme.type == "level_A" && updateGrades[scheme.week-1]=="")
                                    {
                                      updateGrades[scheme.week-1] = levelA_items.last;
                                      gradeController.text = updateGrades.join(";");
                                    }else
                                    if(scheme.type == "attendance" && updateGrades[scheme.week-1]=="")
                                    {
                                      updateGrades[scheme.week-1] = attend_items.last;
                                      gradeController.text = updateGrades.join(";");
                                    }else
                                    if(scheme.type == "score" && updateGrades[scheme.week-1]=="")
                                    {
                                      updateGrades[scheme.week-1] = "0";
                                      gradeController.text = updateGrades.join(";");
                                    }

                                    List<String> checkbox;
                                    if(scheme.type == "checkbox"){
                                      if(updateGrades[scheme.week-1]==""){
                                        checkbox = List<String>();
                                        for(int i=0; i<num.parse(scheme.extra);i++){
                                          checkbox.add("0");
                                        }
                                        gradeController.text = updateGrades.join(";");
                                      }else{
                                        checkbox = (updateGrades[scheme.week-1]).split(",");
                                      }
                                    }

                                    return Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 16,
                                      color: Colors.white,
                                      shadowColor: Colors.black38,
                                      margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.grade_outlined, size: 32,),
                                                ],
                                              ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Week "+ scheme.week.toString(), style: TextStyle(fontSize: 20)),
                                                  Text(transferSchemeTypeName(scheme), style: TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                              child: Padding(
                                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                                child: Column(
                                                    children: [
                                                      if(scheme.type == "level_HD")
                                                        Container(
                                                          padding: const EdgeInsets.only(left: 16, right: 16),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(color:Colors.black45, width: 2),
                                                          ),
                                                          child: DropdownButton<String>(
                                                              value: updateGrades[scheme.week-1],
                                                              icon: const Icon(Icons.arrow_drop_down),
                                                              iconSize: 22,
                                                              elevation: 16,
                                                              style: const TextStyle(color: Colors.black, fontSize: 16),
                                                              items: levelHD_items.map<DropdownMenuItem<String>>((String value) {
                                                                return DropdownMenuItem<String>(
                                                                  value: value,
                                                                  child: Text(value),
                                                                );
                                                              }).toList(),
                                                              onChanged: (String newValue){
                                                                setState(() {
                                                                  updateGrades[scheme.week-1] = newValue;
                                                                  avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                                });
                                                                gradeController.text = updateGrades.join(";");
                                                                print("gradeController: "+gradeController.text);
                                                              }
                                                          ),
                                                        ),
                                                      if(scheme.type == "level_A")
                                                        Container(
                                                          padding: const EdgeInsets.only(left: 16, right: 16),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(color:Colors.black45, width: 2),
                                                          ),
                                                          child: DropdownButton<String>(
                                                              value: updateGrades[scheme.week-1],
                                                              icon: const Icon(Icons.arrow_drop_down),
                                                              iconSize: 22,
                                                              elevation: 16,
                                                              style: const TextStyle(color: Colors.black, fontSize: 16),
                                                              items: levelA_items.map<DropdownMenuItem<String>>((String value) {
                                                                return DropdownMenuItem<String>(
                                                                  value: value,
                                                                  child: Text(value),
                                                                );
                                                              }).toList(),
                                                              onChanged: (String newValue){
                                                                setState(() {
                                                                  updateGrades[scheme.week-1] = newValue;
                                                                  avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                                });
                                                                gradeController.text = updateGrades.join(";");
                                                                print("gradeController: "+gradeController.text);
                                                              }
                                                          ),
                                                        ),
                                                      if(scheme.type == "attendance")
                                                        Container(
                                                          padding: const EdgeInsets.only(left: 16, right: 16),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(color:Colors.black45, width: 2),
                                                          ),
                                                          child: DropdownButton<String>(
                                                              value: updateGrades[scheme.week-1],
                                                              icon: const Icon(Icons.arrow_drop_down),
                                                              iconSize: 22,
                                                              elevation: 16,
                                                              style: const TextStyle(color: Colors.black, fontSize: 16),
                                                              items: attend_items.map<DropdownMenuItem<String>>((String value) {
                                                                return DropdownMenuItem<String>(
                                                                  value: value,
                                                                  child: Text(value),
                                                                );
                                                              }).toList(),
                                                              onChanged: (String newValue){
                                                                setState(() {
                                                                  updateGrades[scheme.week-1] = newValue;
                                                                  avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                                });
                                                                gradeController.text = updateGrades.join(";");
                                                                print("gradeController: "+gradeController.text);
                                                              }
                                                          ),
                                                        ),
                                                      if(scheme.type == "score")
                                                        Container(
                                                          height:150,
                                                          child:
                                                          NumberPicker.integer(
                                                            initialValue: updateGrades[scheme.week-1]==""?0:num.parse(updateGrades[scheme.week-1]),
                                                            minValue: 0,
                                                            maxValue: num.parse(scheme.extra),
                                                            step: 10,
                                                            onChanged: (num newScore){
                                                              setState((){
                                                                updateGrades[scheme.week-1] = newScore.toString();
                                                                avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                              });
                                                              gradeController.text = updateGrades.join(";");
                                                              print("gradeController: "+gradeController.text);
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
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            for(int i=0; i<checkbox.length; i++)
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text("Task "+(i+1).toString()),
                                                                  Checkbox(value: (checkbox[i]=="0")?false:true, onChanged: (checked){
                                                                    setState((){
                                                                      checkbox[i] = (checked)?"1":"0";
                                                                      updateGrades[scheme.week-1] = checkbox.join(",");
                                                                      avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                                    });
                                                                    gradeController.text = updateGrades.join(";");
                                                                    print("gradeController: "+gradeController.text);
                                                                  })
                                                                ],
                                                              ),
                                                          ],
                                                        )
                                                    ]
                                                ),
                                              )
                                          ),
                                        ],
                                      )
                                    );
                                  },
                                  itemCount: schemes.length,
                              )
                            ),
                          ],
                        ),
                      ),
                    )
                  ]
              )
          ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "deleteTag",
              onPressed: () async {
                return await showDialog(context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("Delete Alert"),
                        content: Text("Are you sure you want to delete "+student.name+" ("+student.id+") ?"),
                        actions: <Widget>[
                          FlatButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel")),
                          FlatButton(onPressed: () => ({
                              setState(() {
                                Provider.of<AllModels>(context, listen: false).deleteStudent(student.pk);
                              }),
                              Navigator.of(context).pop(false), //close dialog
                              Navigator.pop(context), //back to student list page
                            }
                          ), child: Text("Delete", style: TextStyle(color: Colors.red)
                          )),
                        ],
                      );
                    }
                );
              },
              tooltip: 'DELETE',
              backgroundColor: Colors.red,
              child: Icon(Icons.delete),
            ),
            SizedBox(
              width: 15,
            ),
            FloatingActionButton(
              heroTag: "shareTag",
              onPressed: () async {
                String txt = "Name: "+nameController.text+", Id: "+stuIdController.text+", Avg grade: "+avgController.text;
                for(int i=0; i<student.grades.length;i++){
                  txt = txt+", Week "+(i+1).toString()+": "+student.grades[i].toString();
                }
                print(txt);
                Share.share(txt);
              },
              tooltip: 'SHARE',
              backgroundColor: Colors.green,
              child: Icon(Icons.share),
            ),
            SizedBox(
              width: 15,
            ),
            FloatingActionButton(
              heroTag: "saveTag",
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  //return to previous screen
                  student.name = nameController.text;
                  student.id = stuIdController.text;
                  student.grades = gradeController.text.split(";");
                  Provider.of<AllModels>(context, listen: false).updateStudent(widget.pk, student);
                  Navigator.pop(context);
                }
              },
              tooltip: 'SAVE',
              child: Icon(Icons.save),
            ),
          ],
        )
      );
    });
  }

  String transferSchemeTypeName(Scheme scheme){
    switch(scheme.type){
      case "level_HD":
        return "HD+/HD/DN/CR/PP/NN";
      case "level_A":
        return "A/B/C/D/F";
      case "attendance":
        return "Attend/Absent";
      case "score":
        return "Score of "+scheme.extra;
      case "checkbox":
        return "Checkbox of "+scheme.extra;
        return "";
    }
  }

}

/*
Padding(
                                        padding: EdgeInsets.only(left: 10, top: 5, right: 50, bottom: 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Week "+scheme.week.toString()+": "+scheme.type,
                                            style: TextStyle(fontSize: 18),),
                                            if(scheme.type == "level_HD")
                                              Container(
                                                padding: const EdgeInsets.only(left: 16, right: 16),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color:Colors.black45, width: 2),
                                                ),
                                                child: DropdownButton<String>(
                                                    value: updateGrades[scheme.week-1],
                                                    icon: const Icon(Icons.arrow_drop_down),
                                                    iconSize: 22,
                                                    elevation: 16,
                                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                                    items: levelHD_items.map<DropdownMenuItem<String>>((String value) {
                                                      return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String newValue){
                                                      setState(() {
                                                        updateGrades[scheme.week-1] = newValue;
                                                        avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                      });
                                                      gradeController.text = updateGrades.join(";");
                                                      print("gradeController: "+gradeController.text);
                                                    }
                                                ),
                                              ),
                                            if(scheme.type == "level_A")
                                              Container(
                                                padding: const EdgeInsets.only(left: 16, right: 16),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color:Colors.black45, width: 2),
                                                ),
                                                child: DropdownButton<String>(
                                                    value: updateGrades[scheme.week-1],
                                                    icon: const Icon(Icons.arrow_drop_down),
                                                    iconSize: 22,
                                                    elevation: 16,
                                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                                    items: levelA_items.map<DropdownMenuItem<String>>((String value) {
                                                      return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String newValue){
                                                      setState(() {
                                                        updateGrades[scheme.week-1] = newValue;
                                                        avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                      });
                                                      gradeController.text = updateGrades.join(";");
                                                      print("gradeController: "+gradeController.text);
                                                    }
                                                ),
                                              ),
                                            if(scheme.type == "attendance")
                                              Container(
                                                padding: const EdgeInsets.only(left: 16, right: 16),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color:Colors.black45, width: 2),
                                                ),
                                                child: DropdownButton<String>(
                                                    value: updateGrades[scheme.week-1],
                                                    icon: const Icon(Icons.arrow_drop_down),
                                                    iconSize: 22,
                                                    elevation: 16,
                                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                                    items: attend_items.map<DropdownMenuItem<String>>((String value) {
                                                      return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String newValue){
                                                      setState(() {
                                                        updateGrades[scheme.week-1] = newValue;
                                                        avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                      });
                                                      gradeController.text = updateGrades.join(";");
                                                      print("gradeController: "+gradeController.text);
                                                    }
                                                ),
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
                                                          avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                        });
                                                        gradeController.text = updateGrades.join(";");
                                                        print("gradeController: "+gradeController.text);
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
                                                        Text("Task "+(i+1).toString()),
                                                        Checkbox(value: (checkbox[i]=="0")?false:true, onChanged: (checked){
                                                          setState((){
                                                            checkbox[i] = (checked)?"1":"0";
                                                            updateGrades[scheme.week-1] = checkbox.join(",");
                                                            avgController.text = calculater.calculateStudentAvg(updateGrades, schemes).toString();
                                                          });
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
 */