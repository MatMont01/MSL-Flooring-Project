// lib/features/projects/presentation/providers/project_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msl_flooring_app/features/auth/presentation/providers/auth_providers.dart';

import '../../data/datasources/project_remote_data_source.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';

// --- Providers para la infraestructura de datos de Proyectos ---

// 1. Provider para el ProjectRemoteDataSource
final projectRemoteDataSourceProvider = Provider<ProjectRemoteDataSource>((
  ref,
) {
  // Reutilizamos el apiClientProvider que ya maneja el token
  final apiClient = ref.watch(apiClientProvider);
  return ProjectRemoteDataSourceImpl(apiClient: apiClient);
});

// 2. Provider para el ProjectRepository
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final remoteDataSource = ref.watch(projectRemoteDataSourceProvider);
  return ProjectRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- State Notifier para la lista de Proyectos ---

// 3. Provider del Notifier que nuestra UI observará
final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, ProjectListState>((ref) {
      final projectRepository = ref.watch(projectRepositoryProvider);
      // Creamos la instancia y llamamos al método para cargar los datos iniciales
      return ProjectListNotifier(projectRepository)..fetchProjects();
    });

// --- Clases de Estado para la UI ---

// 4. Definimos los posibles estados de nuestra pantalla de proyectos
abstract class ProjectListState {}

class ProjectListInitial extends ProjectListState {}

class ProjectListLoading extends ProjectListState {}

class ProjectListSuccess extends ProjectListState {
  final List<ProjectEntity> projects;

  ProjectListSuccess(this.projects);
}

class ProjectListFailure extends ProjectListState {
  final String message;

  ProjectListFailure(this.message);
}

// --- El Notifier ---

// 5. La clase que contiene la lógica para obtener los datos y manejar el estado
class ProjectListNotifier extends StateNotifier<ProjectListState> {
  final ProjectRepository _projectRepository;

  ProjectListNotifier(this._projectRepository) : super(ProjectListInitial());

  Future<void> fetchProjects() async {
    try {
      state = ProjectListLoading();
      final projects = await _projectRepository.getAllProjects();
      state = ProjectListSuccess(projects);
    } catch (e) {
      state = ProjectListFailure(e.toString());
    }
  }
}
