import 'package:flutter/material.dart';

import 'package:date_activity/Controller/ActivityController.dart';
import 'package:date_activity/main.dart';
import 'package:date_activity/View/Calendar.dart';

class EditActivity extends StatefulWidget {
  const EditActivity({Key? key}) : super(key: key);

  @override
  State<EditActivity> createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset:false,
        appBar: AppBar(
        title: const Text("Edit Activity", style: TextStyle(fontSize: 22),),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton (
          icon: Icon(Icons.backspace),
          onPressed: () {

            ActivityController.activityDataList.clear();

            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage()), (route) => false);
          },
        ),
      ),
    body: Container(
        //decoration: BoxDecoration(color: Colors.grey[100]),
      child: SingleChildScrollView(child: Calendar())
      )
    );
  }
}
