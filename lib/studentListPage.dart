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
      schemesLength = schemes.length;
      return Scaffold(
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
                      return Dismissible(
                        child: ListTile(
                          title: Text(student.name),
                          subtitle: Text(student.id),
                          leading: Container(
                            width: 70,
                            child: Image.memory(bytes, fit: BoxFit.contain,),
                          ),
                          trailing: Text(calculate.calculateStudentAvg(
                              student.grades, schemes).toString() + "%",
                              style: TextStyle(fontSize: 18),
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

