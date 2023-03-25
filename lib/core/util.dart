import '../logger_wrap.dart';

int roundUnixTimeToDays(int unixTime) {
  int days = unixTime ~/ 86400000;
  int roundedUnixTime = days * 86400000;
  return roundedUnixTime;
}