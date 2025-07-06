// lib/features/inventory/data/repositories/tool_assignment_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/repositories/tool_assignment_repository.dart';
import '../datasources/tool_assignment_remote_data_source.dart';

class ToolAssignmentRepositoryImpl implements ToolAssignmentRepository {
  final ToolAssignmentRemoteDataSource remoteDataSource;

  ToolAssignmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createToolAssignment(Map<String, dynamic> assignmentData) async {
    try {
      await remoteDataSource.createToolAssignment(assignmentData);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al crear la asignación de herramienta.',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignmentsByTool(String toolId) async {
    try {
      return await remoteDataSource.getAssignmentsByTool(toolId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener las asignaciones de la herramienta.',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignmentsByWorker(String workerId) async {
    try {
      return await remoteDataSource.getAssignmentsByWorker(workerId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener las asignaciones del trabajador.',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignmentsByProject(String projectId) async {
    try {
      return await remoteDataSource.getAssignmentsByProject(projectId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener las asignaciones del proyecto.',
      );
    }
  }
}