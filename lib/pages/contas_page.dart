import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minhas_financas_digitais/pages/cadastrar_conta_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/BalanceTopPage.dart';
import '../components/FloatingButton.dart';
import '../components/ListarContas.dart';
import '../helpers/filtrar_operacoes.dart';
import '../components/mes_ano_selector.dart';
import '../helpers/formatar_valor_monetario.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  List<dynamic>? contas = [];

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
    _fetchOperacoes();
  }

  Future<void> _fetchSaldo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('authToken') ?? '';

      final url = Uri.parse('https://financess-back.herokuapp.com/conta');
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200) {
        setState(() {
          contas = json.decode(response.body);
          saldosPorInstituicao = _calcularSaldosPorInstituicao(contas!);
        });
      } else if (response.statusCode == 401) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        print(
            'Falha ao obter o saldo. Código de status: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar saldo: $e');
    }
  }

  Map<String, double> _calcularSaldosPorInstituicao(List<dynamic> contas) {
    Map<String, double> saldos = {};
    for (var conta in contas) {
      String instituicao = conta['instituicao'];
      double saldo = (conta['saldo'] as num).toDouble();
      saldos[instituicao] = (saldos[instituicao] ?? 0.0) + saldo;
    }
    return saldos;
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
      if (authToken == null) return;

      final responseDespesa = await _fetchData(
          'https://financess-back.herokuapp.com/despesa', authToken);
      final responseReceita = await _fetchData(
          'https://financess-back.herokuapp.com/receita', authToken);

      if (responseDespesa != null) {
        setState(() {
          despesasAll = responseDespesa;
        });
      }
      if (responseReceita != null) {
        setState(() {
          receitasAll = responseReceita;
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>?> _fetchData(String url, String authToken) async {
    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $authToken'});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Falha ao obter dados. Código de status: ${response.statusCode}');
      return null;
    }
  }

  double _calculateSaldoAtual() {
    return saldosPorInstituicao.values.fold(0.0, (sum, value) => sum + value);
  }

  double _calculateSaldoPrevisto() {
    double saldoAtual = _calculateSaldoAtual();
    double totalReceitas = _calcularTotal(receitas, false);
    double totalDespesas = _calcularTotal(despesas, false);
    return saldoAtual + totalReceitas - totalDespesas;
  }

  double _calcularTotal(List<dynamic>? operacoes, bool efetivado) {
    return operacoes?.where((item) => item['efetivado'] == efetivado).fold(
            0.0, (sum, item) => sum! + (item['valor'] as num).toDouble()) ??
        0.0;
  }

  Future<void> _deletarConta(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('authToken');
      if (authToken == null) return;

      final url = Uri.parse('https://financess-back.herokuapp.com/conta/$id');
      final response = await http
          .delete(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Conta removida com sucesso!',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 0.0),
          duration: Duration(seconds: 2),
        ));
        _fetchSaldo();
      }
    } catch (e) {
      print('Erro ao deletar conta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
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
              BalanceTopPage(
                isLoading: _isLoading,
                item1: BalanceItem(
                  titulo: 'Saldo Atual',
                  valor: formatarValorMonetario(_calculateSaldoAtual()),
                  background: Colors.green,
                ),
                item2: BalanceItem(
                  titulo: 'Previsto',
                  valor: formatarValorMonetario(_calculateSaldoPrevisto()),
                  background: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              ListarContas(
                contas: contas,
                onDismissed: (conta, index) {
                  setState(() {
                    contas!.removeAt(index); // Remove the item from the list
                  });
                  // Call a function to delete the item from the database or API
                  _deletarConta(conta['_id']);
                },
                onSave: () {
                  _fetchSaldo();
                  _fetchOperacoes();
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingButton(
          builder: CadastrarContaPage(
            onSave: () {
              _fetchSaldo();
            },
          ),
          backgroundColor: Colors.blue),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
