import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? privacyPolicyText;

  getPolicy() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    String value = box.get('policy');

    if (value != null) {


      setState(() {
        privacyPolicyText = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: Text('Privacy Policy'),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            privacyPolicyText??"",
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
              height: 1.5, // line height to improve readability
            ),
          ),
        ),
      ),
    );
  }
}
