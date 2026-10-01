sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AppConfigurationException extends AppException {
  const AppConfigurationException(super.message);
}

final class DataAccessException extends AppException {
  const DataAccessException(super.message);
}
