import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:share_plus/share_plus.dart';

class ShareAppScreen extends StatefulWidget {
  @override
  State<ShareAppScreen> createState() => _ShareAppScreenState();
}

class _ShareAppScreenState extends State<ShareAppScreen> {
  // Replace with your actual app store links
   String? iosAppLink ;
 // Your iOS app link
   String? androidAppLink ;


   getLinks() async {
     await Hive.initFlutter();
     var box = await Hive.openBox('myBox');
     Map<String,dynamic> value = box.get('links');

     if (value != null) {


       setState(() {
         iosAppLink = value['ios-url'];
         androidAppLink=value['android-url'];
       });
     }
   }

   @override
   void initState() {
     super.initState();
     getLinks();
   }
 // Your Android app link
  void _shareApp(String appLink, String platform) {
    Share.share(
      'Check out this amazing app on $platform: $appLink',
      subject: 'Share this app with your friends!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: Text('Share App with Others'),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(

              height: 300,
              child: Image.asset('assets/images/logo_png.png'), // Replace with your app icon
            ),
            SizedBox(height: 30,),
            Text(
              "Invite your friends to try this app!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _shareApp(iosAppLink??"", "Apple App Store"),
              icon: Icon(Icons.apple,color: Color(0xFF8C4A03),),
              label: Text("Share iOS App",style: TextStyle(fontSize: 18,color: Color(0xFF8C4A03)),),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18,color: Colors.white),
                backgroundColor: Colors.yellow[700],

              ),
            ),
            SizedBox(height: 16), // Spacing between buttons
            ElevatedButton.icon(
              onPressed: () => _shareApp(androidAppLink??"", "Google Play Store"),
              icon: Icon(Icons.android,color: Color(0xFF8C4A03),),
              label: Text("Share Android App",style: TextStyle(fontSize: 18,color: Color(0xFF8C4A03)),),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18,color: Colors.white),
                  backgroundColor: Colors.yellow[700]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
