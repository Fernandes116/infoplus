import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;

  const ErrorView({
    Key? key,
    required this.error,
    this.stackTrace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Ocorreu um erro inesperado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              error.toString(),
              style: const TextStyle(fontSize: 16),
            ),
            if (stackTrace != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Detalhes técnicos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(stackTrace.toString()),
            ],
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                child: const Text('Voltar ao início'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
