import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';


class Calculator
{

  String calculateClassAvg(Scheme scheme, List<Student> students){
    double sum = 0.0;
      switch(scheme.type){
        case "level_HD":
          for(int i=0; i<students.length; i++ ){
            sum +=  transferLevelHD((students[i].grades)[scheme.week-1]);
          }
          return (sum/students.length.toDouble()).toStringAsFixed(1)+" /100.0";
        case "level_A":
          for(int i=0; i<students.length; i++ ){
            sum +=  transferLevelA((students[i].grades)[scheme.week-1]);
          }
          return (sum/students.length.toDouble()).toStringAsFixed(1)+" /100.0";
        case "attendance":
          for(int i=0; i<students.length; i++ ){
            sum +=  transferAttendance((students[i].grades)[scheme.week-1]);
          }
          return (sum/students.length.toDouble()).toStringAsFixed(1)+" /100.0";
        case "score":
          for(int i=0; i<students.length; i++ ){
            if((students[i].grades)[scheme.week-1] != ""){
              sum += double.parse((students[i].grades)[scheme.week-1]);
            }
          }
          return (sum/students.length.toDouble()).toStringAsFixed(1)+" /"+scheme.extra+".0";
        case "checkbox":
          for(int i=0; i<students.length; i++ ){
            if((students[i].grades)[scheme.week-1] != ""){
              sum += countCheckBox((students[i].grades)[scheme.week-1]);
            }
          }
          return (sum/students.length.toDouble()).toStringAsFixed(1)+" /"+scheme.extra+".0";
        default:
          return "N/A";
    }
  }

  num calculateStudentAvg(List<String> grades, List<Scheme> schemes){
    //print("shceme size: "+schemes.length.toString());
    double sum = 0.0;
    for(int i=0; i<schemes.length; i++){
      switch(schemes[i].type){
        case "level_HD":
          sum += transferLevelHD(grades[schemes[i].week-1]);
          break;
        case "level_A":
          sum += transferLevelA(grades[schemes[i].week-1]);
          break;
        case "attendance":
          sum += transferAttendance(grades[schemes[i].week-1]);
          break;
        case "score":
          sum += convertNewBaseOfScore(grades[schemes[i].week-1], schemes[i].extra, 100.0);
          break;
        case "checkbox":
          sum += getCheckBoxScore(grades[schemes[i].week-1]);
          break;
        default:
          break;
      }
    }
    return num.parse((sum/schemes.length.toDouble()).toStringAsFixed(1));
  }

  num transferLevelHD(String grade){
    switch(grade){
      case "HD+":
        return 100.0;
      case "HD":
        return 80.0;
      case "DN":
        return 70.0;
      case "CR":
        return 60.0;
      case "PP":
        return 50.0;
      case "NN":
        return 0.0;
      default: //empty case
        return 0.0;
    }
  }

  num transferLevelA(String grade){
    switch(grade){
      case "A":
        return 100.0;
      case "B":
        return 80.0;
      case "C":
        return 70.0;
      case "D":
        return 60.0;
      case "F":
        return 0.0;
      default: //empty case
        return 0.0;
    }
  }

  num transferAttendance(String grade){
    switch(grade){
      case "Attend":
        return 100.0;
      case "Absent":
        return 0.0;
      default:
        return 0.0;
    }
  }

  num convertNewBaseOfScore(String score, String extra, num base){
    if(score == "")
    {
      return 0.0;
    }
    return double.parse(score)/double.parse(extra)*base.toDouble();
  }

  num countCheckBox(String s){
    List<String> boxes = s.split(",");
    int n = 0;
    for(String b in boxes){
      if(b == '1'){
        n++;
      }
    }
    return n;
  }

  num getCheckBoxScore(String s){
    if(s == ""){
      return 0.0;
    }
    List<String> boxes = s.split(",");
    return countCheckBox(s).toDouble()/boxes.length.toDouble()*100.0;
  }

}