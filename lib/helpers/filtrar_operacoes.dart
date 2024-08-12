List<dynamic>? filterDespesas(List<dynamic>? despesas, int ano, int mes) {
  return despesas?.where((operacao) {
    try {
      DateTime data = DateTime.parse(operacao['data']);
      data = data.add(Duration(days: 1));

      int repetirPorValue =
          operacao['repetirPor'] != null ? operacao['repetirPor'] as int : 0;
      DateTime repetirPor =
          DateTime(data.year, data.month + repetirPorValue, 1);

      bool isDespesaFixaValida = operacao['fixa'] == true &&
          data.isBefore(DateTime(ano, mes, 1)) &&
          DateTime(ano, mes, 1).isBefore(
              operacao['repetirPor'] != null && operacao['repetirPor']! > 0
                  ? repetirPor
                  : DateTime(9999, 12, 31)) &&
          operacao['excluirData'] != null &&
          !operacao['excluirData']!.any((excluirData) {
            List<String> parts = excluirData.split('-');
            return int.parse(parts[0]) == ano && int.parse(parts[1]) == mes;
          });

      bool isDespesaMesAtual =
          (operacao['fixa'] == false || operacao['fixa'] == null) &&
              operacao['data'] != null &&
              int.parse(operacao['data'].split('-')[1]) == mes &&
              int.parse(operacao['data'].split('-')[0]) == ano;

      return isDespesaFixaValida || isDespesaMesAtual;
    } catch (e) {
      return false; // Return false for entries with invalid dates
    }
  }).toList();
}
