// lib/core/error/failure.dart

// Una clase genérica para representar fallos en la aplicación.
// Puede ser un error de servidor, un error de red, etc.
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

// Falla específica para errores que vienen del servidor (ej. 401, 404, 500).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Falla para cuando no hay conexión a internet.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}