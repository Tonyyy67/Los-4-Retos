import 'package:flutter/material.dart';

void main() => runApp(const MemesGatosApp());

class MemesGatosApp extends StatelessWidget {
  const MemesGatosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memes de Gatos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: const MemePage(),
    );
  }
}

/// Construye la URL dinámica de Cataas.
/// Ejemplo: https://cataas.com/cat/says/Hola?fontSize=40&fontColor=white&filter=mono
class CataasApi {
  static const _base = 'https://cataas.com/cat';

  static String buildUrl({
    required String texto,
    required String filtro,
    required String colorTexto,
    required int tamano,
    required int semilla,
  }) {
    final limpio = texto.trim();
    // Si hay texto, usamos /cat/says/{texto}; si no, solo /cat
    final path = limpio.isEmpty
        ? _base
        : '$_base/says/${Uri.encodeComponent(limpio)}';

    final params = <String, String>{
      if (limpio.isNotEmpty) 'fontSize': '$tamano',
      if (limpio.isNotEmpty) 'fontColor': colorTexto,
      if (filtro != 'ninguno') 'filter': filtro,
      // Evita que Flutter use la imagen en caché: cada semilla = gato nuevo
      'v': '$semilla',
    };

    return Uri.parse(path).replace(queryParameters: params).toString();
  }
}

class MemePage extends StatefulWidget {
  const MemePage({super.key});

  @override
  State<MemePage> createState() => _MemePageState();
}

class _MemePageState extends State<MemePage> {
  final _controller = TextEditingController();

  String _texto = '';
  String _filtro = 'ninguno';
  String _color = 'white';
  double _tamano = 40;
  int _semilla = DateTime.now().millisecondsSinceEpoch;

  static const _filtros = {
    'ninguno': 'Sin filtro',
    'mono': 'Blanco y negro',
    'negate': 'Negativo',
    'blur': 'Desenfoque',
    'sepia': 'Sepia',
  };

  static const _colores = {
    'white': Colors.white,
    'yellow': Colors.yellow,
    'red': Colors.red,
    'black': Colors.black,
  };

  String get _url => CataasApi.buildUrl(
        texto: _texto,
        filtro: _filtro,
        colorTexto: _color,
        tamano: _tamano.round(),
        semilla: _semilla,
      );

  void _generar() {
    FocusScope.of(context).unfocus();
    setState(() => _texto = _controller.text);
  }

  void _otroGato() {
    setState(() {
      _texto = _controller.text;
      _semilla = DateTime.now().millisecondsSinceEpoch;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🐱 Generador de Memes de Gatos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Imagen del gato
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.black12,
                child: Image.network(
                  _url,
                  key: ValueKey(_url),
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progreso) {
                    if (progreso == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stack) => const Center(
                    child: Text('😿 No se pudo cargar el gato.\nIntenta otra vez.',
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Texto del meme
          TextField(
            controller: _controller,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: 'Escribe tu frase',
              hintText: 'Cuando es lunes...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
            onSubmitted: (_) => _generar(),
          ),

          // Filtro
          DropdownButtonFormField<String>(
            initialValue: _filtro,
            decoration: const InputDecoration(
              labelText: 'Filtro',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.filter_vintage),
            ),
            items: _filtros.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) => setState(() => _filtro = v!),
          ),
          const SizedBox(height: 12),

          // Color del texto
          Row(
            children: [
              const Text('Color del texto: '),
              ..._colores.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: const SizedBox(width: 14, height: 14),
                      avatar: CircleAvatar(backgroundColor: e.value),
                      selected: _color == e.key,
                      onSelected: (_) => setState(() => _color = e.key),
                    ),
                  )),
            ],
          ),

          // Tamaño
          Row(
            children: [
              Text('Tamaño: ${_tamano.round()}'),
              Expanded(
                child: Slider(
                  value: _tamano,
                  min: 20,
                  max: 80,
                  divisions: 12,
                  onChanged: (v) => setState(() => _tamano = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Botones
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _generar,
                  icon: const Icon(Icons.text_fields),
                  label: const Text('Poner texto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _otroGato,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Otro gato'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // URL generada (para ver cómo cambian los parámetros)
          SelectableText(
            _url,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
