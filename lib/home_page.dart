import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  List<dynamic>? receitas = [];
  List<dynamic>? despesas = [];

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
    _fetchOperacoes();
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

      setState(() {});
    } else {
      // Falha ao obter o saldo
      print('Falha ao obter o saldo. Código de status: ${response.statusCode}');
    }
  }

  Future<void> _fetchOperacoes() async {
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
        despesas = filterDespesas(json.decode(responseDespesa.body),
            _selectedDate.year, _selectedDate.month);
      });
    } else {
      print(
          'Falha ao obter as receitas. Código de status: ${responseDespesa.statusCode}');
    }
    if (responseReceita.statusCode == 200) {
      setState(() {
        receitas = filterDespesas(json.decode(responseReceita.body),
            _selectedDate.year, _selectedDate.month);
      });
    } else {
      print(
          'Falha ao obter as receitas. Código de status: ${responseReceita.statusCode}');
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              MesAnoSelector(
                selectedDate: _selectedDate,
                onPreviousMonth: () {
                  setState(() {
                    _selectedDate =
                        DateTime(_selectedDate.year, _selectedDate.month - 1);
                    _fetchOperacoes(); // Fetch operations for the new date
                  });
                },
                onNextMonth: () {
                  setState(() {
                    _selectedDate =
                        DateTime(_selectedDate.year, _selectedDate.month + 1);
                    _fetchOperacoes(); // Fetch operations for the new date
                  });
                },
              ),
              SizedBox(height: 30),
              Card(
                child: ListTile(
                  title: Text('Saldo Atual'),
                  subtitle:
                      Text('R\$ ${_calculateSaldoAtual().toStringAsFixed(2)}'),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: ListTile(
                  title: Text('Saldo Previsto'),
                  subtitle: Text(
                      'R\$ ${_calculateSaldoPrevisto().toStringAsFixed(2)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
