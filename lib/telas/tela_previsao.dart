import 'package:flutter/material.dart';

import '../models/dados_previsao.dart';
import '../services/cptec_service.dart';
import '../services/previsao_storage.dart';
import '../utils/condicoes_tempo.dart';
import '../widgets/grafico_temperaturas.dart';

class TelaPrevisao extends StatefulWidget {
  const TelaPrevisao({super.key, required this.cidade, this.dadosIniciais});

  final Cidade cidade;
  final DadosPrevisao? dadosIniciais;

  @override
  State<TelaPrevisao> createState() => _TelaPrevisaoState();
}

class _TelaPrevisaoState extends State<TelaPrevisao> {
  final _cptec = CptecService();
  final _armazenamento = PrevisaoStorage();

  DadosPrevisao? _dados;
  String? _mensagem;
  bool _carregando = false;
  bool _dadosSalvos = false;

  @override
  void initState() {
    super.initState();
    _dados = widget.dadosIniciais;
    _dadosSalvos = widget.dadosIniciais != null;
    if (_dados == null) {
      _atualizar();
    }
  }

  Future<void> _atualizar() async {
    if (_carregando) return;
    setState(() {
      _carregando = true;
      _mensagem = null;
    });

    try {
      final dados = await _cptec.buscarPrevisao(widget.cidade);
      if (!mounted) return;

      if (dados.previsoes.isEmpty) {
        setState(() => _mensagem = 'Não há previsão disponível.');
        return;
      }

      var falhaAoSalvar = false;
      try {
        await _armazenamento.salvar(dados);
      } catch (_) {
        falhaAoSalvar = true;
      }
      if (!mounted) return;
      setState(() {
        _dados = dados;
        _dadosSalvos = false;
        if (falhaAoSalvar) {
          _mensagem = 'A previsão foi carregada, mas não pôde ser salva.';
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

  String _mensagemErro(TipoErroCptec tipo) {
    switch (tipo) {
      case TipoErroCptec.conexao:
        return _dados == null
            ? 'Falha de conexão. Verifique sua internet.'
            : 'Falha de conexão. A última previsão foi preservada.';
      case TipoErroCptec.indisponivel:
        return 'A previsão está indisponível no CPTEC/INPE.';
      case TipoErroCptec.respostaInvalida:
        return 'O serviço retornou uma resposta inválida.';
    }
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Não informada';
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previsão')),
      body: _dados == null ? _construirSemDados() : _construirPrevisao(),
    );
  }

  Widget _construirSemDados() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _mensagem ?? 'Não há previsão disponível.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _atualizar,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirPrevisao() {
    final dados = _dados!;
    return RefreshIndicator(
      onRefresh: _atualizar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${dados.cidade.nome}/${dados.cidade.uf}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('Atualização: ${_formatarData(dados.atualizacao)}'),
          if (_dadosSalvos)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('Exibindo a última previsão salva no aparelho.'),
              ),
            ),
          if (_mensagem != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_mensagem!),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _carregando ? null : _atualizar,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar previsão'),
          ),
          if (_carregando) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 24),
          GraficoTemperaturas(previsoes: dados.previsoes),
          const SizedBox(height: 16),
          ...dados.previsoes.map(_cartaoPrevisao),
          const SizedBox(height: 8),
          const Text(
            'Fonte dos dados: CPTEC/INPE',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _cartaoPrevisao(PrevisaoDia previsao) {
    final minima = previsao.minima == null
        ? 'Não informada'
        : '${previsao.minima} °C';
    final maxima = previsao.maxima == null
        ? 'Não informada'
        : '${previsao.maxima} °C';
    final indiceUv = previsao.indiceUv == null
        ? 'Não informado'
        : previsao.indiceUv!.toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconeTempo(previsao.sigla), size: 42),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatarData(previsao.data),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(descricaoTempo(previsao.sigla)),
                  const SizedBox(height: 8),
                  Text('Mínima: $minima'),
                  Text('Máxima: $maxima'),
                  Text('Índice UV: $indiceUv'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
