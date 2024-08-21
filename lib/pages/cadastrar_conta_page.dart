import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/Button.dart';
import '../components/LabelInput.dart';

class CadastrarContaPage extends StatefulWidget {
  final void Function() onSave;

  const CadastrarContaPage({super.key, 
    required this.onSave,
  });

  @override
  _EditOperationPageState createState() => _EditOperationPageState();
}

class _EditOperationPageState extends State<CadastrarContaPage> {
  final MoneyMaskedTextController _valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  final TextEditingController _nomeController = TextEditingController();
  dynamic _selectedConta;
  dynamic _selectedBanco;
  List<dynamic> contas = [];
  List<String> tiposConta = [
    'Conta Corrente',
    'Investimentos',
    'Dinheiro',
    'Outros',
  ];
  List<String> bancos = [
    'nubank',
    'c6',
    'bradesco',
    'btg',
    'inter',
    'itau',
    'neon',
    'rico',
    'santander',
    'unicred',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _cadastrarConta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      // Handle the case where authToken is null (e.g., user not authenticated)
      return;
    }

    final url = Uri.parse('https://financess-back.herokuapp.com/conta');

    Map<String, dynamic> requestBody = {
      "instituicao": _selectedBanco,
      "saldo": _valorController.numberValue,
      "tipoConta": _selectedConta,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Conta salva com sucesso!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 0.0),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
      widget.onSave();
    } else {
      print('Failed to save expense. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Conta'),
        backgroundColor: Colors.blue, // Define o fundo do AppBar como verde
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: 'saldo',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0), // Aqui você define o tamanho do texto
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(21, 17, 25, 1),
                  borderRadius: BorderRadius.only(
                    topLeft:
                        Radius.circular(30), // Raio no canto superior esquerdo
                    topRight:
                        Radius.circular(30), // Raio no canto superior direito
                  ),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(children: [
                  LabelInput('banco'),
                  DropdownButtonFormField<String>(
                    value: _selectedBanco,
                    items: bancos.map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  20), // Ajuste o valor para o raio desejado
                              child: Image.asset(
                                'assets/images/${categoria.toLowerCase()}.png', // Caminho dinâmico para a imagem
                                width: 30,
                                height: 30,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons
                                      .error); // Exibir um ícone de erro se a imagem falhar ao carregar
                                },
                              ),
                            ),
                            SizedBox(
                                width:
                                    20), // Espaço entre o logo e o nome do banco
                            Text(categoria),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBanco = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'selecione',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                  ),
                  SizedBox(height: 20),
                  LabelInput('tipo de conta'),
                  DropdownButtonFormField<String>(
                    value: _selectedConta,
                    items: tiposConta.map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedConta = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: 'selecione',
                        floatingLabelBehavior: FloatingLabelBehavior.never),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child:
                            Button('adicionar', Colors.blue, _cadastrarConta),
                      ),
                    ],
                  )
                ]))
          ],
        )),
      ),
    );
  }
}
