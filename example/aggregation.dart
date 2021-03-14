import 'package:mongo_dart/mongo_dart.dart';
import 'package:rational/rational.dart';

void main() async {
  final db = Db('mongodb://127.0.0.1/testdb');
  await db.open();
  var collection = db.collection('orders');
  await collection.drop();
  await collection.insertMany([
    {'status': 'A', 'cust_id': 3, 'amount': Rational.fromInt(128)},
    {'status': 'B', 'cust_id': 2, 'amount': Rational.fromInt(100)},
    {'status': 'A', 'cust_id': 1, 'amount': Rational.fromInt(80)},
    {'status': 'A', 'cust_id': 3, 'amount': Rational.fromInt(72)},
  ]);
  final pipeline = AggregationPipelineBuilder()
      .addStage(Match(where.eq('status', 'A').map['\$query']))
      .addStage(
          Group(id: Field('cust_id'), fields: {'total': Sum(Field('amount'))}))
      .build();
  final result = await DbCollection(db, 'orders')
      .modernAggregate(pipeline)
      .toList();
  result.forEach(print);
}
