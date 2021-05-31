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
      grades = json['grades'] as List;

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
    });

    await Future.delayed(Duration(seconds: 2));
    loading = false;
    notifyListeners();
  }


}