import 'package:mongo_dart/src/utils/timers.dart';
import 'package:test/test.dart';

void main() {
  group('Timeout', () {
    var delay = Duration(milliseconds: 50);

    test('Timeout', () async {
      var check = '';
      setTimeout(() {
        check = 'Checked!';
      }, delay);
      expect(check, isEmpty);

      await Future.delayed(delay);
      expect(check, isNotEmpty);
    });

    test('Timeout unref', () async {
      var check = '';
      var timeout = setTimeout(() {
        check = 'Checked!';
      }, delay);

      timeout.unref();
      await Future.delayed(delay);
      expect(check, isEmpty);
    });
    test('Timeout ref', () async {
      var check = '';
      var timeout = setTimeout(() {
        check = 'Checked!';
      }, delay);

      timeout.unref();
      timeout.ref();
      await Future.delayed(delay);
      expect(check, 'Checked!');
    });

    test('Timeout clear', () async {
      var check = '';
      var timeout = setTimeout(() {
        check = 'Checked!';
      }, delay);

      timeout.clear();
      timeout.ref();
      await Future.delayed(delay);
      expect(check, isEmpty);
    });

    test('Timeout late ref', () async {
      var check = '';
      var timeout = setTimeout(() {
        check = 'Checked!';
      }, delay);

      timeout.unref();
      await Future.delayed(delay);
      expect(check, isEmpty);
      timeout.ref();
      await Future.delayed(delay);
      expect(check, 'Checked!');
    });
  });

  group('Immediate', () {
    var delay = Duration(milliseconds: 1);

    test('Immediate', () async {
      var check = '';
      setImmediate(() {
        check = 'Checked!';
      });
      expect(check, isEmpty);
      await Future.delayed(delay);
      expect(check, 'Checked!');
    });

    test('Immediate unref', () async {
      var check = '';
      var immediate = setImmediate(() {
        check = 'Checked!';
      });

      immediate.unref();
      await Future.delayed(delay);
      expect(check, isEmpty);
    });
    test('Immediate ref', () async {
      var check = '';
      var immediate = setImmediate(() {
        check = 'Checked!';
      });

      immediate.unref();
      immediate.ref();
      await Future.delayed(delay);
      expect(check, 'Checked!');
    });

    test('Immediate clear', () async {
      var check = '';
      var immediate = setImmediate(() {
        check = 'Checked!';
      });

      immediate.clear();
      immediate.ref();
      await Future.delayed(delay);
      expect(check, isEmpty);
    });

    test('Immediate late ref', () async {
      var check = '';
      var immediate = setImmediate(() {
        check = 'Checked!';
      });

      immediate.unref();
      await Future.delayed(delay);
      expect(check, isEmpty);
      immediate.ref();
      await Future.delayed(delay);
      expect(check, 'Checked!');
    });
  });

  group('Interval', () {
    var delay = Duration(milliseconds: 50);

    test('Interval', () async {
      var check = '';
      setInterval(() {
        check = 'Checked!';
      }, delay);
      expect(check, isEmpty);

      await Future.delayed(delay);
      expect(check, isNotEmpty);
    });

    test('Interval unref', () async {
      var check = '';
      var interval = setInterval(() {
        check = 'Checked!';
      }, delay);

      interval.unref();
      await Future.delayed(delay);
      expect(check, isEmpty);
    });
    test('Interval ref', () async {
      var check = '';
      var interval = setInterval(() {
        check = 'Checked!';
      }, delay);

      interval.unref();
      interval.ref();
      await Future.delayed(delay);
      expect(check, 'Checked!');
    });

    test('Interval clear', () async {
      var check = '';
      var interval = setInterval(() {
        check = 'Checked!';
      }, delay);

      interval.clear();
      interval.ref();
      await Future.delayed(delay);
      expect(check, isEmpty);
    });

    test('Interval late ref', () async {
      var check = '';
      var interval = setInterval(() {
        check = 'Checked!';
      }, delay);

      interval.unref();
      await Future.delayed(delay);
      expect(check, isEmpty);
      interval.ref();
      await Future.delayed(delay);
      expect(check, 'Checked!');
    });
  });
}
