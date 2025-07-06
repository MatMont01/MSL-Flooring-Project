// lib/core/providers/session_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/entities/session_entity.dart';

// Este StateNotifier se mantiene igual.
class SessionNotifier extends StateNotifier<SessionEntity?> {
  SessionNotifier() : super(null);

  void setSession(SessionEntity session) {
    state = session;
  }

  void clearSession() {
    state = null;
  }
}

// El provider global de la sesión se mantiene igual.
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionEntity?>((
  ref,
) {
  return SessionNotifier();
});

// --- AÑADE ESTE NUEVO PROVIDER ---
// Este provider deriva su estado del sessionProvider.
// Su única misión es devolver un booleano: true si es admin, false si no.
// Es la forma más limpia y reactiva de obtener este valor.
// En tu session_provider.dart, verifica que el isAdminProvider esté bien:
final isAdminProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionProvider);
  return session?.isAdmin ?? false;
});
