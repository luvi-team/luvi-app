---
name: dataviz
description: Use when you need to create charts, graphs, or data visualizations in Flutter
---

# DataViz Skill

## Overview
Creates data visualizations using fl_chart with LUVI's design tokens.

## When to Use
- You need to display data as a chart
- Keywords: "Chart", "Graph", "Dashboard", "Visualization", "Metric", "Plot"
- Cycle data visualization (Menstruation, Ovulation, etc.)

## When NOT to Use
- Simple lists or tables (use ListView/DataTable)
- Static infographics (use Image/SVG)
- Real-time streaming data (needs different architecture)

## Chart Library: fl_chart

### Available Chart Types
- `LineChart` - Trends over time
- `BarChart` - Compare categories
- `PieChart` - Show proportions
- `RadarChart` - Multi-dimensional

## Workflow

1. **Analyze data** - Which chart type fits?
2. **Use design tokens** - `DsColors.*` for colors
3. **Ensure A11y** - `Semantics(label: ...)` for axes/legends
4. **Handle empty state** - Graceful UI when no data

## Quick Reference

### LineChart Example
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
  ),
)
```

### A11y Wrapper
```dart
Semantics(
  label: AppLocalizations.of(context)!.chartDescription,
  child: LineChart(...),
)
```

See `CHART_TOKENS.md` for cycle-phase colors.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Hardcoded chart colors | Use `DsColors.*` tokens |
| Missing Semantics | Wrap chart in `Semantics(label: ...)` |
| No empty state | Show placeholder when `data.isEmpty` |
| Wrong phase color | Check CHART_TOKENS.md for cycle phases |
