List<dynamic>? filterDespesas(List<dynamic>? despesas, int ano, int mes) {
  return despesas?.where((operacao) {
    try {
      DateTime data = DateTime.parse(operacao['data']);
      int repetirPorValue =
          operacao['repetirPor'] != null ? operacao['repetirPor'] as int : 0;
      DateTime repetirPor =
          DateTime(data.year, data.month + repetirPorValue, 1);

      // Formato de ano-mês para comparação
      String anoMes =
          '${ano.toString().padLeft(4, '0')}-${mes.toString().padLeft(2, '0')}';
      print(anoMes);
      // Verifica se a despesa é fixa e processa com base no conteúdo de excluirData
      bool isDespesaFixaValida = false;
      if (operacao['fixa'] == true) {
        DateTime dataInicio = DateTime(ano, mes, 1);
        DateTime dataFim = DateTime(ano, mes + 1, 1);

        // Quando excluirData está vazio ou nulo
        if (operacao['excluirData'] == null ||
            operacao['excluirData'].isEmpty) {
          isDespesaFixaValida =
              data.isBefore(dataFim) && dataInicio.isBefore(repetirPor);
        } else {
          // Quando excluirData contém dados
          isDespesaFixaValida = data.isBefore(dataFim) &&
              dataInicio.isBefore(repetirPor) &&
              !operacao['excluirData'].any((excluirData) {
                // Verifica se a data de excluirData corresponde ao ano e mês filtrados
                String dataAnoMes = excluirData.substring(0, 7); // 'yyyy-MM'
                return dataAnoMes == anoMes;
              });
        }
      }

      // Verificação para despesas do mês atual
      bool isDespesaMesAtual =
          (operacao['fixa'] == false || operacao['fixa'] == null) &&
              data.year == ano &&
              data.month == mes;

      // Inclui despesas fixas com repetirPor igual a 0 e exclui aquelas no mês e ano do excluirData
      bool incluirDespesaFixaComRepetirPorZero = operacao['fixa'] == true &&
          repetirPorValue == 0 &&
          (operacao['excluirData'] == null ||
              operacao['excluirData'].isEmpty ||
              !(operacao['excluirData'] as List<dynamic>).any((excluirData) {
                // Verifica se o mês e ano de excluirData não estão no ano e mês atuais
                String dataAnoMes = excluirData.substring(0, 7); // 'yyyy-MM'
                return dataAnoMes == anoMes;
              }));

      // Exclui despesas se o mês e ano estão na lista de excluirData
      bool isExcluirData = operacao['excluirData'] != null &&
          operacao['excluirData'].any((excluirData) {
            String excluirAnoMes = excluirData.substring(0, 7); // 'yyyy-MM'
            return excluirAnoMes == anoMes;
          });

      return (isDespesaFixaValida ||
              incluirDespesaFixaComRepetirPorZero ||
              isDespesaMesAtual) &&
          !isExcluirData;
    } catch (e) {
      print('Erro ao filtrar despesa: $e');
      return false; // Retorna falso para entradas com datas inválidas
    }
  }).toList();
}
