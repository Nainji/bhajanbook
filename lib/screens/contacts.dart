import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ContactScreen extends StatefulWidget {
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
   List<dynamic> contacts = [];


  getContacts() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> value = box.get('contacts');

    if (value != null) {


      setState(() {
        contacts = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getContacts();
  }
  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: Text('Contacts'),

      child: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Color(0xFFFFF2C2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.yellow[700]),
                        SizedBox(width: 10),
                        Text(
                          contact['name'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.yellow[700]),
                        SizedBox(width: 10),
                        Text(
                          contact['email'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.yellow[700]),
                        SizedBox(width: 10),
                        Text(
                          'Phone Type: ${contact['phoneType']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    for (var phone in contact['phoneNumbers'])
                      Row(
                        children: [
                          Icon(Icons.call, color: Colors.yellow[700]),
                          SizedBox(width: 10),
                          Text(
                            'Number: ${phone['number']}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


