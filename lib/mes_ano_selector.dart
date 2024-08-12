import 'package:flutter/material.dart';

class MesAnoSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  MesAnoSelector({
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          padding: EdgeInsets.all(20),
          icon: Icon(Icons.arrow_left),
          onPressed: onPreviousMonth,
        ),
        Text(
          '${selectedDate.month == 1 ? 'Janeiro' : selectedDate.month == 2 ? 'Fevereiro' : selectedDate.month == 3 ? 'Março' : selectedDate.month == 4 ? 'Abril' : selectedDate.month == 5 ? 'Maio' : selectedDate.month == 6 ? 'Junho' : selectedDate.month == 7 ? 'Julho' : selectedDate.month == 8 ? 'Agosto' : selectedDate.month == 9 ? 'Setembro' : selectedDate.month == 10 ? 'Outubro' : selectedDate.month == 11 ? 'Novembro' : 'Dezembro'} de ${selectedDate.year}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          padding: EdgeInsets.all(20),
          icon: Icon(Icons.arrow_right),
          onPressed: onNextMonth,
        ),
      ],
    );
  }
}
