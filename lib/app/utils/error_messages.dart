String readableErrorMessage(Object error) {
  if (error is ArgumentError) {
    final message = error.message;
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
    return 'Dato inválido.';
  }

  if (error is StateError) {
    final message = error.message;
    if (message.trim().isNotEmpty) {
      return message;
    }
    return 'Estado inválido.';
  }

  if (error is FormatException) {
    return 'Formato inválido.';
  }

  final text = error.toString();
  const exceptionPrefix = 'Exception: ';
  if (text.startsWith(exceptionPrefix)) {
    return text.substring(exceptionPrefix.length);
  }
  const errorPrefix = 'Error: ';
  if (text.startsWith(errorPrefix)) {
    return text.substring(errorPrefix.length);
  }
  return text;
}
