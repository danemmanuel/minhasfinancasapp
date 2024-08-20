import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:minhas_financas_digitais/pages/cadastrar_conta_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/BalanceTopPage.dart';
import '../helpers/filtrar_operacoes.dart';
import '../components/mes_ano_selector.dart';
import '../helpers/formatar_valor_monetario.dart';
import 'editar_conta_page.dart';
import 'login_page.dart';

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
  List<dynamic>? contas = [];

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
    _fetchOperacoes();
  }

  Future<void> _fetchSaldo() async {
    saldosPorInstituicao = {};
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
      setState(() {
        contas = json.decode(response.body);
      });

      for (var conta in contas!) {
        String instituicao = conta['instituicao'];
        double saldo = (conta['saldo'] as num).toDouble();

        if (saldosPorInstituicao.containsKey(instituicao)) {
          saldosPorInstituicao[instituicao] =
              (saldosPorInstituicao[instituicao] ?? 0.0) + saldo;
        } else {
          saldosPorInstituicao[instituicao] = saldo;
        }
      }
    } else if (response.statusCode == 401) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
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

  Future<void> _deletarConta(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      // Handle the case where authToken is null (e.g., user not authenticated)
      return;
    }

    final url = Uri.parse('https://financess-back.herokuapp.com/conta/' + id);

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Conta removida com sucesso!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin:
            EdgeInsets.only(bottom: 0.0), // Ajuste o valor para mover para cima
        duration: Duration(seconds: 2),
      ));
      _fetchSaldo();
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
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 3.8,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: contas?.length ?? 0,
                  itemBuilder: (context, index) {
                    var conta = contas![index];
                    return Dismissible(
                      key: Key(conta['id']
                          .toString()), // Use a unique key for each item
                      direction: DismissDirection
                          .endToStart, // Swipe from right to left
                      onDismissed: (direction) {
                        setState(() {
                          contas!
                              .removeAt(index); // Remove the item from the list
                        });
                        // Call a function to delete the item from the database or API
                        _deletarConta(conta['_id']);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditarContaPage(
                              conta: conta,
                              onSave: () {
                                _fetchSaldo();
                                _fetchOperacoes();
                              },
                            ),
                          ));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        'assets/images/${conta['instituicao'].toString().toLowerCase()}.png',
                                        width: 50,
                                        height: 50,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      conta['instituicao'],
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(height: 5),
                                    Text(
                                      'saldo de',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Text(
                                      formatarValorMonetario(
                                          (conta['saldo'] as num).toDouble()),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: 16.0, bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CadastrarContaPage(
                onSave: () {
                  _fetchSaldo();
                },
              ),
            ));
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
