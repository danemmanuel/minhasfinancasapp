import 'package:intl/intl.dart';

String formatarValorMonetario(dynamic valor) {
  if (valor == null) return 'R\$ 0,00';

  double valorDouble;
  if (valor is int) {
    valorDouble = valor.toDouble();
  } else if (valor is double) {
    valorDouble = valor;
  } else {
    throw ArgumentError('O valor deve ser do tipo int ou double');
  }

  final NumberFormat formatador = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  return formatador.format(valorDouble);
}
