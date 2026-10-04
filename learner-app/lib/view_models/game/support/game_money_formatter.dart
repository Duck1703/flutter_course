String formatGameMoney(int amount) {
  final text = amount.toString();
  final buffer = StringBuffer(r'$');
  for (var index = 0; index < text.length; index++) {
    if (index > 0 && (text.length - index) % 3 == 0) buffer.write(',');
    buffer.write(text[index]);
  }
  return buffer.toString();
}
