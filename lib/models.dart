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


class AllModels extends ChangeNotifier {
  final List<Student> stuItems = [];
  final List<Scheme> schItems = [];

  CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');

  CollectionReference schemesCollection = FirebaseFirestore.instance.collection('schemes');

  bool loading = false;

  AllModels() {
    fetchAll();
  }

  Student getStudent(String pk){
    if (pk == null) return null;
    return stuItems.firstWhere((student) => student.pk == pk);
  }

  void deleteStudent(String pk) async
  {
    loading = true;
    notifyListeners();
    await studentsCollection.doc(pk).delete();

    await fetchAll();
  }

  void addStudent(Student item) async
  {
    loading = true;
    notifyListeners();
    await studentsCollection.add(item.toJson());
    //refresh the db
    await fetchAll();
  }

  void updateStudent(String pk, Student item) async
  {
    loading = true;
    notifyListeners();
    await studentsCollection.doc(pk).set(item.toJson());
    await fetchAll();
  }

  Scheme getScheme(String pk){
    if (pk == null) return null;
    return schItems.firstWhere((scheme) => scheme.pk == pk);
  }

  void addScheme(Scheme item) async
  {
    loading = true;
    notifyListeners();
    await schemesCollection.add(item.toJson());
    //refresh the db
    await fetchAll();
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