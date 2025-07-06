// lib/features/projects/presentation/screens/create_project_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:msl_flooring_app/features/projects/domain/entities/project_request_entity.dart';

import '../providers/project_providers.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      final projectRequest = ProjectRequestEntity(
        name: _nameController.text,
        description: _descriptionController.text,
        budget: double.tryParse(_budgetController.text) ?? 0.0,
        startDate: _startDate!,
        endDate: _endDate!,
        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
      );

      ref.read(createProjectProvider.notifier).createProject(projectRequest);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa todos los campos, incluyendo las fechas.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado del provider de creación
    ref.listen<CreateProjectState>(createProjectProvider, (previous, next) {
      if (next is CreateProjectSuccess) {
        // Si tiene éxito, refrescamos la lista de proyectos y volvemos atrás
        ref.read(projectListProvider.notifier).fetchProjects();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Proyecto "${next.newProject.name}" creado con éxito.',
            ),
          ),
        );
      }
      if (next is CreateProjectFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.message}')));
      }
    });

    final createProjectState = ref.watch(createProjectProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Proyecto')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Proyecto',
                ),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Presupuesto'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitud'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitud'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),
              // --- Selectores de Fecha ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha de Inicio: ${_startDate == null ? 'No seleccionada' : DateFormat('yyyy-MM-dd').format(_startDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha de Fin: ${_endDate == null ? 'No seleccionada' : DateFormat('yyyy-MM-dd').format(_endDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: const Text('Seleccionar'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // --- Botón de Guardar ---
              ElevatedButton(
                onPressed: createProjectState is CreateProjectLoading
                    ? null
                    : _submitForm,
                child: createProjectState is CreateProjectLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Proyecto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
