class CurrencyFormatters {
  const CurrencyFormatters._();

  static String rupiah(int value) {
    if (value == 0) {
      return 'Rp0';
    }

    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final fromRight = text.length - i;
      buffer.write(text[i]);
      if (fromRight > 1 && fromRight % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }
}
