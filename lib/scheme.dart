import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

    //await Future.delayed(Duration(seconds: 2));
    loading = false;
    notifyListeners();
  }


}