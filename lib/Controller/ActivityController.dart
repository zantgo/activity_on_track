import 'package:date_activity/Model/ActivityData.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveData {
  const HiveData();
//CREATE
  Future<int> createActivityData (ActivityData a) async {
    final Box<ActivityData> box = await Hive.openBox<ActivityData >('activity');
    return box.add(a);
  }
//READ
  Future<List<ActivityData>> get activities async {
    final Box<ActivityData > box = await Hive.openBox<ActivityData >('activity');
    return box.values.toList();
  }
//UPDATE
  void updateActivityData (int i, ActivityData a) async {
    final Box<ActivityData> box = await Hive.openBox<ActivityData >('activity');
    return box.put(i, a);
  }
//DELETE
  void deleteActivityData (int i) async {
    final Box<ActivityData> box = await Hive.openBox<ActivityData >('activity');
    return box.delete(i);
  }
}

class ActivityController {

  static var activityDataList = <ActivityData>[];

  static void intoList(ActivityData a) {
    activityDataList.add(a);
  }

}

