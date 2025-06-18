import 'package:flutter/material.dart';
import '../../models/reward.dart';

class RewardForm extends StatefulWidget {
  final void Function(Reward reward) onSave;
  final Reward? existing;
  final String icon;
  final String name;
  final int pointsRequired;
  final double value;  // Alterado de String para double

  const RewardForm({
    Key? key,
    required this.onSave,
    this.existing,
    required this.icon,
    required this.name,
    required this.pointsRequired,
    required this.value,
  }) : super(key: key);

  @override
  State<RewardForm> createState() => _RewardFormState();
}

class _RewardFormState extends State<RewardForm> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late int _points;
  late String _type;
  late String _description;
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _title = widget.existing?.title ?? '';
    _points = widget.existing?.points ?? 0;
    _type = widget.existing?.type ?? 'sms';
    _description = widget.existing?.description ?? '';
    _imageUrl = widget.existing?.imageUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
              onSaved: (value) => _title = value!,
            ),
            TextFormField(
              initialValue: _points.toString(),
              decoration: const InputDecoration(labelText: 'Pontos necessários'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || int.tryParse(value) == null ? 'Número inválido' : null,
              onSaved: (value) => _points = int.parse(value!),
            ),
            TextFormField(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
              onSaved: (value) => _type = value!,
            ),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
              onSaved: (value) => _description = value!,
            ),
            TextFormField(
              initialValue: _imageUrl,
              decoration: const InputDecoration(labelText: 'URL da Imagem'),
              validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
              onSaved: (value) => _imageUrl = value!,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState!.save();
                  final reward = Reward(
                    id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _title,
                    points: _points,
                    type: _type,
                    description: _description,
                    imageUrl: _imageUrl,
                    icon: widget.icon,
                    name: widget.name,
                    pointsRequired: widget.pointsRequired,
                    value: widget.value,
                  );
                  widget.onSave(reward);
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
