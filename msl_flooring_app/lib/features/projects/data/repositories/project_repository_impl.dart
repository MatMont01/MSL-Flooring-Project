// lib/features/projects/data/repositories/project_repository_impl.dart

import '../../../../core/error/failure.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProjectEntity>> getAllProjects() async {
    try {
      // Llama al método del datasource para obtener los datos.
      // Como ProjectModel hereda de ProjectEntity, la conversión es implícita
      // y no se necesita un mapeo adicional aquí.
      return await remoteDataSource.getAllProjects();
    } on Failure catch (e) {
      // Si el error ya es una de nuestras Fallas personalizadas (ej. ServerFailure),
      // simplemente la relanzamos para que la capa superior la maneje.
      throw e;
    } catch (e) {
      // Si es cualquier otro tipo de error inesperado, lo envolvemos en nuestra
      // Falla genérica para mantener la consistencia.
      throw const ServerFailure(
        'Ocurrió un error inesperado al obtener los proyectos.',
      );
    }
  }
}
