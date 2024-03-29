import 'package:mongo_dart/mongo_dart.dart';
import 'package:decimal/decimal.dart';

void main() async {
  final db = Db('mongodb://127.0.0.1/testdb');
  await db.open();
  var collection = db.collection('orders');
  await collection.drop();
  await collection.insertMany([
    {'status': 'A', 'cust_id': 3, 'amount': Decimal.fromInt(128)},
    {'status': 'B', 'cust_id': 2, 'amount': Decimal.fromInt(100)},
    {'status': 'A', 'cust_id': 1, 'amount': Decimal.fromInt(80)},
    {'status': 'A', 'cust_id': 3, 'amount': Decimal.fromInt(72)},
  ]);
  final pipeline = AggregationPipelineBuilder()
      .addStage(Match(where.eq('status', 'A').map['\$query']))
      .addStage(
          Group(id: Field('cust_id'), fields: {'total': Sum(Field('amount'))}))
      .build();
  final result =
      await DbCollection(db, 'orders').modernAggregate(pipeline).toList();
  result.forEach(print);
}
