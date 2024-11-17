import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RecyclingCentersScreen extends StatefulWidget {
  @override
  _RecyclingCentersScreenState createState() => _RecyclingCentersScreenState();
}

class _RecyclingCentersScreenState extends State<RecyclingCentersScreen> {
  List<Map<String, dynamic>> recyclingCenters = [];
  final String googleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  bool _isLoading = true;
  bool _hasError = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _verificarPermisos();
  }

  Future<void> _verificarPermisos() async {
    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.deniedForever) {
      _mostrarDialogoPermisoDenegado();
    } else if (permiso == LocationPermission.whileInUse || permiso == LocationPermission.always) {
      await _checkConnectivityAndGetCenters();
    }
  }

  Future<void> _checkConnectivityAndGetCenters() async {
    bool isConnected = await _checkInternetConnection();
    if (!isConnected) {
      setState(() {
        _isLoading = false;
        _isOffline = true;
        _hasError = true;
      });
      return;
    }

    await _obtenerCentrosReciclajeCercanos();
  }

  Future<void> _obtenerCentrosReciclajeCercanos() async {
    try {
      final posicion = await Geolocator.getCurrentPosition();
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${posicion.latitude},${posicion.longitude}&radius=5000&type=point_of_interest&keyword=recycling&key=$googleApiKey');
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        setState(() {
          recyclingCenters = List<Map<String, dynamic>>.from(datos['results']);
          _isLoading = false;
          _hasError = false;
          _isOffline = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _isOffline = false;
        });
        print('Error al obtener los centros de reciclaje: ${respuesta.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _isOffline = false;
      });
      print('Error al obtener la ubicación: $e');
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _mostrarDialogoPermisoDenegado() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permiso de ubicación denegado'),
          content: Text('La aplicación necesita permisos de ubicación para funcionar correctamente. Por favor, habilita los permisos en la configuración del dispositivo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Centros de Reciclaje Cercanos'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.green[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOffline ? Icons.wifi_off : Icons.error_outline,
                  size: 48,
                  color: Colors.red[400],
                ),
                SizedBox(height: 16),
                Text(
                  _isOffline
                      ? "Sin conexión a Internet"
                      : "Error al obtener los centros de reciclaje",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _isOffline
                      ? "Verifica tu conexión"
                      : "Intenta de nuevo más tarde",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _checkConnectivityAndGetCenters,
                  icon: Icon(Icons.refresh),
                  label: Text("Reintentar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: recyclingCenters.length,
            itemBuilder: (context, index) {
              final centro = recyclingCenters[index];
              return Card(
                elevation: 2, // Elevación aplicada aquí
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(Icons.location_on, color: Colors.green[700]),
                  title: Text(
                    centro['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  subtitle: Text(
                    centro['vicinity'] ?? 'Dirección no disponible',
                    style: TextStyle(
                      color: Colors.green[600],
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
