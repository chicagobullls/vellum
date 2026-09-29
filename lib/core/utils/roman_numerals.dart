/// Utility for formatting numbers and dates into antique Roman numerals.
class RomanNumerals {
  static const List<int> _values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  static const List<String> _symbols = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];

  static String toRoman(int number) {
    if (number <= 0 || number > 3999) return number.toString();
    final buffer = StringBuffer();
    int num = number;
    for (int i = 0; i < _values.length; i++) {
      while (num >= _values[i]) {
        buffer.write(_symbols[i]);
        num -= _values[i];
      }
    }
    return buffer.toString();
  }

  /// Formats DateTime as: "XXIX · IX · MMXXVI"
  static String formatDateRoman(DateTime date) {
    final day = toRoman(date.day);
    final month = toRoman(date.month);
    final year = toRoman(date.year);
    return '$day · $month · $year';
  }
}
