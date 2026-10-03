import 'package:intl/intl.dart';

class Formatters {
  static String currency(num amount, {bool includeSymbol = true}) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    final formatted = formatter.format(amount);
    return includeSymbol ? '৳$formatted' : formatted;
  }

  static String phone(String phone) {
    if (phone.length == 11) {
      return '${phone.substring(0, 5)} ${phone.substring(5, 8)} ${phone.substring(8)}';
    }
    return phone;
  }

  static String formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0 && dateTime.day == now.day) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays <= 1 && now.day - dateTime.day == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('d MMM yyyy, h:mm a').format(dateTime);
    }
  }

  static String formatRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0 && dateTime.day == now.day) {
      return 'Today';
    } else if (difference.inDays <= 7) {
      return 'This Week';
    } else {
      return 'Earlier';
    }
  }
}
