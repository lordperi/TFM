class TimeUtils {
  /// Devuelve true si la diferencia entre [target] y [now] es estrictamente mayor a 5 minutos.
  /// Si [now] no se proporciona, usa DateTime.now().
  static bool isMoreThanFiveMinutesOld(DateTime target, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final difference = currentTime.difference(target);
    
    return difference.inMilliseconds > (5 * 60 * 1000);
  }
}
