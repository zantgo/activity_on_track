import 'package:hive/hive.dart';

part 'ActivityData.g.dart';

@HiveType(typeId: 0)
class ActivityData extends HiveObject{
  ActivityData(this.name);
  @HiveField(0)
  String name;

  @HiveField(1)
  List<DateTime> days = [];

  @HiveField(2)
  int count = 0;

  @HiveField(3)
  String description = "";
}
