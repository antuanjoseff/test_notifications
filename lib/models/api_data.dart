sealed class ApiData<T> {
  const ApiData();
}

class Success<T> extends ApiData<T> {
  final T data;
  const Success({required this.data});
}

class ExceptionError<T> extends ApiData<T> {
  final Exception exception;
  const ExceptionError({required this.exception});
}

class Error<T> extends ApiData<T> {
  final String message;
  const Error({required this.message});
}
