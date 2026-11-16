class Cidade {
  const Cidade({required this.id, required this.nome, required this.uf});

  final String id;
  final String nome;
  final String uf;

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome, 'uf': uf};
  }

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      uf: json['uf']?.toString() ?? '',
    );
  }
}

class PrevisaoDia {
  const PrevisaoDia({
    required this.data,
    required this.sigla,
    required this.minima,
    required this.maxima,
    required this.indiceUv,
  });

  final DateTime? data;
  final String sigla;
  final int? minima;
  final int? maxima;
  final double? indiceUv;

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toIso8601String(),
      'sigla': sigla,
      'minima': minima,
      'maxima': maxima,
      'indiceUv': indiceUv,
    };
  }

  factory PrevisaoDia.fromJson(Map<String, dynamic> json) {
    return PrevisaoDia(
      data: DateTime.tryParse(json['data']?.toString() ?? ''),
      sigla: json['sigla']?.toString() ?? '',
      minima: int.tryParse(json['minima']?.toString() ?? ''),
      maxima: int.tryParse(json['maxima']?.toString() ?? ''),
      indiceUv: double.tryParse(json['indiceUv']?.toString() ?? ''),
    );
  }
}

class DadosPrevisao {
  const DadosPrevisao({
    required this.cidade,
    required this.atualizacao,
    required this.previsoes,
  });

  final Cidade cidade;
  final DateTime? atualizacao;
  final List<PrevisaoDia> previsoes;

  Map<String, dynamic> toJson() {
    return {
      'cidade': cidade.toJson(),
      'atualizacao': atualizacao?.toIso8601String(),
      'previsoes': previsoes.map((previsao) => previsao.toJson()).toList(),
    };
  }

  factory DadosPrevisao.fromJson(Map<String, dynamic> json) {
    final cidadeJson = json['cidade'];
    final previsoesJson = json['previsoes'];

    if (cidadeJson is! Map || previsoesJson is! List) {
      throw const FormatException('Dados salvos inválidos.');
    }

    return DadosPrevisao(
      cidade: Cidade.fromJson(Map<String, dynamic>.from(cidadeJson)),
      atualizacao: DateTime.tryParse(json['atualizacao']?.toString() ?? ''),
      previsoes: previsoesJson
          .whereType<Map>()
          .map(
            (previsao) =>
                PrevisaoDia.fromJson(Map<String, dynamic>.from(previsao)),
          )
          .toList(),
    );
  }
}
