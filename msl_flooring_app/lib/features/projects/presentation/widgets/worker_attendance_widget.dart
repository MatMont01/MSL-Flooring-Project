// lib/features/projects/presentation/widgets/worker_attendance_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../worker/presentation/providers/worker_providers.dart';

class WorkerAttendanceWidget extends ConsumerStatefulWidget {
  final String projectId;
  final double projectLatitude;
  final double projectLongitude;

  const WorkerAttendanceWidget({
    super.key,
    required this.projectId,
    required this.projectLatitude,
    required this.projectLongitude,
  });

  @override
  ConsumerState<WorkerAttendanceWidget> createState() =>
      _WorkerAttendanceWidgetState();
}

class _WorkerAttendanceWidgetState
    extends ConsumerState<WorkerAttendanceWidget> {
  Position? _currentPosition;
  bool _isWithinRange = false;
  bool _isLoadingLocation = true;
  String? _locationError;

  static const double _requiredRadiusMeters = 200.0;

  @override
  void initState() {
    super.initState();
    // 🔧 MOVEMOS LA LLAMADA A UN FUTURO PARA EVITAR EL ERROR
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocation();
      _checkAttendanceStatus();
    });
  }

  Future<void> _checkLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _locationError = null;
      });

      // 1. Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Los servicios de ubicación están deshabilitados';
          _isLoadingLocation = false;
          _isWithinRange = false;
        });
        return;
      }

      // 2. Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Los permisos de ubicación fueron denegados';
            _isLoadingLocation = false;
            _isWithinRange = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Los permisos de ubicación están denegados permanentemente';
          _isLoadingLocation = false;
          _isWithinRange = false;
        });
        return;
      }

      // 3. Obtener ubicación actual
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        widget.projectLatitude,
        widget.projectLongitude,
      );

      setState(() {
        _isWithinRange = distance <= _requiredRadiusMeters;
        _isLoadingLocation = false;
      });

      print(
        '🔍 [Attendance] Current position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
      );
      print(
        '🔍 [Attendance] Project position: ${widget.projectLatitude}, ${widget.projectLongitude}',
      );
      print('🔍 [Attendance] Distance: ${distance.toStringAsFixed(2)}m');
      print('🔍 [Attendance] Within range: $_isWithinRange');
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
        _isWithinRange = false;
      });
      print('🔴 [Attendance] Location error: $e');
    }
  }

  void _checkAttendanceStatus() {
    final session = ref.read(sessionProvider);
    if (session?.id != null) {
      // 🔧 USAMOS UN FUTURE PARA EVITAR EL ERROR DE MODIFICACIÓN DURANTE BUILD
      Future.microtask(() {
        ref
            .read(attendanceProvider(session!.id).notifier)
            .getStatus(widget.projectId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (session?.id == null) return const SizedBox.shrink();

    final attendanceState = ref.watch(attendanceProvider(session!.id));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Control de Asistencia',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estado de ubicación
            _buildLocationStatus(),

            const SizedBox(height: 16),

            // Botones de check-in/check-out
            _buildAttendanceButtons(attendanceState, session.id),

            const SizedBox(height: 16),

            // Estado actual de asistencia
            _buildCurrentAttendanceStatus(attendanceState),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    if (_isLoadingLocation) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Verificando ubicación...'),
          ],
        ),
      );
    }

    if (_locationError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_off, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Text(
                  'Error de ubicación',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _locationError!,
              style: TextStyle(fontSize: 12, color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: _checkLocation,
                  child: const Text('Reintentar'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _openLocationSettings,
                  child: const Text('Configuración'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final distance = _currentPosition != null
        ? Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            widget.projectLatitude,
            widget.projectLongitude,
          )
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isWithinRange ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isWithinRange ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isWithinRange ? Icons.location_on : Icons.location_searching,
                color: _isWithinRange ? Colors.green : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isWithinRange
                    ? 'Dentro del área de trabajo'
                    : 'Fuera del área de trabajo',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _isWithinRange
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Distancia: ${distance.toStringAsFixed(1)}m (Máx: ${_requiredRadiusMeters.toInt()}m)',
            style: TextStyle(
              fontSize: 12,
              color: _isWithinRange ? Colors.green[600] : Colors.orange[600],
            ),
          ),
          if (!_isWithinRange) ...[
            const SizedBox(height: 4),
            Text(
              'Acércate al proyecto para marcar asistencia',
              style: TextStyle(fontSize: 12, color: Colors.orange[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceButtons(dynamic attendanceState, String workerId) {
    final bool hasActiveRecord =
        attendanceState is AttendanceSuccess &&
        attendanceState.activeRecord != null;

    return Row(
      children: [
        // Botón de Check-in
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                (!hasActiveRecord && _isWithinRange && !_isLoadingLocation)
                ? () => _performCheckIn(workerId)
                : null,
            icon: Icon(
              Icons.login,
              color: (!hasActiveRecord && _isWithinRange && !_isLoadingLocation)
                  ? Colors.white
                  : Colors.grey[400],
            ),
            label: Text(
              'Marcar Entrada',
              style: TextStyle(
                color:
                    (!hasActiveRecord && _isWithinRange && !_isLoadingLocation)
                    ? Colors.white
                    : Colors.grey[400],
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (!hasActiveRecord && _isWithinRange && !_isLoadingLocation)
                  ? Colors.green
                  : Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Botón de Check-out
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                (hasActiveRecord && _isWithinRange && !_isLoadingLocation)
                ? () => _performCheckOut(attendanceState.activeRecord!.id)
                : null,
            icon: Icon(
              Icons.logout,
              color: (hasActiveRecord && _isWithinRange && !_isLoadingLocation)
                  ? Colors.white
                  : Colors.grey[400],
            ),
            label: Text(
              'Marcar Salida',
              style: TextStyle(
                color:
                    (hasActiveRecord && _isWithinRange && !_isLoadingLocation)
                    ? Colors.white
                    : Colors.grey[400],
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (hasActiveRecord && _isWithinRange && !_isLoadingLocation)
                  ? Colors.red
                  : Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentAttendanceStatus(dynamic attendanceState) {
    return switch (attendanceState) {
      AttendanceLoading() => const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ),
      AttendanceSuccess(activeRecord: final record) =>
        record != null
            ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.work, color: Colors.blue[600], size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Actualmente trabajando',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (record.checkInTime != null) ...[
                      Text(
                        'Entrada: ${DateFormat('HH:mm:ss').format(record.checkInTime!)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Tiempo transcurrido: ${_getElapsedTime(record.checkInTime!)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.grey, size: 16),
                    SizedBox(width: 8),
                    Text('No has marcado entrada hoy'),
                  ],
                ),
              ),
      AttendanceFailure(message: final message) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Text(
          'Error: $message',
          style: TextStyle(color: Colors.red[700]),
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  String _getElapsedTime(DateTime checkInTime) {
    final elapsed = DateTime.now().difference(checkInTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  void _performCheckIn(String workerId) {
    if (_currentPosition != null) {
      ref
          .read(attendanceProvider(workerId).notifier)
          .performCheckIn(widget.projectId);
    }
  }

  void _performCheckOut(String attendanceId) {
    final session = ref.read(sessionProvider);
    if (session?.id != null) {
      ref
          .read(attendanceProvider(session!.id).notifier)
          .performCheckOut(attendanceId);
    }
  }

  // 🔧 NUEVA FUNCIÓN PARA ABRIR CONFIGURACIÓN DE UBICACIÓN
  void _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
