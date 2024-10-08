import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/operacoes_page.dart';
import 'pages/contas_page.dart';
import 'pages/login_page.dart';
import 'components/page_container.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import necessário para localizações globais

void main() async {
  await initializeDateFormatting('pt_BR', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getAuthToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String authToken = snapshot.data ?? '';

          List<Widget> pages = [
            HomePage(),
            DespesasPage(
              key: UniqueKey(),
              tipoOperacao: 'receita',
            ),
            DespesasPage(
              key: UniqueKey(),
              tipoOperacao: 'despesa',
            ),
            // Adicione outras páginas aqui
          ];

          List<BottomNavigationBarItem> bottomNavBarItems = [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance),
              label: 'Contas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_arrow_up),
              label: 'Receitas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_arrow_down),
              label: 'Despesas',
            ),
          ];

          return MaterialApp(
            locale: Locale('pt', 'BR'), // Define a localidade como pt_BR
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('pt', 'BR'), // Adiciona suporte a pt_BR
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData
                .dark(), // Define o tema do aplicativo como tema escuro
            home: authToken.isNotEmpty
                ? PageContainer(
                    pages: pages, bottomNavBarItems: bottomNavBarItems)
                : LoginPage(),
          );
        } else {
          return CircularProgressIndicator(); // Mostrar um indicador de carregamento enquanto obtém o token
        }
      },
    );
  }

  Future<String> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ?? '';
  }
}
