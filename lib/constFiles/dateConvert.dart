import 'package:intl/intl.dart';

String dateConverter(DateTime dateTime) {
  // Format hanya untuk tanggal (tanpa waktu)
  print('format date');
  print(dateTime.toString());
  DateTime formattedDate =
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  DateTime todayNow = DateTime.now();
  DateTime yesterdayNow = DateTime.now().subtract(Duration(days: 1));

  DateTime todayDate = DateTime(todayNow.year, todayNow.month, todayNow.day);
  DateTime yesterdayDate =
      DateTime(yesterdayNow.year, yesterdayNow.month, yesterdayNow.day);

  // Bandingkan tanggal secara eksplisit
  if (formattedDate.year == todayDate.year &&
      formattedDate.month == todayDate.month &&
      formattedDate.day == todayDate.day) {
    return "Today";
  }

  if (formattedDate.year == yesterdayDate.year &&
      formattedDate.month == yesterdayDate.month &&
      formattedDate.day == yesterdayDate.day) {
    return "Yesterday";
  }

  return DateFormat("d MMM y").format(dateTime);
}
