class Failure implements Exception {
  final String message;
  final Object? exception;
  final StackTrace stackTrace;

  Failure(this.message, [this.exception, StackTrace? stackTrace])
      : stackTrace = stackTrace ?? StackTrace.current;

  const Failure.unknown(this.exception, this.stackTrace)
      : message = 'Something went wrong, please try again later.';
}
