import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'camera_screen.dart'; // Importa el archivo de la cámara
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  await dotenv.load();
  print("API Key: ${dotenv.env['GOOGLE_CLOUD_API_KEY']}"); // Verifica que la clave se cargue correctamente
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);
  runApp(ReciclajeApp());
}

class ReciclajeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InicioScreen(),
    );
  }
}

class InicioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Reciclaje',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraScreen()),
              );
            },
            child: Text('Tomar foto'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Acción para el historial de basura escaneada
            },
            child: Text('Historial de basura escaneada'),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
