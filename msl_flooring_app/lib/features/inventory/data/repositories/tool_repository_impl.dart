// lib/features/inventory/data/repositories/tool_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/tool_entity.dart';
import '../../domain/entities/tool_request_entity.dart';
import '../../domain/repositories/tool_repository.dart';
import '../datasources/tool_remote_data_source.dart';
import '../models/tool_request_model.dart';

class ToolRepositoryImpl implements ToolRepository {
  final ToolRemoteDataSource remoteDataSource;

  ToolRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ToolEntity>> getAllTools() async {
    try {
      return await remoteDataSource.getAllTools();
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener las herramientas.',
      );
    }
  }

  @override
  Future<ToolEntity> getToolById(String toolId) async {
    try {
      return await remoteDataSource.getToolById(toolId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener la herramienta.',
      );
    }
  }

  @override
  Future<ToolEntity> createTool(ToolRequestEntity tool) async {
    try {
      final model = ToolRequestModel(
        name: tool.name,
        description: tool.description,
      );
      return await remoteDataSource.createTool(model);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al crear la herramienta.',
      );
    }
  }

  @override
  Future<ToolEntity> updateTool(String toolId, ToolRequestEntity tool) async {
    try {
      final model = ToolRequestModel(
        name: tool.name,
        description: tool.description,
      );
      return await remoteDataSource.updateTool(toolId, model);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al actualizar la herramienta.',
      );
    }
  }

  @override
  Future<void> deleteTool(String toolId) async {
    try {
      await remoteDataSource.deleteTool(toolId);
    } on Failure {
      rethrow;
    } catch (e) {
      throw const ServerFailure(
        'Ocurrió un error inesperado al eliminar la herramienta.',
      );
    }
  }
}