---
name: dataviz
description: Erstellt Charts und Dashboards. Auto-invoke bei: Chart, Dashboard, Visualization, Metric, Graph, Plot.
allowed-tools: Read, Grep, Glob, Edit, Write
---

# DataViz Skill

## Chart-Library: fl_chart

### Verfügbare Chart-Typen:
- `LineChart` - Trends über Zeit
- `BarChart` - Kategorien vergleichen
- `PieChart` - Anteile visualisieren
- `RadarChart` - Multi-Dimensionen

### Workflow:
1. **Daten analysieren** - Welcher Chart-Typ passt?
2. **Farben aus Tokens** - `DsColors.*` verwenden
3. **A11y sicherstellen** - `Semantics(label: ...)` für Achsen/Legenden
4. **Empty State** - Graceful UI wenn keine Daten

### Beispiel LineChart:
```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';

LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: data.map((d) => FlSpot(d.x, d.y)).toList(),
        color: DsColors.signature,
        barWidth: 2,
      ),
    ],
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: true),
      ),
    ),
  ),
)
```

### A11y für Charts:
```dart
Semantics(
  label: AppLocalizations.of(context)!.chartDescription,
  child: LineChart(...),
)
```

### Token-Referenz:
Siehe `.claude/skills/dataviz/CHART_TOKENS.md` für Chart-spezifische Farben.
