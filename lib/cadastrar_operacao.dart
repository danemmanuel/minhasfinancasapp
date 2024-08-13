import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'components/Button.dart';
import 'components/LabelInput.dart';

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

  Future<void> _cadastrarOperacao() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      // Handle the case where authToken is null (e.g., user not authenticated)
      return;
    }

    final url = tipoOperacao == 'receita'
        ? Uri.parse('https://financess-back.herokuapp.com/receita')
        : Uri.parse('https://financess-back.herokuapp.com/despesa');

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
      print('Failed to save expense. Status code: ${response.statusCode}');
    }
    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tipoOperacao == 'receita'
            ? 'Cadastrar Receita'
            : 'Cadastrar Despesa'),
        backgroundColor: widget.tipoOperacao == 'receita'
            ? Colors.green
            : Colors.red, // Define o fundo do AppBar como verde
      ),
      body: Container(
        decoration: BoxDecoration(
          color: widget.tipoOperacao == 'receita' ? Colors.green : Colors.red,
        ),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: 'valor',
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
                  LabelInput('título'),
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                      child: SwitchListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title:
                        Text(tipoOperacao == 'receita' ? 'recebido' : 'pago'),
                    value: _isPago,
                    onChanged: (value) {
                      setState(() {
                        _isPago = value;
                      });
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.black,
                  )),
                  SizedBox(height: 20),
                  LabelInput('data'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                      Row(
                        children: [
                          Button(
                              'hoje',
                              tipoOperacao == 'receita'
                                  ? Colors.green
                                  : Colors.red, () {
                            setState(() {
                              setState(() {
                                _selectedDate =
                                    DateTime.now(); // Define a data como hoje
                              });
                            });
                          }),
                          SizedBox(width: 8.0),
                          Button(
                              'ontem',
                              tipoOperacao == 'receita'
                                  ? Colors.green
                                  : Colors.red, () {
                            setState(() {
                              setState(() {
                                _selectedDate = DateTime.now().subtract(
                                    Duration(
                                        days: 1)); // Define a data como ontem
                              });
                            });
                          }),
                          SizedBox(width: 8.0),
                          Button(
                              'selecionar',
                              tipoOperacao == 'receita'
                                  ? Colors.green
                                  : Colors.red, () {
                            setState(() {
                              _selectDate(context);
                            });
                          })
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  LabelInput('conta'),
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
                    decoration: InputDecoration(
                      labelText: 'selecione',
                      floatingLabelBehavior: FloatingLabelBehavior
                          .never, // Mantém o label fixo acima do input
                    ),
                  ),
                  SizedBox(height: 30),
                  LabelInput('categoria'),
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
                    decoration: InputDecoration(
                        labelText: 'selecione',
                        floatingLabelBehavior: FloatingLabelBehavior.never),
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
                        child: Text('cancelar',
                            style: TextStyle(color: Colors.white)),
                      ),
                      Button('adicionar', Colors.green, _cadastrarOperacao)
                    ],
                  )
                ]))
          ],
        )),
      ),
    );
  }
}
