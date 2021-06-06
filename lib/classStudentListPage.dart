import 'dart:convert';
import 'dart:typed_data';
import 'package:assignment4/studentDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'calculator.dart';
import 'calculator.dart';
import 'models.dart';
import 'dart:async';

class ClassStudentListPage extends StatefulWidget
{
  final String pk; //select scheme pk

  const ClassStudentListPage({Key key, this.pk}) : super(key: key);


  @override
  _ClassPageState createState() => _ClassPageState();

}

class _ClassPageState extends State<ClassStudentListPage> {

  final calculate = Calculator();
  final List<String> levelHD_items = <String>["HD+", "HD", "DN", "CR", "PP", "NN"];
  final List<String> levelA_items = <String>["A", "B", "C", "D", "F"];
  final List<String> attend_items = <String>["Attend", "Absent"];
  Student selectedStudent;
  final markController = TextEditingController();
  Scheme scheme;

  @override
  Widget build(BuildContext context) {
    return Consumer<AllModels>(
      builder: buildClassScaffod,
    );
  }

  Future<void> showEditMarkDialog(BuildContext context) async {
    bool _uploading = false;

    markController.text = selectedStudent.grades[scheme.week-1];
    if(scheme.type == "level_HD" && markController.text=="")
    {
      markController.text = levelHD_items.last;
    }else
    if(scheme.type == "level_A" && markController.text=="")
    {
      markController.text = levelA_items.last;
    }else
    if(scheme.type == "attendance" && markController.text=="")
    {
      markController.text = attend_items.last;
    }else
    if(scheme.type == "score" && markController.text=="")
    {
      markController.text = "0";
    }

    List<String> checkbox;
    if(scheme.type == "checkbox"){
      if(markController.text==""){
        checkbox = List<String>();
        for(int i=0; i<num.parse(scheme.extra);i++){
          checkbox.add("0");
        }
      }else{
        checkbox = (markController.text).split(",");
      }
    }

    showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit student mark"),
              content: Form(
                  child:
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  child: Image.memory(Base64Decoder().convert(selectedStudent.img), fit: BoxFit.contain,),
                                ),
                                Text(
                                    selectedStudent.name, style: TextStyle(fontSize: 16)
                                ),
                                Text(
                                    selectedStudent.id, style: TextStyle(fontSize: 12)
                                )
                              ],
                            )
                          ),
                          Expanded(
                              flex: 4,
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
                                          value: markController.text,
                                          icon: const Icon(Icons.arrow_drop_down),
                                          iconSize: 18,
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
                                              markController.text = newValue;
                                            });
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
                                          value: markController.text,
                                          icon: const Icon(Icons.arrow_drop_down),
                                          iconSize: 18,
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
                                              markController.text = newValue;
                                            });
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
                                          value: markController.text,
                                          icon: const Icon(Icons.arrow_drop_down),
                                          iconSize: 18,
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
                                              markController.text = newValue;
                                            });
                                          }
                                      ),
                                    ),
                                  if(scheme.type == "score")
                                    Container(
                                      height: 150,
                                      child:
                                      NumberPicker.integer(
                                        initialValue: markController.text==""?0:num.parse(markController.text),
                                        minValue: 0,
                                        maxValue: num.parse(scheme.extra),
                                        step: 10,
                                        onChanged: (num newScore){
                                          setState((){
                                            markController.text = newScore.toString();
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
                                              Text("Task "+(i+1).toString()),
                                              Checkbox(value: (checkbox[i]=="0")?false:true, onChanged: (checked){
                                                setState((){
                                                  checkbox[i] = (checked)?"1":"0";
                                                  markController.text = checkbox.join(",");
                                                });
                                              })
                                            ],
                                          ),
                                      ],
                                    )
                                ],
                              )
                          ),
                        ],
                      ),

                    ],
                  )
              ),
              actions: <Widget>[
                FlatButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel", style: TextStyle(color: Colors.red))),
                FlatButton(
                    onPressed: () async{
                      print("update is click.");

                        selectedStudent.grades[scheme.week-1] = markController.text;
                        Provider.of<AllModels>(context, listen: false).updateStudent(selectedStudent.pk, selectedStudent);
                        Navigator.of(context).pop(); //close the pop up
                    },
                    child: Text("Update"),
                )
              ],
            );
          });
        });
  }

  Scaffold buildClassScaffod(BuildContext context, AllModels allModels, _) {
    print("pk: "+widget.pk);
    scheme = Provider.of<AllModels>(context, listen: false).getScheme(widget.pk);

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Week "+scheme.week.toString()+" - "+transferSchemeTypeName(scheme) +" Marking"),
        ),
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (allModels.loading) CircularProgressIndicator() else
              Expanded(
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    var student = allModels.stuItems[index];
                    Uint8List bytes = Base64Decoder().convert(student.img);
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 16,
                      color: Colors.white,
                      shadowColor: Colors.black38,
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      child: ListTile(
                        title: Text(student.name,
                            style: TextStyle(fontSize: 16)),
                            subtitle: Text(student.id,
                            style: TextStyle(fontSize: 14)),
                        leading: Container(
                          width: 70,
                          child: Image.memory(bytes, fit: BoxFit.contain,),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(calculate.showStudentGrade(scheme, student), style: TextStyle(fontSize: 20)),
                            Text("Marking grade",style: TextStyle(fontSize: 14))
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            selectedStudent = student;
                            showEditMarkDialog(context);
                          });
                        },
                      ),
                    );
                  },
                  itemCount:  allModels.stuItems.length,
                ),
              )
          ],
        ),
      )
    );
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