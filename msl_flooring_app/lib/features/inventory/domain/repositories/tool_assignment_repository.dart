// lib/features/inventory/domain/repositories/tool_assignment_repository.dart

abstract class ToolAssignmentRepository {
  Future<void> createToolAssignment(Map<String, dynamic> assignmentData);

  Future<List<Map<String, dynamic>>> getAssignmentsByTool(String toolId);

  Future<List<Map<String, dynamic>>> getAssignmentsByWorker(String workerId);

  Future<List<Map<String, dynamic>>> getAssignmentsByProject(String projectId);
}
