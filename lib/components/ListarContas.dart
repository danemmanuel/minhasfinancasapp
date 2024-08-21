import 'package:flutter/material.dart';
import '../helpers/formatar_valor_monetario.dart';
import '../pages/editar_conta_page.dart';

class ListarContas extends StatelessWidget {
  final dynamic contas;
  final Function onDismissed;
  final dynamic onSave;

  const ListarContas(
      {super.key, required this.contas, required this.onDismissed, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            key: Key(conta['id'].toString()), // Use a unique key for each item
            direction: DismissDirection.endToStart, // Swipe from right to left
            onDismissed: (direction) {
              onDismissed(conta, index);
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
                      onSave();
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
                              errorBuilder: (context, error, stackTrace) {
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
    );
  }
}
