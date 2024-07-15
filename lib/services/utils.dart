// create function that formats the date
import 'package:intl/intl.dart';

parseChatHistoryDate(String date) {
  return DateFormat('E, MMM d, h:mm a').format(DateTime.parse(date));
}

parseChatDate(String date) {
  return DateFormat.jm().format(DateTime.parse(date));
}