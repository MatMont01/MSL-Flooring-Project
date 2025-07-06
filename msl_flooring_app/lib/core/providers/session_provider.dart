// lib/core/providers/session_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/entities/session_entity.dart';

// Este StateNotifier mantendrá la sesión del usuario (o null si no ha iniciado sesión)
class SessionNotifier extends StateNotifier<SessionEntity?> {
  SessionNotifier() : super(null);

  void setSession(SessionEntity session) {
    state = session;
  }

  void clearSession() {
    state = null;
  }
}

// El provider global que expondremos
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionEntity?>((
  ref,
) {
  return SessionNotifier();
});
