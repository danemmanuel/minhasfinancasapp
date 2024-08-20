import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'contas_page.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

Future<void> saveAuthToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('authToken', token);
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _authenticateUser(String email, String password) async {
    final url =
        Uri.parse('https://financess-back.herokuapp.com/auth/local/signin');

    final response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      // Autenticação bem-sucedida
      Map<String, dynamic> responseBody = json.decode(response.body);
      String accessToken = responseBody['access_token'];
      print('Autenticação bem-sucedida. Token: ${response.body}');
      await saveAuthToken(accessToken);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Autenticação falhou
      print('Falha na autenticação. Código de status: ${response.statusCode}');
      // Exibir mensagem de erro ao usuário
    }
  }

  Future<void> _googleSignInMethod() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // O login foi cancelado pelo usuário
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      print('ID Token: $idToken');
      if (idToken != null) {
        // Enviar o token para o backend para autenticação
        final url =
            Uri.parse('https://financess-back.herokuapp.com/auth/google/auth');
        final response = await http.post(
          url,
          body: json.encode({'idToken': idToken}),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 201) {
          // Autenticação bem-sucedida
          Map<String, dynamic> responseBody = json.decode(response.body);
          String? accessToken = responseBody['accessToken'];
          print('Resposta do backend: ${response.body}');
          if (accessToken != null) {
            print('Autenticação bem-sucedida. Token: $accessToken');
            await saveAuthToken(accessToken);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            print('Erro: accessToken é nulo');
          }
        } else {
          print(
              'Erro na resposta do backend: ${response.statusCode} ${response.body}');
        }
      } else {
        print('Erro: idToken é nulo');
      }
    } catch (error) {
      print('Erro no login com Google: $error');
      // Exibir mensagem de erro ao usuário
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _authenticateUser(
                    _emailController.text, _passwordController.text);
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _googleSignInMethod,
              child: Text('Login with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
