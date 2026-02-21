import 'package:flutter_test/flutter_test.dart';
import 'package:diabeaty_mobile/core/utils/time_utils.dart';

void main() {
  group('[TDD Enforcer] TimeUtils', () {
    test('isMoreThanFiveMinutesOld returns true if difference is > 5 minutes', () {
      final now = DateTime.now();
      final sixMinutesAgo = now.subtract(const Duration(minutes: 6));
      
      final result = TimeUtils.isMoreThanFiveMinutesOld(sixMinutesAgo, now: now);
      expect(result, isTrue);
    });

    test('isMoreThanFiveMinutesOld returns false if difference is <= 5 minutes', () {
      final now = DateTime.now();
      final fourMinutesAgo = now.subtract(const Duration(minutes: 4));
      
      final result = TimeUtils.isMoreThanFiveMinutesOld(fourMinutesAgo, now: now);
      expect(result, isFalse);
    });
  });
}
