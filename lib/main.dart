// Copyleft 2022 Santiago Rojas
// SPDX-License-Identifier: GPL-3.0


import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

import 'package:date_activity/Model/ActivityData.dart';
import 'package:date_activity/Controller/ActivityController.dart';
import 'package:date_activity/View/EditActivity.dart';

late Box box;

Future<void> main() async {

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Hive.initFlutter();
  box = await Hive.openBox('box');
  Hive.registerAdapter(ActivityDataAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ActivityOnTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: ThemeMode.system,
      /* ThemeMode.system to follow system theme,
         ThemeMode.light for light theme,
         ThemeMode.dark for dark theme
      */


      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _name = TextEditingController();
  final HiveData hiveData = const HiveData();
  List<ActivityData> activities = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    activities = await hiveData.activities;

    setState((){});
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }



  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final Box<ActivityData> box = await Hive.openBox<ActivityData>('activity');

    setState(() {

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      var a = activities.removeAt(oldIndex);
      activities.insert(newIndex, a);

      for (var element in box.values) {
        element.delete();
      }

      for (int i = 0; i < activities.length; i++) {
        box.add(activities[i]);
      }
    });


  }

  void addActivity() {

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Center(child: Text('Add Activity', style: TextStyle(fontSize: 28),)),
        actionsAlignment: MainAxisAlignment.center,
          content: TextField(controller: _name, autofocus: true, maxLength: 32, style: const TextStyle(fontSize: 24),),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel', style: TextStyle(fontSize: 20),),
          ),
          TextButton(
            onPressed: () async {
              String name = _name.text;
              if (name.isNotEmpty) {
                await hiveData.createActivityData(ActivityData(
                    _name.text
                ));

                await getData();

                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()), (route) => false);
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter name", style: TextStyle(fontSize: 20)),
                    ));
              }
            },
            child: const Text('Add', style: TextStyle(fontSize: 20),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      appBar: AppBar(
        title: const Text("Activities", style: TextStyle(fontSize: 24),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => addActivity(),
            tooltip: 'ADD',
          )],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
            child:
                ReorderableListView.builder(
                itemCount: activities.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.8))),
                    key: Key('$index'),

                    child: ListTile(
                      title: Text(activities[index].name,  style: const TextStyle(fontSize: 24)),
                        subtitle: Text(activities[index].count.toString(), style: const TextStyle(fontSize: 20)),
                        onTap: () {

                          ActivityController.intoList(activities[index]);
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EditActivity()), (route) => false);

                      }
                    ),
                  );
                },
                onReorder: _onReorder,
              ),
            )
          ]
        )
      )
    );
  }
}