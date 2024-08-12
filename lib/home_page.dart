import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, double> saldosPorInstituicao = {};

  @override
  void initState() {
    super.initState();
    _fetchSaldo();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text('Home Page'),
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Saldos por Instituição:',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.left,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: saldosPorInstituicao.length,
                itemBuilder: (context, index) {
                  String instituicao =
                      saldosPorInstituicao.keys.elementAt(index);
                  double saldo = saldosPorInstituicao[instituicao] ?? 0.0;
                  return ListTile(
                    title: Text(instituicao),
                    subtitle: Text('Saldo: R\$ ${saldo.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
