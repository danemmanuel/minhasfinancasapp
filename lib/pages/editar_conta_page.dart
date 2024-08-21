import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/Button.dart';
import '../components/LabelInput.dart';

class EditarContaPage extends StatefulWidget {
  final void Function() onSave;
  final Map<String, dynamic> conta;

  const EditarContaPage({super.key, 
    required this.conta,
    required this.onSave,
  });

  @override
  _EditarContaPageState createState() => _EditarContaPageState();
}

class _EditarContaPageState extends State<EditarContaPage> {
  late MoneyMaskedTextController _valorController;
  late TextEditingController _nomeController;
  late String _selectedConta;
  late String _selectedBanco;
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
    _valorController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
      initialValue: widget.conta['saldo'].toDouble(),
    );
    _nomeController = TextEditingController(text: widget.conta['instituicao']);
    _selectedConta = widget.conta['tipoConta'];
    _selectedBanco = widget.conta['instituicao'].toLowerCase();
  }

  @override
  void dispose() {
    _valorController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _editarConta() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      // Handle the case where authToken is null (e.g., user not authenticated)
      return;
    }

    final url = Uri.parse('https://financess-back.herokuapp.com/conta');

    Map<String, dynamic> requestBody = {
      "_id": widget.conta['_id'],
      "instituicao": _selectedBanco,
      "saldo": _valorController.numberValue,
      "tipoConta": _selectedConta,
    };

    print(json.encode(requestBody));

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Conta atualizada com sucesso!',
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
      print('Failed to update account. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Conta'),
        backgroundColor: Colors.blue,
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
                    fontSize: 30.0,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(21, 17, 25, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    LabelInput('banco'),
                    DropdownButtonFormField<String>(
                      value: _selectedBanco,
                      items: bancos.map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/${categoria.toLowerCase()}.png',
                                  width: 30,
                                  height: 30,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error);
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
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
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: Button('atualizar', Colors.blue, _editarConta),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
