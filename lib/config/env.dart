class Env {
  // Configurações de API
  static const String apiBaseUrl = 'https://api.infoplus.com';

  // Configurações de pagamento
  static const mpesaUssdCode = '*848*{amount}*{phone}#';
  static const emolaUssdCode = '*847*{amount}*{phone}#';
  static const mpesaMerchantCode = '123456';
  static const emolaMerchantCode = '654321';
  static const emolaServiceCode = '987654';

  // Tempos em segundos
  static const paymentTimeout = 30;  // Tempo para iniciar pagamento
  static const smsWaitTimeout = 45;  // Tempo para receber confirmação

  // Valores padrão
  static const defaultJobPrice = 4.0;    // Preço para consulta de vagas
  static const defaultPricePrice = 2.0;  // Preço para consulta de preços
  static const defaultImovelPrice = 3.0; // Preço para consulta de imóveis

  // Pontos por consulta
  static const jobPoints = 5;
  static const pricePoints = 2;
  static const imovelPoints = 3;

  // Configurações de SMS
  static const mpesaSmsKeywords = ['pagamento', 'pago', 'transferência'];
  static const emolaSmsKeywords = ['pagamento', 'pago', 'debido'];

  // Regex para extrair dados do SMS
  static final mpesaAmountRegex = RegExp(r'(\d+\.?\d*) MT');
  static final emolaAmountRegex = RegExp(r'Valor: (\d+\.?\d*) MT');

  // Caminhos de destino
  static const jobsRoute = '/jobs';
  static const pricesRoute = '/prices';
  static const imoveisRoute = '/imoveis';

  // Método para carregar configurações
  static Future<void> load() async {
    // Implementação para carregar configurações dinâmicas
    // Pode ser de um arquivo .env ou de um serviço remoto
  }
}
