import 'package:flutter/material.dart';

class BalanceItem {
  final dynamic titulo;
  final dynamic valor;
  final dynamic background;

  BalanceItem(
      {required this.titulo, required this.valor, required this.background});
}

class BalanceTopPage extends StatelessWidget {
  final bool isLoading;
  final BalanceItem item1;
  final BalanceItem item2;

  const BalanceTopPage({super.key, 
    required this.item1,
    required this.item2,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0), // Keep the right side rounded
                bottomRight: Radius.circular(10.0),
                topLeft: Radius.circular(10.0), // No rounding on the left side
                bottomLeft: Radius.circular(10.0),
              ),
            ),
            color: item1.background,
            child: ListTile(
              leading: Icon(
                Icons.attach_money,
                size: 20,
                color: Colors.white,
              ),
              title: isLoading
                  ? Container(
                      width: 100,
                      height: 15,
                      color: Colors.white.withOpacity(0.5),
                    )
                  : Container(
                      child: Text(
                        item1.titulo,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              subtitle: isLoading
                  ? Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 100,
                      height: 15,
                      color: Colors.white.withOpacity(0.5),
                    )
                  : Container(
                      child: Text(
                        item1.valor,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), // Keep the right side rounded
                bottomRight: Radius.circular(10),
                topLeft: Radius.circular(10.0), // No rounding on the left side
                bottomLeft: Radius.circular(10.0),
              ),
            ),
            color: item2.background,
            child: ListTile(
              leading: Icon(
                Icons.account_balance,
                size: 20,
                color: Colors.white,
              ),
              title: isLoading
                  ? Container(
                      width: 100,
                      height: 15,
                      color: Colors.white.withOpacity(0.5),
                    )
                  : Container(
                      child: Text(
                        item2.titulo,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              subtitle: isLoading
                  ? Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 100,
                      height: 15,
                      color: Colors.white.withOpacity(0.5),
                    )
                  : Container(
                      child: Text(
                        item2.valor,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
