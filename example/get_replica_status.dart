import 'package:mongo_dart/mongo_dart.dart';

/// At the moment you can only run getStatus() command on primary
/// On secondary we get a "MongoDart Error: No master connection" because we have no read permission on it
/// To test with secondary you can comment our the lines 29 and 31 in connection_manager.dart
main() async {
  var db = new Db("mongodb://127.0.0.1:27017/admin");
  await db.open();

  Map<String, dynamic> rep_status = await db.getStatus();
  //print(rep_status);
  if (rep_status.containsKey("members")) {
    List<dynamic> members = rep_status['members'];
    int members_count = members.length;
    print("Members Count: " + members_count.toString());
    members.forEach((dynamic value) {
      print("-----------------------------------");
      //print(value);
      int _id = value['_id'];
      String name = value['name'];
      double health = value['health'];
      String stateStr = value['stateStr'];
      int uptime = value['uptime'];

      print("Member id: " + _id.toString());
      print("Member name: " + name);
      print("Member health: " + health.toString());
      print("Member State: " + stateStr.toString());
      print("Member State: " + secToTime(uptime));
    });
  }

  await db.close();
}

String secToTime(int seconds) {
  double hours = seconds / 3600;
  double mins = seconds / 60 % 60;
  int secs = seconds % 60;
  return hours.floor().toString() +
      "h " +
      mins.floor().toString() +
      "m " +
      secs.floor().toString() +
      "s";
}
