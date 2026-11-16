import 'package:flutter/material.dart';

const Map<String, String> descricoesTempo = {
  'ec': 'Encoberto com chuvas isoladas',
  'ci': 'Chuvas isoladas',
  'c': 'Chuva',
  'in': 'Instável',
  'pp': 'Possibilidade de pancadas de chuva',
  'cm': 'Chuva pela manhã',
  'cn': 'Chuva à noite',
  'pt': 'Pancadas de chuva à tarde',
  'pm': 'Pancadas de chuva pela manhã',
  'np': 'Nublado e pancadas de chuva',
  'pc': 'Pancadas de chuva',
  'pn': 'Parcialmente nublado',
  'cv': 'Chuvisco',
  'ch': 'Chuvoso',
  't': 'Tempestade',
  'ps': 'Predomínio de sol',
  'e': 'Encoberto',
  'n': 'Nublado',
  'cl': 'Céu claro',
  'nv': 'Nevoeiro',
  'g': 'Geada',
  'ne': 'Neve',
  'nd': 'Não definido',
  'pnt': 'Pancadas de chuva à noite',
  'psc': 'Possibilidade de chuva',
  'pcm': 'Possibilidade de chuva pela manhã',
  'pct': 'Possibilidade de chuva à tarde',
  'pcn': 'Possibilidade de chuva à noite',
  'npt': 'Nublado com pancadas à tarde',
  'npn': 'Nublado com pancadas à noite',
  'ncn': 'Nublado com possibilidade de chuva à noite',
  'nct': 'Nublado com possibilidade de chuva à tarde',
  'ncm': 'Nublado com possibilidade de chuva pela manhã',
  'npm': 'Nublado com pancadas pela manhã',
  'npp': 'Nublado com possibilidade de chuva',
  'vn': 'Variação de nebulosidade',
  'ct': 'Chuva à tarde',
  'ppn': 'Possibilidade de pancadas de chuva à noite',
  'ppt': 'Possibilidade de pancadas de chuva à tarde',
  'ppm': 'Possibilidade de pancadas de chuva pela manhã',
};

String descricaoTempo(String sigla) {
  return descricoesTempo[sigla.toLowerCase()] ?? 'Condição não informada';
}

IconData iconeTempo(String sigla) {
  final codigo = sigla.toLowerCase();

  if (codigo == 'cl' || codigo == 'ps') {
    return Icons.wb_sunny_outlined;
  }
  if (codigo == 'pn' || codigo == 'vn') {
    return Icons.wb_cloudy_outlined;
  }
  if (codigo == 'n' || codigo == 'e') {
    return Icons.cloud_outlined;
  }
  if (codigo == 't') {
    return Icons.thunderstorm_outlined;
  }
  if (codigo == 'nv') {
    return Icons.foggy;
  }
  if (codigo == 'g') {
    return Icons.ac_unit;
  }
  if (codigo == 'ne') {
    return Icons.severe_cold_outlined;
  }
  if (codigo == 'nd' || codigo.isEmpty) {
    return Icons.help_outline;
  }
  return Icons.water_drop_outlined;
}
