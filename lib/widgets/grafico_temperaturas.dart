import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/dados_previsao.dart';

class GraficoTemperaturas extends StatelessWidget {
  const GraficoTemperaturas({super.key, required this.previsoes});

  final List<PrevisaoDia> previsoes;

  @override
  Widget build(BuildContext context) {
    final pontosMinima = <FlSpot>[];
    final pontosMaxima = <FlSpot>[];
    final valores = <double>[];

    for (var i = 0; i < previsoes.length; i++) {
      final minima = previsoes[i].minima;
      final maxima = previsoes[i].maxima;
      if (minima != null) {
        pontosMinima.add(FlSpot(i.toDouble(), minima.toDouble()));
        valores.add(minima.toDouble());
      }
      if (maxima != null) {
        pontosMaxima.add(FlSpot(i.toDouble(), maxima.toDouble()));
        valores.add(maxima.toDouble());
      }
    }

    if (valores.isEmpty) {
      return const Text('Dados insuficientes para exibir o gráfico.');
    }

    final menor = valores.reduce(min) - 2;
    final maior = valores.reduce(max) + 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temperaturas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const Row(
          children: [
            _Legenda(cor: Colors.blue, texto: 'Mínimas'),
            SizedBox(width: 20),
            _Legenda(cor: Colors.red, texto: 'Máximas'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: max(1, previsoes.length - 1).toDouble(),
              minY: menor,
              maxY: maior,
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (valor, _) => Text(
                      '${valor.toInt()}°',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (valor, _) {
                      final indice = valor.round();
                      if (indice < 0 || indice >= previsoes.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        _formatarDia(previsoes[indice].data),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                if (pontosMinima.isNotEmpty)
                  LineChartBarData(
                    spots: pontosMinima,
                    color: Colors.blue,
                    barWidth: 3,
                    isCurved: false,
                    dotData: const FlDotData(show: true),
                  ),
                if (pontosMaxima.isNotEmpty)
                  LineChartBarData(
                    spots: pontosMaxima,
                    color: Colors.red,
                    barWidth: 3,
                    isCurved: false,
                    dotData: const FlDotData(show: true),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatarDia(DateTime? data) {
    if (data == null) {
      return '--/--';
    }
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}';
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.cor, required this.texto});

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 4, color: cor),
        const SizedBox(width: 6),
        Text(texto),
      ],
    );
  }
}
