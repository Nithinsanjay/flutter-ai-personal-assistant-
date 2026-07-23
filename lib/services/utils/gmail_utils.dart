import 'dart:convert';

class GmailUtils {
  static String decodeBase64(String input) {
    try {
      String normalized = input.replaceAll('-', '+').replaceAll('_', '/');
      int padLength = (4 - (normalized.length % 4)) % 4;
      normalized += '=' * padLength;
      return utf8.decode(base64.decode(normalized), allowMalformed: true);
    } catch (_) {
      return '';
    }
  }

  static String cleanHtmlTags(String html) {
    if (!html.contains('<') || !html.contains('>')) return html;
    final regExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    String clean = html.replaceAll(regExp, ' ');
    clean = clean
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return clean;
  }

  static DateTime? parseHttpDate(String dateStr) {
    try {
      final cleanStr = dateStr.contains(',')
          ? dateStr.split(',')[1].trim()
          : dateStr.trim();
      final parts = cleanStr.split(' ');
      if (parts.length >= 4) {
        final day = int.parse(parts[0]);
        final monthStr = parts[1].toLowerCase();
        final year = int.parse(parts[2]);
        final timeParts = parts[3].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

        final monthNames = [
          'jan', 'feb', 'mar', 'apr', 'may', 'jun',
          'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
        ];
        final month = monthNames.indexOf(monthStr) + 1;

        if (month > 0) {
          return DateTime(year, month, day, hour, minute, second);
        }
      }
    } catch (_) {}
    return null;
  }
}
