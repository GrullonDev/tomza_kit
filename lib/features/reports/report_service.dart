/// ReportService: generación de reportes simple.

class ReportService {
  Future<Map<String, num>> generateKpis(Map<String, num> data) async {
    // Mock: retornar sumatoria y promedio de valores.
    final values = data.values.toList();
    final sum = values.fold<num>(0, (a, b) => a + b);
    final avg = values.isEmpty ? 0 : sum / values.length;
    return {'sum': sum, 'avg': avg};
  }
}
