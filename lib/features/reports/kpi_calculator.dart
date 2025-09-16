/// KpiCalculator: helpers para KPIs.
library;

class KpiCalculator {
  static double conversionRate(int leads, int sales) =>
      leads == 0 ? 0 : sales / leads;

  static double growthPercent(num previous, num current) =>
      previous == 0 ? 0 : ((current - previous) / previous) * 100;
}
