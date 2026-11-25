import 'package:flutter_test/flutter_test.dart';
import 'package:memes_gatos/main.dart';

void main() {
  test('La URL de Cataas incluye texto, color, tamaño y filtro', () {
    final url = CataasApi.buildUrl(
      texto: 'Hola mundo',
      filtro: 'mono',
      colorTexto: 'white',
      tamano: 40,
      semilla: 1,
    );
    expect(url, startsWith('https://cataas.com/cat/says/Hola%20mundo?'));
    expect(url, contains('fontSize=40'));
    expect(url, contains('fontColor=white'));
    expect(url, contains('filter=mono'));
  });

  test('Sin texto usa /cat y sin filtro no manda filter', () {
    final url = CataasApi.buildUrl(
      texto: '  ',
      filtro: 'ninguno',
      colorTexto: 'white',
      tamano: 40,
      semilla: 1,
    );
    expect(url, 'https://cataas.com/cat?v=1');
  });
}
