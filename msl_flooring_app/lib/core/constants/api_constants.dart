// lib/core/constants/api_constants.dart

class ApiConstants {
  // --- URLs Base de los Microservicios ---

  // URL del servicio de autenticación
  // Puerto: 8081
  static const String authServiceBaseUrl = 'http://localhost:8081/api/auth';

  // URL del servicio de proyectos
  // Puerto: 8082
  static const String projectServiceBaseUrl = 'http://localhost:8082/api/projects';

  // URL del servicio de trabajadores
  // Puerto: 8083
  static const String workerServiceBaseUrl = 'http://localhost:8083/api/workers';

  // URL del servicio de inventario
  // Puerto: 8084
  static const String inventoryServiceBaseUrl = 'http://localhost:8084/api';

  // URL del servicio de notificaciones
  // Puerto: 8085
  static const String notificationServiceBaseUrl = 'http://localhost:8085/api';

  // URL del servicio de analíticas
  // Puerto: 8086
  static const String analyticsServiceBaseUrl = 'http://localhost:8086/api';

  // --- Endpoints Específicos (Ejemplo para auth-service) ---
  static const String loginEndpoint = '/login'; //
  static const String registerEndpoint = '/register'; //
  static const String validateTokenEndpoint = '/validate'; //
}