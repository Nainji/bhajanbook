import 'package:bhajan_book/screens/imagePreview.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // For storing image locally
import 'package:http/http.dart' as http;

import 'base.dart';

class Panchang extends StatefulWidget {
  const Panchang({super.key});

  @override
  State<Panchang> createState() => _PanchangState();
}

class _PanchangState extends State<Panchang> {

  Map<dynamic,dynamic> cards = {};

  getDarshans() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    Map<dynamic,dynamic> value = box.get('panchang');

    if (value != null) {


      setState(() {
        cards = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDarshans();
  }
  @override
  Widget build(BuildContext context) {

   return ImagePreviewScreen(imageUrls: [cards['image']], title: "Utsav Panchang",index: 0,);
  }
}


