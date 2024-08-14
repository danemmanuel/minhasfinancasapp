import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:minhas_financas_digitais/pages/editar_operacao.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/BalanceTopPage.dart';
import '../helpers/formatar_valor_monetario.dart';
import 'cadastrar_operacao.dart';
import '../components/SkeletonLoader.dart';
import '../helpers/filtrar_operacoes.dart';
import '../components/operacao_row.dart';
import '../components/mes_ano_selector.dart';

class DespesasPage extends StatefulWidget {
  final String tipoOperacao;
  final Key? key;

  DespesasPage({required this.tipoOperacao, this.key});

  @override
  _DespesasPageState createState() => _DespesasPageState();
}

class _DespesasPageState extends State<DespesasPage> {
  late String tipoOperacao;

  List<dynamic> receitas = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    tipoOperacao = widget.tipoOperacao;
    super.initState();
    _fetchReceitas();
  }

  Future<void> _fetchReceitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      // Handle the case where authToken is null (e.g., user not authenticated)
      return;
    }

    final url = tipoOperacao == 'despesa'
        ? Uri.parse('https://financess-back.herokuapp.com/despesa')
        : Uri.parse('https://financess-back.herokuapp.com/receita');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        receitas = json.decode(response.body);
      });
    } else {
      print(
          'Falha ao obter as receitas. Código de status: ${response.statusCode}');
    }
  }

  Future<void> _deletarOperacao(operacao) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      // Handle the case where authToken is null (e.g., user not authenticated)
      return;
    }

    final url = tipoOperacao == 'despesa'
        ? Uri.parse(
            'https://financess-back.herokuapp.com/despesa/' + operacao['_id'])
        : Uri.parse(
            'https://financess-back.herokuapp.com/receita/' + operacao['_id']);

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          tipoOperacao == 'receita'
              ? "Receita removida com sucesso!"
              : 'Despesa removida com sucesso!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin:
            EdgeInsets.only(bottom: 0.0), // Ajuste o valor para mover para cima
        duration: Duration(seconds: 2),
      ));
      _fetchReceitas();
    }
  }

  Future<void> _efetivarOperacao(operacao) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      return;
    }

    setState(() {
      operacao['efetivado'] = true;
    });

    final url = tipoOperacao == 'despesa'
        ? Uri.parse('https://financess-back.herokuapp.com/despesa')
        : Uri.parse('https://financess-back.herokuapp.com/receita');

    Map<String, dynamic> requestBody = {
      "_id": operacao['_id'],
      "descricao": operacao['descricao'],
      "efetivado": true,
      "valor": operacao['valor'],
      "repetirPor": 0,
      "fixa": operacao['fixa'],
      "data": operacao['fixa'] == true
          ? DateFormat('yyyy-MM-dd')
              .format(DateTime(_selectedDate.year, _selectedDate.month, 1))
          : operacao['data'] != null
              ? operacao['data']
              : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "excluirData": operacao['fixa']
          ? [
              ...(operacao['excluirData'] != null
                  ? List<String>.from(operacao['excluirData'])
                  : []),
              DateFormat('yyyy-MM-dd').format(_selectedDate),
            ]
          : [],
      "categoria": operacao['categoria'],
      "conta": operacao['conta']
    };

    print(json.encode(requestBody));
    final response = await http.put(url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tipoOperacao == 'receita'
                ? "Receita efetivada com sucesso!"
                : 'Despesa efetivada com sucesso!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 0.0),
          duration: Duration(seconds: 2),
        ),
      );
      _fetchReceitas();
    }
  }

  void updateReceitas() {
    _fetchReceitas();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = receitas.isEmpty;

    List<dynamic>? filteredDespesas =
        filterDespesas(receitas, _selectedDate.year, _selectedDate.month);

    double _calcularPendente() {
      return filteredDespesas!
          .where((operacao) =>
              operacao['efetivado'] == false || operacao['efetivado'] == null)
          .fold(0, (total, operacao) => total + operacao['valor']);
    }

    double _calcularTotal() {
      return filteredDespesas!
          .fold(0, (total, operacao) => total + operacao['valor']);
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10), // Define o padding desejado
          child: Column(
            children: [
              SizedBox(height: 50), // Espaçamento entre os itens
              MesAnoSelector(
                selectedDate: _selectedDate,
                onPreviousMonth: () {
                  setState(() {
                    _selectedDate =
                        DateTime(_selectedDate.year, _selectedDate.month - 1);
                    _calcularPendente();
                  });
                },
                onNextMonth: () {
                  setState(() {
                    _selectedDate =
                        DateTime(_selectedDate.year, _selectedDate.month + 1);
                    _calcularPendente();
                  });
                },
              ),
              BalanceTopPage(
                isLoading: isLoading,
                item1: BalanceItem(
                    titulo: 'Pendente',
                    valor: formatarValorMonetario(_calcularPendente()),
                    background:
                        tipoOperacao == 'receita' ? Colors.green : Colors.red),
                item2: BalanceItem(
                    titulo: 'Total',
                    valor: formatarValorMonetario(_calcularTotal()),
                    background: Colors.blue),
              ),
              // Text(tipoOperacao == 'receita' ? 'RECEITAS' : 'DESPESAS',
              //     style: TextStyle(
              //         color: tipoOperacao == 'receita'
              //             ? Colors.greenAccent
              //             : Colors.redAccent)),

              // Exibe o SkeletonLoader enquanto os dados estão carregando
              if (isLoading)
                Expanded(child: SkeletonLoader())
              else if (filteredDespesas != null && filteredDespesas.isNotEmpty)
                Expanded(
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
                                _fetchReceitas();
                                // Função para chamar após salvar
                              },
                            ),
                          ));

                          // Open the gerenciarOperacao modal with the expense data
                        },
                        child: OperacaoRow(
                          despesa: filteredDespesas[index],
                          onDelete: _deletarOperacao,
                          onEfetivar: _efetivarOperacao,
                          selectedDate: _selectedDate,
                        ),
                      );
                    },
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Text(
                      'Nenhuma ${tipoOperacao == 'receita' ? 'receita' : 'despesa'} encontrada.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            right: 16.0, bottom: 16.0), // Ajuste o espaçamento desejado
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CadastrarOperacaoPage(
                tipoOperacao: tipoOperacao,
                onSave: () {
                  _fetchReceitas();
                  // Função para chamar após salvar
                },
              ),
            ));
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor:
              tipoOperacao == 'receita' ? Colors.green : Colors.red,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
