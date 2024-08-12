import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CadastrarOperacaoPage extends StatefulWidget {
  final String tipoOperacao;
  final void Function() onSave;

  CadastrarOperacaoPage({
    required this.tipoOperacao,
    required this.onSave,
  });

  @override
  _EditOperationPageState createState() => _EditOperationPageState();
}

class _EditOperationPageState extends State<CadastrarOperacaoPage> {
  late String tipoOperacao;
  final MoneyMaskedTextController _valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  TextEditingController _nomeController = TextEditingController();
  bool _isPago = false;
  DateTime _selectedDate = DateTime.now();
  dynamic _selectedConta;
  dynamic _selectedCategoria;
  List<dynamic> contas = [];
  List<String> categoriasDespesa = [
    'Cartão de Crédito',
    'Alimentacao',
    'Mercado',
    'Lazer',
    'Casa',
    'Educação',
    'Serviços',
    'Impostos',
    'Saúde',
    'Taxas',
    'Outros',
  ];
  List<String> categoriasReceita = [
    'Salário',
    'Investimento',
    'Recisão',
    'Emprestimo',
    'Dividendo',
    'Outros',
  ];
  // Seus controllers e outras variáveis

  @override
  void initState() {
    super.initState();
    tipoOperacao = widget.tipoOperacao;
    super.initState();
    _fetchContas();
    // Inicialize seus controllers e variáveis
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tipoOperacao == 'receita'
            ? 'Cadastrar Receita'
            : 'Cadastrar Despesa'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
          children: [
            // Seu conteúdo existente (TextField, SwitchListTile, etc.)
            SizedBox(height: 20),
            TextField(
              controller: _valorController,
              decoration: InputDecoration(
                labelText: tipoOperacao == 'receita'
                    ? 'Valor da Receita'
                    : 'Valor da Despesa',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
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
              activeColor: Colors.green,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.black,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: tipoOperacao == 'receita'
                    ? 'Nome da Receita'
                    : 'Nome da Despesa',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
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
                    backgroundColor: Colors.red,
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

                    final response = await http.post(
                      url,
                      headers: {
                        'Authorization': 'Bearer $authToken',
                        'Content-Type': 'application/json',
                      },
                      body: json.encode(requestBody),
                    );

                    if (response.statusCode == 201) {
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
                          duration: Duration(seconds: 2),
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
                    backgroundColor: Colors.green,
                  ),
                  child:
                      Text('Adicionar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
