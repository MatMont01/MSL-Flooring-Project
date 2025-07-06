// lib/core/navigation/app_routes.dart

class AppRoutes {
  static const String login = '/login';
  static const String home =
      '/projects'; // Cambiemos /home a /projects para más claridad
  static const String projectDetails =
      '/projects/:id'; // Nueva ruta con parámetro

  // --- AÑADE ESTA LÍNEA ---
  static const String createProject = '/projects/create';
}
