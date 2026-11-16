import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/dados_previsao.dart';

class PrevisaoStorage {
  static const _chave = 'ultima_previsao';
  final SharedPreferencesAsync _preferencias = SharedPreferencesAsync();

  Future<void> salvar(DadosPrevisao dados) async {
    await _preferencias.setString(_chave, jsonEncode(dados.toJson()));
  }

  Future<DadosPrevisao?> carregar() async {
    try {
      final texto = await _preferencias.getString(_chave);
      if (texto == null) {
        return null;
      }
      final json = jsonDecode(texto);
      if (json is! Map) {
        return null;
      }
      return DadosPrevisao.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }
}
