// lib/core/constants/api_constants.dart

class ApiConstants {
  // --- URLs Base de los Microservicios (VERSIÓN CORREGIDA PARA EMULADOR ANDROID) ---

  // IP especial para que el emulador de Android se conecte al localhost del host.
  static const String _androidEmulatorHost = '10.0.2.2';

  // URL del servicio de autenticación
  static const String authServiceBaseUrl =
      'http://$_androidEmulatorHost:8081/api/auth';

  // URL del servicio de proyectos
  static const String projectServiceBaseUrl =
      'http://$_androidEmulatorHost:8082/api/projects';

  // URL del servicio de trabajadores
  static const String workerServiceBaseUrl =
      'http://$_androidEmulatorHost:8083/api/workers';

  // URL del servicio de inventario
  static const String inventoryServiceBaseUrl =
      'http://$_androidEmulatorHost:8084/api';

  // URL del servicio de notificaciones
  static const String notificationServiceBaseUrl =
      'http://$_androidEmulatorHost:8085/api';

  // URL del servicio de analíticas
  static const String analyticsServiceBaseUrl =
      'http://$_androidEmulatorHost:8086/api';

  // --- Endpoints Específicos (se mantienen igual) ---
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String validateTokenEndpoint = '/validate';
}
