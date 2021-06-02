import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Student
{
  String pk;
  String name;
  String id;
  String img;
  List<String> grades;

  Student({this.pk, this.name, this.id, this.img, this.grades});

  Student.fromJson(Map<String, dynamic> json)
    :
      pk = json['pk'],
      name = json['name'],
      id = json['id'],
      img = json['img'],
      grades = json['grades'].cast<String>();

  Map<String, dynamic> toJson() =>
        {
          'pk': pk,
          'name': name,
          'id': id,
          'img': img,
          'grades': grades
        };


}

class StudentModel extends ChangeNotifier {
  final List<Student> items = [];

  CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');
  bool loading = false;

  StudentModel()
  {
    fetchStudents();
  }

  Student get(String pk){
    if (pk == null) return null;
    return items.firstWhere((student) => student.pk == pk);
  }

  void add(Student item) async
  {
    loading = true;
    notifyListeners();
    await studentsCollection.add(item.toJson());
    //refresh the db
    await fetchStudents();
  }

  void fetchStudents() async
  {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await studentsCollection.orderBy('id').get();
    querySnapshot.docs.forEach((doc) {
      var student = Student.fromJson(doc.data());
      student.pk = doc.id;
      items.add(student);
      //debug
      /*
      for(String g in student.grades){
        print("grade: "+g);
      }
       */

    });



    //await Future.delayed(Duration(seconds: 2));
    loading = false;
    notifyListeners();
  }


}

class Scheme
{
  String pk;
  int week;
  String type;
  String extra;

  Scheme({this.pk, this.week, this.type, this.extra});

  Scheme.fromJson(Map<String, dynamic> json)
      :
        pk = json['pk'],
        week = json['week'],
        type = json['type'],
        extra = json['extra'];

  Map<String, dynamic> toJson() =>
      {
        'pk': pk,
        'week': week,
        'type': type,
        'extra': extra
      };
}

class SchemeModel extends ChangeNotifier{

  final List<Scheme> items = [];

  CollectionReference schemesCollection = FirebaseFirestore.instance.collection('schemes');
  bool loading = false;

  SchemeModel()
  {
    fetchSchemes();
  }

  Scheme get(String pk){
    if (pk == null) return null;
    return items.firstWhere((scheme) => scheme.pk == pk);
  }

  void add(Scheme item) async
  {
    loading = true;
    notifyListeners();
    await schemesCollection.add(item.toJson());
    //refresh the db
    await fetchSchemes();
  }

  void fetchSchemes() async
  {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await schemesCollection.orderBy('week').get();
    querySnapshot.docs.forEach((doc) {
      var scheme = Scheme.fromJson(doc.data());
      scheme.pk = doc.id;
      items.add(scheme);
      //debug
    });
    /*
    for(Scheme i in items){
      print(i.pk);
      print(i.week);
    }
     */

    //await Future.delayed(Duration(seconds: 2));
    loading = false;
    notifyListeners();
  }


}

class AllModels extends ChangeNotifier {
  final List<Student> stuItems = [];
  final List<Scheme> schItems = [];

  CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');

  CollectionReference schemesCollection = FirebaseFirestore.instance.collection('schemes');

  bool loading = false;

  AllModels() {
    fetchAll();
  }


  void fetchAll() async
  {
    stuItems.clear();
    schItems.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await studentsCollection.orderBy('id').get();

    querySnapshot.docs.forEach((doc) {
      var student = Student.fromJson(doc.data());
      student.pk = doc.id;
      stuItems.add(student);
    });

    var querySnapshot_sch = await schemesCollection.orderBy('week').get();
    querySnapshot_sch.docs.forEach((doc) {
      var scheme = Scheme.fromJson(doc.data());
      scheme.pk = doc.id;
      schItems.add(scheme);
      //debug
    });



    //await Future.delayed(Duration(seconds: 2));
    loading = false;
    notifyListeners();
  }
}