import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // Importa la librería de Gemini

class RecyclingGuideScreen extends StatefulWidget {
  final File image;

  RecyclingGuideScreen({required this.image});

  @override
  _RecyclingGuideScreenState createState() => _RecyclingGuideScreenState();
}

class _RecyclingGuideScreenState extends State<RecyclingGuideScreen> {
  String _recyclingInfo = "Procesando imagen...";

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    // Crear el prompt con el texto que deseas enviar a Gemini junto con la imagen
    String prompt = "Clasifica la basura en la imagen y da consejos de reciclaje.";

    // Llamar a la API de Gemini para analizar la imagen y generar una respuesta
    String geminiResponse = await getGeminiResponse(prompt);

    // Actualizar la UI con la información de reciclaje
    setState(() {
      _recyclingInfo = geminiResponse;
    });
  }

  Future<String> getGeminiResponse(String prompt) async {
    // Usar el cliente Gemini
    final gemini = Gemini.instance; // Usamos el cliente estático de Gemini

    try {
      // Enviar la imagen y el texto a Gemini
      final response = await gemini.textAndImage(
        text: prompt, // El texto que acompaña la imagen
        images: [widget.image.readAsBytesSync()], // Convierte la imagen a bytes y la envía
      );

      // Recuperar la respuesta generada por Gemini
      return response?.content?.parts?.last.text ?? 'No se pudo generar una respuesta.';
    } catch (e) {
      return 'Error al obtener respuesta de Gemini: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Guía de Reciclaje"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Envuelve el Column con un SingleChildScrollView
          child: Column(
            children: [
              Image.file(widget.image), // Muestra la imagen seleccionada
              SizedBox(height: 20),
              Text(
                _recyclingInfo, // Muestra la información de reciclaje
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
