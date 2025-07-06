// lib/features/projects/presentation/providers/project_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msl_flooring_app/features/auth/presentation/providers/auth_providers.dart';

import '../../../../core/providers/session_provider.dart';
import '../../data/datasources/project_remote_data_source.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/project_request_entity.dart';
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
      // Le pasamos el 'ref' al notifier
      // ¡HEMOS QUITADO LA LLAMADA "..fetchProjects()"!
      return ProjectListNotifier(projectRepository, ref);
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
// --- El Notifier (MODIFICADO CON print()) ---
class ProjectListNotifier extends StateNotifier<ProjectListState> {
  final ProjectRepository _projectRepository;
  final Ref _ref;

  ProjectListNotifier(this._projectRepository, this._ref)
    : super(ProjectListInitial());

  Future<void> fetchProjects() async {
    // Usamos print() para asegurar la visibilidad
    print('[ProjectNotifier] Fetching projects...');

    try {
      state = ProjectListLoading();
      print('[ProjectNotifier] State set to Loading.');

      final session = _ref.read(sessionProvider);
      if (session == null) {
        throw Exception(
          'Error: No hay sesión activa. No se pueden buscar proyectos.',
        );
      }

      final bool isAdmin = session.isAdmin;
      print('[ProjectNotifier] User is admin: $isAdmin');

      List<ProjectEntity> projects;

      if (isAdmin) {
        print('[ProjectNotifier] Calling getAllProjects() for admin.');
        projects = await _projectRepository.getAllProjects();
      } else {
        print('[ProjectNotifier] Calling getAssignedProjects() for worker.');
        projects = await _projectRepository.getAssignedProjects();
      }

      print(
        '[ProjectNotifier] Successfully fetched ${projects.length} projects.',
      );
      state = ProjectListSuccess(projects);
      print('[ProjectNotifier] State set to Success.');
    } catch (e, s) {
      // Capturamos el error (e) y el StackTrace (s)

      // ¡ESTE ES EL PRINT MÁS IMPORTANTE!
      print('======================================================');
      print('!!! ERROR en ProjectNotifier.fetchProjects !!!');
      print('Error: $e');
      print('StackTrace: \n$s');
      print('======================================================');

      state = ProjectListFailure(e.toString());
      print('[ProjectNotifier] State set to Failure.');
    }
  }
}
// --- Providers y Lógica para la Creación de Proyectos ---

// 1. Definimos los estados para el proceso de creación.
abstract class CreateProjectState {}

class CreateProjectInitial extends CreateProjectState {}

class CreateProjectLoading extends CreateProjectState {}

class CreateProjectSuccess extends CreateProjectState {
  final ProjectEntity newProject;

  CreateProjectSuccess(this.newProject);
}

class CreateProjectFailure extends CreateProjectState {
  final String message;

  CreateProjectFailure(this.message);
}

// 2. Creamos el Notifier que manejará la lógica de creación.
class CreateProjectNotifier extends StateNotifier<CreateProjectState> {
  final ProjectRepository _projectRepository;

  CreateProjectNotifier(this._projectRepository)
    : super(CreateProjectInitial());

  Future<void> createProject(ProjectRequestEntity project) async {
    try {
      state = CreateProjectLoading();
      final newProject = await _projectRepository.createProject(project);
      state = CreateProjectSuccess(newProject);
    } catch (e) {
      state = CreateProjectFailure(e.toString());
    }
  }
}

// 3. Creamos el Provider para nuestro nuevo Notifier.
final createProjectProvider =
    StateNotifierProvider<CreateProjectNotifier, CreateProjectState>((ref) {
      // Reutilizamos el repositorio que ya teníamos.
      final projectRepository = ref.watch(projectRepositoryProvider);
      return CreateProjectNotifier(projectRepository);
    });
