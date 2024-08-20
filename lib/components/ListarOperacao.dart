import 'package:flutter/material.dart';

import '../pages/editar_operacao_page.dart';
import 'operacao_row.dart';

class ListarOperacao extends StatelessWidget {
  final dynamic filteredDespesas;
  final dynamic tipoOperacao;
  final dynamic onSave;
  final dynamic onDelete;
  final dynamic onEfetivar;
  final dynamic selectedDate;

  ListarOperacao(
      {required this.filteredDespesas,
      required this.tipoOperacao,
      required this.onSave,
      required this.onDelete,
      required this.onEfetivar,
      required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: filteredDespesas.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditarOperacaoPage(
                  tipoOperacao: tipoOperacao,
                  operacaoData: filteredDespesas[index],
                  onSave: () {
                    onSave();
                  },
                ),
              ));
            },
            child: OperacaoRow(
              despesa: filteredDespesas[index],
              onDelete: onDelete,
              onEfetivar: onEfetivar,
              selectedDate: selectedDate,
            ),
          );
        },
      ),
    );
  }
}
