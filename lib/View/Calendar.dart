import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

import 'package:date_activity/utils.dart';
import 'package:date_activity/Controller/ActivityController.dart';
import 'package:date_activity/main.dart';
import 'package:date_activity/View/EditActivity.dart';
import 'package:date_activity/Model/ActivityData.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  TextEditingController _name = TextEditingController();
  TextEditingController _desController = TextEditingController();

  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  @override
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      // Update values in a Set
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _desController.dispose();
    super.dispose();
  }



  void _onDelete() {

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm?', style: TextStyle(fontSize: 24)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'No'),
            child: const Text('No', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: ()  {

              var a = ActivityController.activityDataList.last;
              HiveData hiveData = HiveData();
              hiveData.deleteActivityData(a.key);

              ActivityController.activityDataList.clear();

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage()), (route) => false);
            },
            child: const Text('Yes', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  void _onUpdate() {

    var a = ActivityController.activityDataList.last;

    a.days = _selectedDays.toList();
    a.count = _selectedDays.length;

    HiveData hiveData = HiveData();
    hiveData.updateActivityData(a.key, a);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Done "+a.count.toString()+" days", style: TextStyle(fontSize: 20)),
        ));

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EditActivity()), (route) => false);

  }

  void _editName() {
    _name.text = ActivityController.activityDataList.last.name;
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Enter name', style: TextStyle(fontSize: 24)),
        content: TextField(
            decoration: const InputDecoration(
              labelText: "Name", labelStyle: TextStyle(fontSize: 20)),
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

  void _editDes() {
    _desController.text = ActivityController.activityDataList.last.description;
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Details', style: TextStyle(fontSize: 24)),
        content: TextField(
          controller: _desController,
          style: const TextStyle(fontSize: 20),
          maxLines : 8,
          minLines: 8,
          decoration: const InputDecoration(border: InputBorder.none),
          autofocus: true,

        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: ()  {

              var a = ActivityController.activityDataList.last;

              a.description = _desController.text;
              HiveData hiveData = HiveData();
              hiveData.updateActivityData(a.key, a);

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EditActivity()), (route) => false);

            },
            child: const Text('Ok', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ActivityController.activityDataList.last.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              ),
              onTap: _editName),
    ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              child:
              TableCalendar<Event>(
                calendarBuilders : const CalendarBuilders(),
                headerStyle: const HeaderStyle(
                  formatButtonVisible : false,
                ),
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
                  // Use values from Set to mark multiple days as selected
                  return _selectedDays.contains(day);
                },
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                onCalendarCreated: (PageController) {

                  List<DateTime> days = ActivityController.activityDataList.last.days;

                  if (days != null) {
                    days.forEach((element) {
                      _selectedDays.add(element);
                    });
                  }
                }
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: 500,
                  height: 200,
                  child: SingleChildScrollView(
                    child: Text(
                      ActivityController.activityDataList.last.description,
                      style: const TextStyle(fontSize: 20),

                    ),
                  ),
                ),
              onTap: _editDes,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _onUpdate,
                icon:Icon(Icons.check),
                label:
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                  child: Text("Update", style: TextStyle(fontSize: 24)),
                ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  )
                ),
              ),

              const SizedBox(width: 15),

              ElevatedButton.icon(
                onPressed: _onDelete,
                icon:Icon(Icons.delete),
                label:
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                  child: Text("Delete", style: TextStyle(fontSize: 24)),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    )
                ),
              ),
            ],
          ),
          SizedBox(height: 20,)
        ],
      );
  }
}
