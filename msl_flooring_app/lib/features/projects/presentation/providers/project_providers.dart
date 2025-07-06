// lib/features/projects/presentation/providers/project_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msl_flooring_app/features/auth/presentation/providers/auth_providers.dart';

import '../../../../core/providers/session_provider.dart';
import '../../../worker/domain/entities/worker_entity.dart';
import '../../../worker/domain/repositories/worker_repository.dart';
import '../../../worker/presentation/providers/worker_providers.dart';
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
class ProjectListNotifier extends StateNotifier<ProjectListState> {
  final ProjectRepository _projectRepository;
  final Ref _ref;

  ProjectListNotifier(this._projectRepository, this._ref)
    : super(ProjectListInitial());

  Future<void> fetchProjects() async {
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

final createProjectProvider =
    StateNotifierProvider<CreateProjectNotifier, CreateProjectState>((ref) {
      final projectRepository = ref.watch(projectRepositoryProvider);
      return CreateProjectNotifier(projectRepository);
    });

// --- Providers y Lógica para los Detalles de un Proyecto ---

abstract class ProjectDetailsState {}

class ProjectDetailsInitial extends ProjectDetailsState {}

class ProjectDetailsLoading extends ProjectDetailsState {}

class ProjectDetailsSuccess extends ProjectDetailsState {
  final ProjectEntity project;

  ProjectDetailsSuccess(this.project);
}

class ProjectDetailsFailure extends ProjectDetailsState {
  final String message;

  ProjectDetailsFailure(this.message);
}

class ProjectDetailsNotifier extends StateNotifier<ProjectDetailsState> {
  final ProjectRepository _projectRepository;

  ProjectDetailsNotifier(this._projectRepository)
    : super(ProjectDetailsInitial());

  Future<void> fetchProjectDetails(String projectId) async {
    try {
      state = ProjectDetailsLoading();
      final project = await _projectRepository.getProjectById(projectId);
      state = ProjectDetailsSuccess(project);
    } catch (e) {
      state = ProjectDetailsFailure(e.toString());
    }
  }
}

final projectDetailsProvider =
    StateNotifierProvider.family<
      ProjectDetailsNotifier,
      ProjectDetailsState,
      String
    >((ref, projectId) {
      final projectRepository = ref.watch(projectRepositoryProvider);
      final notifier = ProjectDetailsNotifier(projectRepository);
      // 👇 AÑADE ESTO - fetch automáticamente cuando se crea
      notifier.fetchProjectDetails(projectId);
      return notifier;
    });

// --- Providers y Lógica para los Trabajadores Asignados a un Proyecto ---

abstract class AssignedWorkersState {}

class AssignedWorkersInitial extends AssignedWorkersState {}

class AssignedWorkersLoading extends AssignedWorkersState {}

class AssignedWorkersSuccess extends AssignedWorkersState {
  final List<WorkerEntity> workers;

  // --- CORRECCIÓN AQUÍ ---
  // Ahora el constructor espera un parámetro nombrado y requerido.
  AssignedWorkersSuccess({required this.workers});
}

class AssignedWorkersFailure extends AssignedWorkersState {
  final String message;

  AssignedWorkersFailure(this.message);
}

class AssignedWorkersNotifier extends StateNotifier<AssignedWorkersState> {
  final ProjectRepository _projectRepository;
  final WorkerRepository _workerRepository;

  AssignedWorkersNotifier(this._projectRepository, this._workerRepository)
    : super(AssignedWorkersInitial());

  // En el AssignedWorkersNotifier, busca el método fetchAssignedWorkers y añade logs:

  Future<void> fetchAssignedWorkers(String projectId) async {
    print('🔍 [AssignedWorkers] Fetching workers for project: $projectId');
    try {
      state = AssignedWorkersLoading();
      print('🔍 [AssignedWorkers] State set to Loading');

      final workerIds = await _projectRepository.getWorkerIdsByProject(
        projectId,
      );
      print('🔍 [AssignedWorkers] Got worker IDs: $workerIds');

      if (workerIds.isEmpty) {
        print('🔍 [AssignedWorkers] No workers found, setting empty list');
        state = AssignedWorkersSuccess(workers: []);
        return;
      }

      final workers = await _workerRepository.getWorkersByIds(workerIds);
      print('🔍 [AssignedWorkers] Got ${workers.length} workers');
      state = AssignedWorkersSuccess(workers: workers);
    } catch (e) {
      print('🔴 [AssignedWorkers] Error: $e');
      state = AssignedWorkersFailure(e.toString());
    }
  }
}

final assignedWorkersProvider = StateNotifierProvider.autoDispose
    .family<AssignedWorkersNotifier, AssignedWorkersState, String>((
      ref,
      projectId,
    ) {
      final projectRepository = ref.watch(projectRepositoryProvider);
      final workerRepository = ref.watch(workerRepositoryProvider);
      return AssignedWorkersNotifier(projectRepository, workerRepository);
    });
// --- Providers y Lógica para la ASIGNACIÓN de un Trabajador ---

// 1. Definimos los estados para el proceso de asignación.
abstract class AssignWorkerState {}

class AssignWorkerInitial extends AssignWorkerState {}

class AssignWorkerLoading extends AssignWorkerState {}

class AssignWorkerSuccess extends AssignWorkerState {}

class AssignWorkerFailure extends AssignWorkerState {
  final String message;

  AssignWorkerFailure(this.message);
}

// 2. Creamos el Notifier que manejará la lógica de la acción.
class AssignWorkerNotifier extends StateNotifier<AssignWorkerState> {
  final ProjectRepository _projectRepository;

  AssignWorkerNotifier(this._projectRepository) : super(AssignWorkerInitial());

  Future<void> assignWorker({
    required String projectId,
    required String workerId,
  }) async {
    try {
      state = AssignWorkerLoading();
      await _projectRepository.assignWorkerToProject(
        projectId: projectId,
        workerId: workerId,
      );
      state = AssignWorkerSuccess();
    } catch (e) {
      state = AssignWorkerFailure(e.toString());
    }
  }

  // Método para resetear el estado a su valor inicial
  void resetState() {
    state = AssignWorkerInitial();
  }
}

// 3. Creamos el Provider para nuestro nuevo Notifier.
final assignWorkerProvider =
    StateNotifierProvider<AssignWorkerNotifier, AssignWorkerState>((ref) {
      // Reutilizamos el repositorio que ya teníamos.
      final projectRepository = ref.watch(projectRepositoryProvider);
      return AssignWorkerNotifier(projectRepository);
    });
