import 'package:flutter/material.dart';

import 'telas/tela_pesquisa.dart';

void main() {
  runApp(const AplicativoPrevisao());
}

class AplicativoPrevisao extends StatelessWidget {
  const AplicativoPrevisao({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Previsão do tempo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TelaPesquisa(),
    );
  }
}
