import 'package:flutter/material.dart';

import '../models/dados_previsao.dart';
import '../services/cptec_service.dart';
import '../services/previsao_storage.dart';
import 'tela_previsao.dart';

class TelaPesquisa extends StatefulWidget {
  const TelaPesquisa({super.key});

  @override
  State<TelaPesquisa> createState() => _TelaPesquisaState();
}

class _TelaPesquisaState extends State<TelaPesquisa> {
  final _controleCidade = TextEditingController();
  final _cptec = CptecService();
  final _armazenamento = PrevisaoStorage();

  List<Cidade> _cidades = [];
  DadosPrevisao? _ultimaPrevisao;
  String? _mensagem;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregarUltimaPrevisao();
  }

  @override
  void dispose() {
    _controleCidade.dispose();
    super.dispose();
  }

  Future<void> _carregarUltimaPrevisao() async {
    final dados = await _armazenamento.carregar();
    if (!mounted) return;
    setState(() => _ultimaPrevisao = dados);
  }

  Future<void> _buscar() async {
    final nome = _controleCidade.text.trim();
    if (nome.isEmpty) {
      setState(() {
        _mensagem = 'Digite o nome de uma cidade.';
        _cidades = [];
      });
      return;
    }
    if (_carregando) return;

    setState(() {
      _carregando = true;
      _mensagem = null;
      _cidades = [];
    });

    try {
      final cidades = await _cptec.buscarCidades(nome);
      if (!mounted) return;
      setState(() {
        _cidades = cidades;
        if (cidades.isEmpty) {
          _mensagem = 'Nenhuma cidade foi encontrada.';
        }
      });
    } on CptecException catch (erro) {
      if (!mounted) return;
      setState(() => _mensagem = _mensagemErro(erro.tipo));
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _abrirPrevisao(
    Cidade cidade, {
    DadosPrevisao? dadosSalvos,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TelaPrevisao(cidade: cidade, dadosIniciais: dadosSalvos),
      ),
    );
    await _carregarUltimaPrevisao();
  }

  String _mensagemErro(TipoErroCptec tipo) {
    switch (tipo) {
      case TipoErroCptec.conexao:
        return 'Falha de conexão. Verifique sua internet.';
      case TipoErroCptec.indisponivel:
        return 'O serviço do CPTEC/INPE está indisponível.';
      case TipoErroCptec.respostaInvalida:
        return 'O serviço retornou uma resposta inválida.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previsão do tempo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controleCidade,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _buscar(),
              decoration: const InputDecoration(
                labelText: 'Nome da cidade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _carregando ? null : _buscar,
              icon: const Icon(Icons.search),
              label: const Text('Pesquisar'),
            ),
            if (_ultimaPrevisao != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _abrirPrevisao(
                  _ultimaPrevisao!.cidade,
                  dadosSalvos: _ultimaPrevisao,
                ),
                icon: const Icon(Icons.history),
                label: Text(
                  'Ver última previsão: '
                  '${_ultimaPrevisao!.cidade.nome}/${_ultimaPrevisao!.cidade.uf}',
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (_carregando) const LinearProgressIndicator(),
            if (_mensagem != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_mensagem!, textAlign: TextAlign.center),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: _cidades.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, indice) {
                  final cidade = _cidades[indice];
                  return ListTile(
                    title: Text(cidade.nome),
                    subtitle: Text(cidade.uf),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _abrirPrevisao(cidade),
                  );
                },
              ),
            ),
            const Text(
              'Fonte dos dados: CPTEC/INPE',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
