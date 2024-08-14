import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/filtrar_operacoes.dart';
import 'mes_ano_selector.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, double> saldosPorInstituicao = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<dynamic>? receitas = [];
  List<dynamic>? receitasAll = [];
  List<dynamic>? despesas = [];
  List<dynamic>? despesasAll = [];

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
    _fetchOperacoes();
  }

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

  Future<void> _fetchSaldo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString('authToken') ?? '';

    final url = Uri.parse('https://financess-back.herokuapp.com/conta');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> contas = json.decode(response.body);

      for (var conta in contas) {
        String instituicao = conta['instituicao'];
        double saldo = (conta['saldo'] as num).toDouble();

        if (saldosPorInstituicao.containsKey(instituicao)) {
          saldosPorInstituicao[instituicao] =
              (saldosPorInstituicao[instituicao] ?? 0.0) + saldo;
        } else {
          saldosPorInstituicao[instituicao] = saldo;
        }
      }
    } else {
      // Falha ao obter o saldo
      print('Falha ao obter o saldo. Código de status: ${response.statusCode}');
    }
  }

  Future<void> calcularOperacoes() async {
    setState(() {
      despesas =
          filterDespesas(despesasAll, _selectedDate.year, _selectedDate.month);

      receitas =
          filterDespesas(receitasAll, _selectedDate.year, _selectedDate.month);
    });
  }

  Future<void> _fetchOperacoes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('authToken');

      if (authToken == null) {
        // Handle the case where authToken is null (e.g., user not authenticated)
        return;
      }

      final urlDespesa =
          Uri.parse('https://financess-back.herokuapp.com/despesa');
      final urlReceita =
          Uri.parse('https://financess-back.herokuapp.com/receita');

      final responseDespesa = await http.get(
        urlDespesa,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      final responseReceita = await http.get(
        urlReceita,
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (responseDespesa.statusCode == 200) {
        setState(() {
          despesasAll = json.decode(responseDespesa.body);
        });
      } else {
        print(
            'Falha ao obter as receitas. Código de status: ${responseDespesa.statusCode}');
      }
      if (responseReceita.statusCode == 200) {
        setState(() {
          receitasAll = json.decode(responseReceita.body);
        });
      } else {
        print(
            'Falha ao obter as receitas. Código de status: ${responseReceita.statusCode}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _calculateSaldoAtual() {
    return saldosPorInstituicao.values.fold(0.0, (sum, value) => sum + value);
  }

  double _calculateSaldoPrevisto() {
    double saldoAtual = _calculateSaldoAtual();

    // Sum only receitas where efetivado is false
    double totalReceitas = receitas
            ?.where((item) =>
                item['efetivado'] == false || item['efetivado'] == null)
            .fold(
              0.0,
              (sum, item) => sum! + (item['valor'] as num).toDouble(),
            ) ??
        0.0;

    // Sum only despesas where efetivado is false
    double totalDespesas = despesas
            ?.where((item) =>
                item['efetivado'] == false || item['efetivado'] == null)
            .fold(
              0.0,
              (sum, item) => sum! + (item['valor'] as num).toDouble(),
            ) ??
        0.0;

    return saldoAtual + totalReceitas - totalDespesas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              SizedBox(height: 50),
              MesAnoSelector(
                selectedDate: _selectedDate,
                onPreviousMonth: () {
                  setState(() {
                    _selectedDate =
                        DateTime(_selectedDate.year, _selectedDate.month - 1);
                    calcularOperacoes();
                  });
                },
                onNextMonth: () {
                  setState(() {
                    _selectedDate =
                        DateTime(_selectedDate.year, _selectedDate.month + 1);
                    calcularOperacoes();
                  });
                },
              ),
              Text('SALDOS'),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(
                              10.0), // Keep the right side rounded
                          bottomRight: Radius.circular(10.0),
                          topLeft: Radius.circular(
                              0.0), // No rounding on the left side
                          bottomLeft: Radius.circular(0.0),
                        ),
                      ),
                      color: Colors.green,
                      child: ListTile(
                        leading: Icon(
                          Icons.attach_money,
                          size: 20,
                          color: Colors.white,
                        ),
                        title: _isLoading
                            ? Container(
                                width: 100,
                                height: 15,
                                color: Colors.white.withOpacity(0.5),
                              )
                            : Container(
                                child: Text(
                                  'Atual',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                        subtitle: _isLoading
                            ? Container(
                                margin: EdgeInsets.only(top: 10),
                                width: 100,
                                height: 15,
                                color: Colors.white.withOpacity(0.5),
                              )
                            : Container(
                                child: Text(
                                  formatarValorMonetario(
                                      _calculateSaldoAtual()),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(width: 0),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight:
                              Radius.circular(0), // Keep the right side rounded
                          bottomRight: Radius.circular(0),
                          topLeft: Radius.circular(
                              10.0), // No rounding on the left side
                          bottomLeft: Radius.circular(10.0),
                        ),
                      ),
                      color: Colors.blue,
                      child: ListTile(
                        leading: Icon(
                          Icons.account_balance,
                          size: 20,
                          color: Colors.white,
                        ),
                        title: _isLoading
                            ? Container(
                                width: 100,
                                height: 15,
                                color: Colors.white.withOpacity(0.5),
                              )
                            : Container(
                                child: Text(
                                  'Previsto',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                        subtitle: _isLoading
                            ? Container(
                                margin: EdgeInsets.only(top: 10),
                                width: 100,
                                height: 15,
                                color: Colors.white.withOpacity(0.5),
                              )
                            : Container(
                                child: Text(
                                  formatarValorMonetario(
                                      _calculateSaldoPrevisto()),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
