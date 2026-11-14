import 'package:flutter/material.dart';
import 'package:recetas_app/models/receta.dart';
import 'package:recetas_app/models/resena.dart';
import 'package:recetas_app/services/resena_service.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final Receta receta;
  const DetalleRecetaScreen({super.key, required this.receta});
  @override
  State<DetalleRecetaScreen> createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> {
  final _resenaService = ResenaService();
  late Future<List<Resena>> _resenas;
  @override
  void initState() {
    super.initState();
    _resenas = _resenaService.obtenerResenas(widget.receta.id);
  }

  void _recargarResenas() {
    setState(() {
      _resenas = _resenaService.obtenerResenas(widget.receta.id);
    });
  }

Future<void> _agregarResena() async {
  final datos = await showDialog<Map<String, String>>(
    context: context,
    builder: (_) => const _FormularioResena(),
  );

  if (!mounted || datos == null) return;

  try {
    await _resenaService.agregarResena(
      Resena(
        recetaId: widget.receta.id,
        nombre: datos['nombre']!,
        comentario: datos['comentario']!,
      ),
    );

    if (!mounted) return;

    _recargarResenas();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reseña guardada')),
    );
  } catch (error) {
    debugPrint('Error al guardar reseña: $error');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo guardar la reseña'),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;
    return Scaffold(
      appBar: AppBar(title: Text("Detalle de la receta")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(14),
            child: Image.network(
              receta.imagenUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Image.asset(
                "assets/images/placto-placeholder.jpg",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [
              Chip(label: Text('${receta.tiempoTotal} min')),
              Chip(label: Text("receta.dificultad")),
              Chip(label: Text(receta.cocina)),
              Chip(label: Text('${receta.calorias} kcal')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Ingredientes: ",
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.ingredientes.map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.orange),
                  const SizedBox(height: 8),
                  Expanded(child: Text(ingrediente)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Preparacion: ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.instrucciones.asMap().entries.map(
            (entrada) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      '${entrada.key + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entrada.value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Mis reseñas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _agregarResena,
            icon: const Icon(Icons.rate_review),
            label: const Text('Agregar reseña'),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Resena>>(
            future: _resenas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('No se pudieron cargar las reseñas');
              }
              final resenas = snapshot.data ?? [];
              if (resenas.isEmpty) {
                return const Text(
                  'Todavia no has escrito reseñas de esta receta',
                );
              }
              return Column(
                children: resenas.map((resena) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        resena.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(resena.comentario),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FormularioResena extends StatefulWidget {
  const _FormularioResena();
  @override
  State<_FormularioResena> createState() => _FormularioResenaState();
}

class _FormularioResenaState extends State<_FormularioResena> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _nombreController = TextEditingController();
  @override
  @override
  void dispose() {
    _controller.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar reseña'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Escribe tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Tu opinión',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Escribe una reseña';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'nombre': _nombreController.text.trim(),
                'comentario': _controller.text.trim(),
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
