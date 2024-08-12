import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class AdicionarOperacao extends StatefulWidget {
  final String tipoOperacao;
  final Function()
      onSave; // Defina o parâmetro onSave como uma função sem argumentos

  AdicionarOperacao({required this.tipoOperacao, required this.onSave});

  @override
  _GerenciarOperacaoModalState createState() => _GerenciarOperacaoModalState();
}

class _GerenciarOperacaoModalState extends State<AdicionarOperacao> {
  late String tipoOperacao;
  TextEditingController _nomeController = TextEditingController();
  final MoneyMaskedTextController _valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  bool _isPago = false;
  DateTime _selectedDate = DateTime.now();
  dynamic _selectedConta;
  dynamic _selectedCategoria;
  List<dynamic> contas = [];
  List<String> categoriasDespesa = [
    'Cartão de Crédito',
    'Alimentação',
    'Mercado',
    'Lazer',
    'Casa',
    'Educação',
    'Impostos',
    'Outros',
  ];
  List<String> categoriasReceita = [
    'Salário',
    'Investimento',
    'Empréstimo',
    'Outros',
  ];

  @override
  void initState() {
    tipoOperacao = widget.tipoOperacao;
    super.initState();
    _fetchContas();
  }

  Future<void> _fetchContas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      // Handle the case where authToken is null (e.g., user not authenticated)
      return;
    }

    final url = Uri.parse('https://financess-back.herokuapp.com/conta');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        contas = json.decode(response.body).cast();
        if (contas.isNotEmpty) {
          _selectedConta = contas[0]; // Set the default selected account
        }
      });
    } else {
      print('Failed to fetch accounts. Status code: ${response.statusCode}');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 1, // 95% da largura da tela
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tipoOperacao == 'receita'
                    ? 'Adicionar Receita'
                    : 'Adicionar Despesa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: tipoOperacao == 'receita'
                      ? 'Valor da Receita'
                      : 'Valor da Despesa',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text(tipoOperacao == 'receita' ? 'Recebido' : 'Pago'),
                value: _isPago,
                onChanged: (value) {
                  setState(() {
                    _isPago = value;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: tipoOperacao == 'receita'
                      ? 'Nome da Receita'
                      : 'Nome da Despesa',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Selecionar Data'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<Map>(
                value: _selectedConta,
                items: contas.map((conta) {
                  String instituicao = conta['instituicao'];
                  return DropdownMenuItem<Map>(
                    value: conta,
                    child: Text(instituicao),
                  );
                }).toList(),
                onChanged: (Map? newValue) {
                  setState(() {
                    _selectedConta = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Conta'),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategoria,
                items: tipoOperacao == 'receita'
                    ? categoriasReceita.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList()
                    : categoriasDespesa.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategoria = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Categoria'),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Cor do botão Cancelar
                    ),
                    child:
                        Text('Cancelar', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? authToken = prefs.getString('authToken');

                      if (authToken == null) {
                        // Handle the case where authToken is null (e.g., user not authenticated)
                        return;
                      }

                      final url = tipoOperacao == 'receita'
                          ? Uri.parse(
                              'https://financess-back.herokuapp.com/receita')
                          : Uri.parse(
                              'https://financess-back.herokuapp.com/despesa');

                      Map<String, dynamic> requestBody = {
                        "descricao": _nomeController.text,
                        "efetivado": _isPago,
                        "valor": _valorController.numberValue,
                        "data": DateFormat('yyyy-MM-dd').format(_selectedDate),
                        "categoria": {"descricao": _selectedCategoria},
                        "conta": _selectedConta,
                      };
                      print(json.encode(requestBody));

                      final response = await http.post(
                        url,
                        headers: {
                          'Authorization': 'Bearer $authToken',
                          'Content-Type': 'application/json',
                        },
                        body: json.encode(requestBody),
                      );

                      if (response.statusCode == 201) {
                        // Despesa salva com sucesso
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tipoOperacao == 'receita'
                                  ? "Receita salva com sucesso!"
                                  : 'Despesa salva com sucesso!',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(bottom: 0.0),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        print(
                            'Failed to save expense. Status code: ${response.statusCode}');
                      }
                      widget.onSave();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Cor do botão Salvar
                    ),
                    child: Text('Adicionar',
                        style: TextStyle(color: Colors.white)),
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
