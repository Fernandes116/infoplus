import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/consulta_historico_provider.dart';
import '../providers/points_provider.dart';
import '../providers/job_provider.dart';
import '../providers/price_provider.dart';
import '../providers/imovel_provider.dart';
import '../models/consulta_historico.dart';
import '../services/payment_service.dart';

class PaymentView extends StatefulWidget {
  final Map<String, dynamic> dados;
  final String selectedProvince;

  const PaymentView({
    Key? key,
    required this.dados,
    required this.selectedProvince,
  }) : super(key: key);

  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  bool _processing = false;
  String? _errorMessage;
  DateTime? _paymentStartTime;
  StreamSubscription<Map<String, dynamic>>? _smsSubscription;

  @override
  void initState() {
    super.initState();
    _setupPaymentListener();
    _startPaymentProcess();
  }

  void _setupPaymentListener() {
    _smsSubscription = PaymentService.paymentStream.listen((paymentData) {
      if (mounted) {
        _onPaymentSuccess(paymentData);
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro: ${error.toString()}';
          _processing = false;
        });
      }
    });
  }

  Future<void> _startPaymentProcess() async {
    await _mostrarDialogoConfirmacao();
  }

  Future<void> _mostrarDialogoConfirmacao() async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Pagamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Deseja pagar ${widget.dados['valor']} MZN por "${widget.dados['tipo']}"?'),
            const SizedBox(height: 10),
            Text(
              'Você receberá ${widget.dados['pontos']} pontos',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmado != true && mounted) {
      Navigator.pop(context);
    } else if (confirmado == true) {
      _processarPagamento();
    }
  }

  Future<void> _processarPagamento() async {
    if (!mounted) return;

    setState(() {
      _processing = true;
      _errorMessage = null;
      _paymentStartTime = DateTime.now();
    });

    try {
      final auth = context.read<AuthProvider>();
      final payment = context.read<PaymentProvider>();
      final phone = auth.firebaseUser?.phoneNumber ?? '';

      final result = await payment.pay(
        widget.dados['valor'].toDouble(),
        phone
      ).timeout(const Duration(seconds: 45));

      if (!mounted) return;

      if (result != true) {
        throw Exception('Falha no processamento do pagamento');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processing = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no pagamento: ${_errorMessage}')),
        );
      }
    }
  }

  Future<void> _onPaymentSuccess(Map<String, dynamic> paymentData) async {
    if (!mounted || !_processing) return;

    try {
      final auth = context.read<AuthProvider>();
      final historicoProvider = context.read<ConsultaHistoricoProvider>();
      final pointsProvider = context.read<PointsProvider>();
      final jobProvider = context.read<JobProvider>();
      final priceProvider = context.read<PriceProvider>();
      final imovelProvider = context.read<ImovelProvider>();
      final userId = auth.firebaseUser!.uid;

      switch (widget.dados['tipo']) {
        case 'vagas':
          await jobProvider.fetchJobs(widget.selectedProvince);
          break;
        case 'preços':
          await priceProvider.fetchPrices(widget.selectedProvince);
          break;
        case 'imóveis':
          await imovelProvider.fetchImoveis(widget.selectedProvince);
          break;
      }

      final detalhes = _getDetalhesConsulta();

      final historico = ConsultaHistorico(
        id: paymentData['transactionId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        tipo: widget.dados['tipo'],
        timestamp: DateTime.now(),
        dados: {
          'valor': widget.dados['valor'],
          'pontos': widget.dados['pontos'],
          'transactionId': paymentData['transactionId'],
          'provincia': widget.selectedProvince,
          'operadora': paymentData['operator'],
          'tempoProcessamento': DateTime.now().difference(_paymentStartTime!).inSeconds,
        },
        detalhes: detalhes,
      );

      await Future.wait([
        historicoProvider.salvar(historico),
        pointsProvider.addPoints(userId, widget.dados['pontos'], widget.dados['tipo']),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pagamento confirmado! +${widget.dados['pontos']} pontos')),
        );
        Navigator.pushReplacementNamed(context, widget.dados['destino']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar pagamento: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  List<Map<String, dynamic>> _getDetalhesConsulta() {
    final jobProvider = context.read<JobProvider>();
    final priceProvider = context.read<PriceProvider>();
    final imovelProvider = context.read<ImovelProvider>();

    switch (widget.dados['tipo']) {
      case 'vagas':
        return jobProvider.jobsByProvince(widget.selectedProvince).map((job) => {
          'title': job.title,
          'location': job.location,
          'id': job.id,
        }).toList();
      case 'preços':
        return priceProvider.pricesByProvince(widget.selectedProvince).map((price) => {
          'item': price.item,
          'value': price.value,
          'province': price.province,
        }).toList();
      case 'imóveis':
        return imovelProvider.imoveisByProvincia(widget.selectedProvince).map((imovel) => {
          'titulo': imovel.titulo,
          'tipo': imovel.tipo,
          'preco': imovel.preco,
          'localizacao': imovel.localizacao,
        }).toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processando Pagamento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_processing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Processando pagamento de ${widget.dados['valor']} MZN',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                const Text('Por favor, confirme no popup do seu mobile money'),
                const SizedBox(height: 20),
                const LinearProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Tempo decorrido: ${DateTime.now().difference(_paymentStartTime ?? DateTime.now()).inSeconds}s',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_errorMessage != null) ...[
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 50,
                ),
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _mostrarDialogoConfirmacao,
                  child: const Text('Tentar Novamente'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _smsSubscription?.cancel();
    super.dispose();
  }
}
