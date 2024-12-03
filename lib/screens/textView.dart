import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCardExample extends StatefulWidget {
  final text;

  CustomCardExample({required this.text});

  @override
  _CustomCardExampleState createState() => _CustomCardExampleState();
}

class _CustomCardExampleState extends State<CustomCardExample> {
  double _fontSize=22;

  @override
  void initState() {
    super.initState();
    _fontSize = 22;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[600],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF2C2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                   widget.text,
                    style: TextStyle(fontSize: _fontSize),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(width: 10),
                Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.yellow[700],
                        inactiveTrackColor: Colors.grey[400],
                        thumbColor: Colors.yellow[700],
                        valueIndicatorColor: Colors.yellow[700],
                      ),
                      child: Slider(
                      activeColor: Color(0xFFFFF2C2),
                      value: _fontSize,
                      min: 22,
                      max: 100,

                      label: _fontSize.round().toString(),
                      onChanged: (double newSize) {
                        setState(() {
                          _fontSize = newSize;
                        });
                      },
                    ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
