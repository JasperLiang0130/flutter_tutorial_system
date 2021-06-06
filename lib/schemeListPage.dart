import 'dart:typed_data';
import 'package:assignment4/classStudentListPage.dart';
import 'package:assignment4/studentDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'calculator.dart';
import 'models.dart';
import 'dart:async';


class SchemeListPage extends StatefulWidget
{
  @override
  _SchemePageState createState() => _SchemePageState();
}

class _SchemePageState extends State<SchemeListPage> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var schemesLength;
  final _textTyepController = TextEditingController();
  final _textExtraController = TextEditingController();
  final _extraNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AllModels>(
        builder: buildSchemesScaffod,
    );
  }

  Future<void> showAddSchemeDialog(BuildContext context) async {
    bool _uploading = false;
    bool _visiableExtra = false;
    final List<String> schemeType_items = <String>["HD+/HD/DN/CR/PP/NN", "A/B/C/D/F", "Attend/Absent", "Score of X", "CheckBox"];
    _textTyepController.text = schemeType_items.first;

    showDialog(context: context,
      builder: (context) {

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Week "+(schemesLength+1).toString()),
                  SizedBox(height: 10,),
                  //dropdown list
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color:Colors.black45, width: 2),
                    ),
                    child: DropdownButton<String>(
                        value: _textTyepController.text ,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 20,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        items: schemeType_items.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String newValue){
                          setState(() {
                            _textTyepController.text = newValue;
                            if(newValue == "Score of X"){
                              _visiableExtra = true;
                              _extraNameController.text = "X";
                            }else if (newValue == "CheckBox"){
                              _visiableExtra = true;
                              _extraNameController.text = "Num of box";
                            }else{
                              _visiableExtra = false;
                              _extraNameController.text = "";
                            }
                          });
                          print("type: "+_textTyepController.text);
                        }
                    ),
                  ),
                  SizedBox(height: 10,),
                  //extra (need to be hidden)
                  Visibility(
                    visible: _visiableExtra,
                    maintainState: true,
                    maintainAnimation: true,
                    child: TextFormField(
                      controller: _textExtraController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Icon(Icons.edit),
                        labelText: _extraNameController.text,
                        hintText: "Type "+_extraNameController.text,
                      ),
                      validator: (value) {
                        if(value.isNotEmpty && num.parse(value) == 0){
                          return "Cannot be 0";
                        }
                        return value.isNotEmpty ? null : "Invalid Input";
                      },
                      onChanged: (value){
                        ((){
                          _textExtraController.text = value;
                          _textExtraController.selection = TextSelection.fromPosition(TextPosition(offset: _textExtraController.text.length));
                        });
                        print(_extraNameController.text+": "+_textExtraController.text);
                      },
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () async{
                    print("confirm is click.");
                    var newScheme = Scheme();
                    newScheme.pk = "";
                    newScheme.week = schemesLength+1;
                    newScheme.type = convertTypenameToDB(_textTyepController.text);
                    if(_textTyepController.text == "Score of X"){
                      if (_formKey.currentState.validate()) { //if it is validate
                        newScheme.extra = _textExtraController.text;
                        Provider.of<AllModels>(context, listen: false).addScheme(newScheme);
                        Navigator.of(context).pop(); //close the pop up
                      }
                    }else if (_textTyepController.text == "CheckBox"){
                      if (_formKey.currentState.validate()) { //if it is validate
                        newScheme.extra = _textExtraController.text;
                        Provider.of<AllModels>(context, listen: false).addScheme(newScheme);
                        Navigator.of(context).pop(); //close the pop up
                      }
                    }else{
                      if (_formKey.currentState.validate()) { //if it is validate
                        newScheme.extra = "";
                        Provider.of<AllModels>(context, listen: false).addScheme(newScheme);
                        Navigator.of(context).pop(); //close the pop up
                      }
                    }
                  },
                  child: Text("OK"))
            ],
          );
        });
      }
    );
  }

  Scaffold buildSchemesScaffod(BuildContext context, AllModels allModels, _) {

    var calcuate = Calculator();
    List<Student> students = allModels.stuItems;
    schemesLength = allModels.schItems.length;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (allModels.loading) CircularProgressIndicator() else
              Expanded(
                child: ListView.builder(
                    itemBuilder: (_, index) {
                      var scheme = allModels.schItems[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 16,
                        color: Colors.white,
                        shadowColor: Colors.black38,
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.list, size: 36,),
                            ],
                          ),
                          title: Text("Week "+ scheme.week.toString(), style: TextStyle(fontSize: 16)),
                          subtitle: Text(transferSchemeTypeName(scheme), style: TextStyle(fontSize: 14)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(calcuate.calculateClassAvg(scheme, students), style: TextStyle(fontSize: 18)),
                              Text("Class Avg",
                                  style: TextStyle(fontSize: 12))
                            ],
                          ),
                          onTap: (){
                            print("tutorial "+scheme.week.toString() + " is tapped!");
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context){
                                  return ClassStudentListPage(pk: scheme.pk);
                                }
                            ));
                          },
                        ),
                      );
                    },
                    itemCount:  allModels.schItems.length,
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "schemeAdd",
        onPressed: () async {
          showAddSchemeDialog(context);
        },
        tooltip: 'Add Tutorial',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );

  }

  String convertTypenameToDB(String s){
    switch(s){
      case "HD+/HD/DN/CR/PP/NN":
        return "level_HD";
      case "A/B/C/D/F":
        return "level_A";
      case "Attend/Absent":
        return "attendance";
      case "Score of X":
        return "score";
      case "CheckBox":
        return "checkbox";
        return "";
    }
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
