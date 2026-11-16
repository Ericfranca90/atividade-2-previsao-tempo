import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/dados_previsao.dart';

enum TipoErroCptec { conexao, indisponivel, respostaInvalida }

class CptecException implements Exception {
  const CptecException(this.tipo);

  final TipoErroCptec tipo;
}

class CptecService {
  static const _host = 'servicos.cptec.inpe.br';
  static const _tempoLimite = Duration(seconds: 15);

  Future<List<Cidade>> buscarCidades(String nome) async {
    final uri = Uri.https(_host, '/XML/listaCidades', {
      'city': _removerAcentos(nome.trim().toLowerCase()),
    });
    final resposta = await _consultar(uri);

    try {
      final documento = XmlDocument.parse(_decodificar(resposta));
      if (documento.rootElement.name.local != 'cidades') {
        throw const FormatException();
      }

      final elementos = documento.rootElement.findElements('cidade').toList();
      if (elementos.isEmpty) {
        return [];
      }

      final cidades = <Cidade>[];
      for (final elemento in elementos) {
        final nomeCidade = _texto(elemento, 'nome');
        final uf = _texto(elemento, 'uf');
        final id = _texto(elemento, 'id');
        if (nomeCidade == null || uf == null || id == null) {
          throw const FormatException();
        }
        cidades.add(Cidade(id: id, nome: nomeCidade, uf: uf));
      }
      return cidades;
    } catch (_) {
      throw const CptecException(TipoErroCptec.respostaInvalida);
    }
  }

  Future<DadosPrevisao> buscarPrevisao(Cidade cidade) async {
    final uri = Uri.https(_host, '/XML/cidade/${cidade.id}/previsao.xml');
    final resposta = await _consultar(uri);

    try {
      final documento = XmlDocument.parse(_decodificar(resposta));
      final raiz = documento.rootElement;
      if (raiz.name.local != 'cidade') {
        throw const FormatException();
      }

      final cidadeRetornada = Cidade(
        id: cidade.id,
        nome: _texto(raiz, 'nome') ?? cidade.nome,
        uf: _texto(raiz, 'uf') ?? cidade.uf,
      );
      final previsoes = raiz.findElements('previsao').map((elemento) {
        return PrevisaoDia(
          data: DateTime.tryParse(_texto(elemento, 'dia') ?? ''),
          sigla: _texto(elemento, 'tempo') ?? '',
          maxima: int.tryParse(_texto(elemento, 'maxima') ?? ''),
          minima: int.tryParse(_texto(elemento, 'minima') ?? ''),
          indiceUv: double.tryParse(_texto(elemento, 'iuv') ?? ''),
        );
      }).toList();

      return DadosPrevisao(
        cidade: cidadeRetornada,
        atualizacao: DateTime.tryParse(_texto(raiz, 'atualizacao') ?? ''),
        previsoes: previsoes,
      );
    } catch (_) {
      throw const CptecException(TipoErroCptec.respostaInvalida);
    }
  }

  Future<http.Response> _consultar(Uri uri) async {
    try {
      final resposta = await http.get(uri).timeout(_tempoLimite);
      if (resposta.statusCode != 200) {
        throw const CptecException(TipoErroCptec.indisponivel);
      }
      return resposta;
    } on CptecException {
      rethrow;
    } on TimeoutException {
      throw const CptecException(TipoErroCptec.conexao);
    } on SocketException {
      throw const CptecException(TipoErroCptec.conexao);
    } on http.ClientException {
      throw const CptecException(TipoErroCptec.conexao);
    }
  }

  String _decodificar(http.Response resposta) {
    return latin1.decode(resposta.bodyBytes);
  }

  String? _texto(XmlElement elemento, String nome) {
    final encontrados = elemento.findElements(nome);
    if (encontrados.isEmpty) {
      return null;
    }
    final texto = encontrados.first.innerText.trim();
    return texto.isEmpty ? null : texto;
  }

  String _removerAcentos(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const semAcento = 'aaaaaeeeeiiiiooooouuuuc';
    var resultado = texto;
    for (var i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }
}
