import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildOperacaoRow(BuildContext context, dynamic despesa,
    Function onDelete, Function onEfetivar) {
  String formatarValorMonetario(dynamic valor) {
    // Verifica se o valor é null ou não.
    if (valor == null) return 'R\$ 0,00';

    // Converte o valor para double se for int
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

  String nome = despesa['descricao'] ?? '-';
  String contaDescricao =
      despesa['conta'] != null ? despesa['conta']['instituicao'] : '';
  String categoriaDescricao = despesa['categoria']['descricao'] != null
      ? despesa['categoria']['descricao']
      : '';

  String categoria = contaDescricao + ' | ' + (categoriaDescricao ?? '-');

  String fixa = despesa['fixa'] == true
      ? 'Fixa'
      : DateFormat('dd/MM/yyyy').format(DateTime.parse(despesa['data']));
  String valor = despesa['valor'] != null
      ? formatarValorMonetario(despesa['valor'])
      : 'R\$ 0,00';
  bool efetivado = despesa['efetivado'] ?? false;

  IconData iconData = efetivado
      ? Icons.check_circle
      : Icons.cancel; // Icon based on payment status

  return Dismissible(
    key: Key(despesa['id'].toString()), // Use a unique key for each item
    direction: DismissDirection.horizontal,
    confirmDismiss: (direction) async {
      if (direction == DismissDirection.endToStart) {
        onDelete(despesa);
        return true;
      } else if (direction == DismissDirection.startToEnd) {
        onEfetivar(despesa);
        return false;
      }
      return false;
    },
    onDismissed: (direction) {
      print(direction);
      if (direction == DismissDirection.endToStart) {
        onDelete(despesa);
      } else if (direction == DismissDirection.startToEnd) {
        onEfetivar(despesa);
      }
    },
    secondaryBackground: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: 30),
        child: Icon(Icons.delete, color: Colors.white),
      ),
    ),
    background: Container(
      color: Colors.green,
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 30),
        child: Icon(Icons.check_circle, color: Colors.white),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 0, horizontal: 10.0), // Define o espaçamento interno
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF191919), width: 1.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.end, // Alinha os elementos à direita
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5), // Espaçamento entre os itens
                    Text(categoria, style: TextStyle(fontSize: 10)),
                    SizedBox(height: 5), // Espaçamento entre os itens
                    Text(fixa, style: TextStyle(fontSize: 10)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      valor,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5), // Espaçamento entre os itens
                    Icon(iconData,
                        color:
                            efetivado ? Colors.greenAccent : Colors.redAccent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
