// Copyleft Santiago Rojas

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

import 'package:date_activity/Model/ActivityData.dart';
import 'package:date_activity/Controller/ActivityController.dart';
import 'package:date_activity/View/EditActivity.dart';

late Box box;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom, //This line is used for showing the bottom bar
  ]);

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

  String _onCount(int index) {

    var c = activities[index].count;

    if (c > 0) {
      return activities[index].count.toString();
    }
    return "";
  }

  void addActivity() {

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Center(child: Text('New', style: TextStyle(fontSize: 28),)),
        actionsAlignment: MainAxisAlignment.center,
          content: TextField(
            controller: _name,
            autofocus: true,
            maxLength: 32,
            style: const TextStyle(fontSize: 24),
            decoration: const InputDecoration(
              labelText: "Name",
              labelStyle: TextStyle(fontSize: 20),
              counter: Offstage(),
            ),
          ),
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
        title: const Text("ACTIVITIES", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: 2.0),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => addActivity(),
            tooltip: 'Add',
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
                    padding: const EdgeInsets.all(5.0),
                    key: Key('$index'),

                    child: Container(
                        padding: const EdgeInsets.all(10.0),

                    decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey,
                            width: 0.8,
                          ),
                    ),

                      child: ListTile(

                        leading: Text(
                          activities[index].name,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 24),
                        ),
                          title: Text(
                            _onCount(index),
                            //activities[index].count.toString(),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 22),
                          ),

                          onTap: () {
                            ActivityController.intoList(activities[index]);
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EditActivity()), (route) => false);

                        }
                      ),
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
