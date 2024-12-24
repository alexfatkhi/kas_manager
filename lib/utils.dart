import 'package:intl/intl.dart';

String formarCurrency(num number) {
  return NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp. ',
    decimalDigits: 0,
  ).format(number);
}
