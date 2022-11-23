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
  TextEditingController _name = TextEditingController();

  void _editName() {
    _name.text = ActivityController.activityDataList.last.name;
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Enter name', style: TextStyle(fontSize: 24)),
        content: TextField(
          decoration: const InputDecoration(
            labelText: "Name",
            labelStyle: TextStyle(fontSize: 20),
            counter: Offstage(),
          ),
          controller: _name,
          maxLength: 32,
          autofocus: true,
          style: const TextStyle(fontSize: 24),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: ()  {

              var a = ActivityController.activityDataList.last;

              if (_name.text.isNotEmpty) {
                a.name = _name.text;
                HiveData hiveData = HiveData();
                hiveData.updateActivityData(a.key, a);

                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EditActivity()), (route) => false);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter name", style: TextStyle(fontSize: 20)),
                    ));
              }
            },
            child: const Text('Ok', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset:false,
        appBar: AppBar(

          title: TextButton(
            onPressed: _editName,
            child: Text(
                ActivityController.activityDataList.last.name,
                style: Theme.of(context).brightness == Brightness.dark ? TextStyle(fontSize: 22,color: Colors.white) : TextStyle(fontSize: 22,color: Colors.black)),
          ),

        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton (
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {

            ActivityController.activityDataList.clear();

            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage()), (route) => false);
          },
        ),
      ),
    body: Container(
      child: SingleChildScrollView(child: Calendar())
      )
    );
  }
}
