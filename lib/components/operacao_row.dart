import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers/formatar_valor_monetario.dart';

class OperacaoRow extends StatefulWidget {
  final dynamic despesa;
  final Function onDelete;
  final Function onEfetivar;
  final dynamic selectedDate;

  OperacaoRow(
      {required this.despesa,
      required this.onDelete,
      required this.onEfetivar,
      required this.selectedDate});

  @override
  _OperacaoRowState createState() => _OperacaoRowState();
}

class _OperacaoRowState extends State<OperacaoRow> {
  Color _backgroundColor = Colors.transparent; // Cor de fundo inicial

  void _piscarRow() async {
    // Adiciona um delay antes de começar a piscar
    await Future.delayed(Duration(milliseconds: 500));

    // Alterna as cores 1 vez
    for (int i = 0; i < 1; i++) {
      setState(() {
        _backgroundColor = Colors.greenAccent.withOpacity(0.3); // Cor clara
      });
      await Future.delayed(Duration(milliseconds: 200));
      setState(() {
        _backgroundColor = Colors.transparent; // Cor original
      });
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic selectedDate = widget.selectedDate;
    String nome = widget.despesa['descricao'] ?? '-';
    String contaDescricao = widget.despesa['conta'] != null
        ? widget.despesa['conta']['instituicao']
        : '';
    String categoriaDescricao = widget.despesa['categoria']['descricao'] != null
        ? widget.despesa['categoria']['descricao']
        : '';

    String categoria = contaDescricao + ' | ' + (categoriaDescricao ?? '-');

    String fixa() {
      final DateTime data = DateTime.parse(widget.despesa['data']);
      final int repetirPorValue = widget.despesa['repetirPor'] ?? 0;
      final DateTime dataInicial = DateTime(data.year, data.month);
      final DateTime dataAtual =
          DateTime(selectedDate.year, selectedDate.month);

      if (widget.despesa['fixa'] == true) {
        if (repetirPorValue > 0) {
          // Calcula o número total de meses para a repetição
          final int totalMeses = repetirPorValue;

          // Calcula o número de meses passados desde a data inicial
          final int mesesPassados = ((dataAtual.year - dataInicial.year) * 12) +
              dataAtual.month -
              dataInicial.month +
              1;

          return '$mesesPassados de $totalMeses meses';
        } else {
          return 'Fixa';
        }
      } else {
        // Exibe a data formatada se não for uma despesa fixa
        return DateFormat('dd MMM yyyy', 'pt_BR').format(data);
      }
    }

    String valor = widget.despesa['valor'] != null
        ? formatarValorMonetario(widget.despesa['valor'])
        : 'R\$ 0,00';
    bool efetivado = widget.despesa['efetivado'] ?? false;

    IconData iconData = efetivado ? Icons.check_circle : Icons.cancel;

    return Dismissible(
      key: Key(widget.despesa['id'].toString()),
      // Bloqueia a direção de deslize da esquerda para a direita se já estiver efetivado
      direction:
          efetivado ? DismissDirection.endToStart : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          widget.onDelete(widget.despesa);
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          widget.onEfetivar(widget.despesa);
          _piscarRow(); // Chama o efeito de piscar após efetivar
          return false;
        }
        return false;
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
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          color: _backgroundColor, // Cor de fundo animada
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
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                        SizedBox(height: 5),
                        Text(categoria, style: TextStyle(fontSize: 10)),
                        SizedBox(height: 5),
                        Text(fixa(), style: TextStyle(fontSize: 10)),
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
                        SizedBox(height: 5),
                        Icon(iconData,
                            color: efetivado
                                ? Colors.greenAccent
                                : Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
