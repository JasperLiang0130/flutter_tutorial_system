import 'dart:math';
import 'dart:typed_data';
import 'package:assignment4/studentDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'cameraController.dart';
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

class _StudentPageState extends State<StudentListPage> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _displayImg;  //Image.asset('assets/images/camera.png');
  File _defaultImg;
  int schemesLength;
  List<Student> students;
  List<Student> filterStudents = List<Student>();
  final filterController = TextEditingController();

  void androidIOSUpload() async
  {
    // 2. Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    //use the TakePictureScreen to get an image. This is like doing a startActivityForResult
    var picture = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TakePictureScreen(
                  // Pass the appropriate camera to the TakePictureScreen widget.
                    camera: firstCamera
                )
        )
    );
    if(picture != null){
      _displayImg = picture;
    }

  }

    Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

    Future<void> showAddDialog(BuildContext context) async {
      bool _uploading = false;
      _displayImg = await getImageFileFromAssets('assets/images/camera.png');
      _defaultImg = _displayImg;
      showDialog(context: context,
          builder: (context) {
            final TextEditingController _textNameController = TextEditingController();
            final TextEditingController _textStuIdController = TextEditingController();
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                content: Form(
                    key: _formKey, //validate
                    child:
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(_displayImg),
                            ),
                          ),
                          child: new FlatButton(
                              padding: EdgeInsets.all(0.0),
                              onPressed: () async {
                                setState(() {
                                  _uploading = true; //visual feedback of upload
                                });
                                await androidIOSUpload();
                                setState(() {
                                  _uploading = false; //visual feedback of upload
                                });

                                if(_displayImg == _defaultImg){
                                  print("Not change image. it will use default image.");
                                }

                              },
                              child: null
                          ),
                        ),
                        TextFormField(
                          controller: _textNameController,
                          validator: (value) {
                            return value.isNotEmpty ? null : "Invalid Input";
                          },
                          decoration: InputDecoration(hintText: "Enter Name"),
                        ),
                        TextFormField(
                          controller: _textStuIdController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            return value.isNotEmpty ? null : "Invalid Input";
                          },
                          decoration: InputDecoration(
                              hintText: "Enter Student ID"),
                        )
                      ],
                    )
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () async{
                        print("confirm is click.");
                        var newStudent = Student();
                        if (_formKey.currentState.validate()) { //if it is validate
                          newStudent.name = _textNameController.text;
                          newStudent.id = _textStuIdController.text;
                          if(_displayImg == _defaultImg){
                            _displayImg = await getImageFileFromAssets('assets/images/man.png');
                          }
                          newStudent.img = base64Encode(_displayImg.readAsBytesSync());
                          //initial grade
                          List<String> emptyGrade = new List<String>();
                          for(int i=0; i<schemesLength; i++){
                            emptyGrade.add("");
                          }
                          newStudent.grades = emptyGrade;
                          newStudent.pk = "";

                          Provider.of<AllModels>(context, listen: false).addStudent(newStudent);
                          Navigator.of(context).pop(); //close the pop up
                          setState((){
                            filterController.text = "";
                          });

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
      students = allModels.stuItems;
      if(filterController.text == ""){
        print("rebuild");
        filterStudents.clear();
        for(Student s in students){
          filterStudents.add(s);
        }
      }
      List<Scheme> schemes = allModels.schItems;
      schemesLength = schemes.length;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                child: TextFormField(
                  controller: filterController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: "Search student",
                    hintText: "Type student name or id",
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (filter){
                    print("filter: "+filter);
                    ((){
                      filterController.text = filter;
                      filterController.selection = TextSelection.fromPosition(TextPosition(offset: filterController.text.length));
                    });

                    setState(() {
                      if(filter != ""){
                        filterStudents.clear();
                        for(Student s in students){
                          final lowName = s.name.toLowerCase();
                          final lowText = filter.toLowerCase();
                          if(lowName.length >= lowText.length && lowText == lowName.substring(0, lowText.length)){
                            filterStudents.add(s);
                          }
                        }
                        if(num.tryParse(filter)!=null){
                          filterStudents.clear();
                          for(Student s in students){
                            final lowName = s.id.toLowerCase();
                            final lowText = filter.toLowerCase();
                            if(lowName.length >= lowText.length && lowText == lowName.substring(0, lowText.length)){
                              filterStudents.add(s);
                            }
                          }
                        }
                      }
                    });
                  },
                ),
              ),
              if (allModels.loading) CircularProgressIndicator() else
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (_, index) {
                      var student = filterStudents[index];
                      Uint8List bytes = Base64Decoder().convert(student.img);
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 16,
                        color: Colors.white,
                        shadowColor: Colors.black38,
                        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                        child: Dismissible(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(calculate.calculateStudentAvg(
                                    student.grades, schemes).toString() + "%",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text("Avg grade",
                                  style: TextStyle(fontSize: 12))
                              ],
                            ),
                            onTap: () {
                              print(student.name + " is tapped!");
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context){
                                    return StudentDetail(pk: student.pk);
                                  }
                              ));
                            },
                          ),
                          background: Container(
                            color: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.delete, color: Colors.white),
                                  Text('Move to trash', style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(Icons.delete, color: Colors.white),
                                  Text('Move to trash', style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                          confirmDismiss: (DismissDirection direction) async {
                            return await showDialog(context: context,
                                builder: (BuildContext context){
                                  return AlertDialog(
                                    title: Text("Delete Alert"),
                                    content: Text("Are you sure you want to delete "+student.name+" ("+student.id+") ?"),
                                    actions: <Widget>[
                                      FlatButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel")),
                                      FlatButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Delete", style: TextStyle(color: Colors.red)
                                      )),
                                    ],
                                  );
                                }
                            );
                          },
                          key: ValueKey<Student>(student),
                          onDismissed: (DismissDirection direction) {
                            setState(() {
                              allModels.deleteStudent(student.pk);
                              filterController.text = "";
                            });
                          },
                        ),
                      );
                    },
                    itemCount: filterStudents.length,
                  ),
                )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "studentAdd",
          onPressed: () async {
            showAddDialog(context);
          },
          tooltip: 'Add Student',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    }
  }

