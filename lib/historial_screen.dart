import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:proyectofinal/history_item_card.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<HistoryItem> _historialItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  Future<void> _loadHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = prefs.getStringList('historial') ?? [];
      debugPrint('Elementos encontrados en SharedPreferences: ${items.length}');

      final List<HistoryItem> loadedItems = [];
      for (var item in items) {
        try {
          final decoded = jsonDecode(item);
          debugPrint('Decodificando item: $decoded'); // Para debugging
          loadedItems.add(HistoryItem.fromJson(decoded));
        } catch (e) {
          debugPrint('Error decodificando item: $e');
        }
      }

      setState(() {
        _historialItems = loadedItems.reversed.toList();
      });

      debugPrint('Elementos cargados en _historialItems: ${_historialItems.length}');
    } catch (e) {
      debugPrint('Error cargando historial: $e');
    }
  }

  Future<void> _removeItem(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _historialItems.removeAt(index);
      });

      final updatedList = _historialItems
          .reversed
          .map((item) => jsonEncode(item.toJson()))
          .toList();

      await prefs.setStringList('historial', updatedList);
    } catch (e) {
      debugPrint('Error eliminando item: $e');
    }
  }

  Future<void> _clearHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _historialItems.clear();
      });
      await prefs.setStringList('historial', []);
    } catch (e) {
      debugPrint('Error limpiando historial: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Reciclaje'),
        backgroundColor: Colors.green,
        actions: [
          if (_historialItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: () => _showClearHistorialDialog(),
            ),
        ],
      ),
      body: _historialItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay elementos en el historial',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _historialItems.length,
        itemBuilder: (context, index) {
          return HistoryItemCard(
            item: _historialItems[index],
            onDelete: () => _removeItem(index),
          );
        },
      ),
    );
  }

  void _showClearHistorialDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Limpiar historial'),
          content: Text('¿Estás seguro de que quieres eliminar todo el historial?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Eliminar'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                _clearHistorial();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}