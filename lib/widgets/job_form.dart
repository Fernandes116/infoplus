import 'package:flutter/material.dart';
import '../models/job.dart';

class JobForm extends StatefulWidget {
  final String userId;
  final void Function(Job job) onSubmit;

  const JobForm({
    super.key, 
    required this.userId,
    required this.onSubmit,
  });

  @override
  State<JobForm> createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _provinceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Localização'),
              validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _provinceController,
              decoration: const InputDecoration(labelText: 'Província'),
              validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Categoria'),
              validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit(
                    Job(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: widget.userId,
                      title: _titleController.text,
                      location: _locationController.text,
                      province: _provinceController.text,
                      category: _categoryController.text,
                      description: _descriptionController.text,
                      createdAt: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar Vaga'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _provinceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
