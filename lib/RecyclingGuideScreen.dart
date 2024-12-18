import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyectofinal/history_item_card.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RecyclingGuideScreen extends StatefulWidget {
  final File image;

  RecyclingGuideScreen({required this.image});

  @override
  _RecyclingGuideScreenState createState() => _RecyclingGuideScreenState();
}

class _RecyclingGuideScreenState extends State<RecyclingGuideScreen> {
  String _recyclingInfo = "Procesando imagen...";
  bool _isLoading = true;
  bool _hasError = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnectivityAndAnalyze();
    });
  }

  Future<void> _checkConnectivityAndAnalyze() async {
    if (await _checkInternetConnection()) {
      _analyzeImage();
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _isOffline = true;
        _recyclingInfo = 'Sin conexión a Internet';
      });
    }
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isOffline = false;
      _recyclingInfo = '';  // Limpiar cualquier dato previo
    });

    bool isConnected = await _checkInternetConnection();
    if (!isConnected) {
      setState(() {
        _isLoading = false;
        _isOffline = true;
        _recyclingInfo = 'Sin conexión a Internet. Verifica tu conexión.';
      });
      return;
    }

    try {
      Uint8List imageBytes = await compute(_convertImageToBytes, widget.image);

      String geminiResponse = await _getGeminiResponse(imageBytes);

      final historyItem = HistoryItem(
        imagePath: widget.image.path,
        recyclingInfo: geminiResponse,
        timestamp: DateTime.now(),
      );

      await _saveToHistorial(historyItem);

      if (mounted) {
        setState(() {
          _recyclingInfo = geminiResponse;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _recyclingInfo = 'Error al procesar la imagen. Intenta de nuevo.';
      });
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

  Future<void> _saveToHistorial(HistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historial = prefs.getStringList('historial') ?? [];
      String itemJson = jsonEncode(item.toJson());
      historial.add(itemJson);

      await prefs.setStringList('historial', historial);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar en el historial. Por favor, intente nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Uint8List _convertImageToBytes(File image) {
    return image.readAsBytesSync();
  }

  Future<String> _getGeminiResponse(Uint8List imageBytes) async {
    final gemini = Gemini.instance;
    String prompt = """
Eres EcoScan AI, un asistente especializado en reciclaje que ayuda a las personas a identificar y reciclar correctamente sus residuos. Por favor, analiza la imagen y proporciona una respuesta estructurada en español con la siguiente información también tienes PROHIBIDO usar negritas y ten cuidado con usar espacios o saltos de líneas de más:

**1. IDENTIFICACIÓN:**
- Describe con precisión qué objeto(s) observas en la imagen.
- Menciona el material principal del que está hecho (plástico, papel, vidrio, etc.).

**2. CLASIFICACIÓN:**
- Especifica si es un residuo **ORGÁNICO** o **INORGÁNICO**.
- Si es inorgánico, indica su subclasificación (reciclable, no reciclable).
- Menciona el color de contenedor apropiado para este residuo.

**3. GUÍA DE RECICLAJE:**
- Paso 1: Indica si requiere alguna preparación previa (limpieza, separación, etc.).
- Paso 2: Explica el proceso correcto de disposición.
- Paso 3: Menciona cualquier consideración especial.

**4. IMPACTO AMBIENTAL:**
- Comparte un dato interesante sobre el impacto de reciclar este tipo de residuo.
- Sugiere una alternativa sostenible si existe.

Por favor, mantén un tono amigable y educativo. Usa frases cortas y claras. Si no puedes identificar claramente el objeto o tienes dudas, indícalo honestamente.

**Ejemplo de respuesta esperada:**
"¡He identificado una botella de plástico PET!

Es un residuo **INORGÁNICO reciclable** que va en el contenedor **amarillo**.

Para reciclarlo correctamente:
1. Enjuaga la botella para eliminar residuos.
2. Retira la etiqueta si es posible.
3. Aplasta la botella para reducir su volumen.
4. Deposítala en el contenedor amarillo.

¡Dato interesante! Reciclar una botella de plástico ahorra suficiente energía para mantener encendida una bombilla LED durante 3 horas.

Consejo: Considera usar una botella reutilizable para reducir el consumo de plásticos de un solo uso."
""";

    try {
      final response = await gemini.textAndImage(
        text: prompt,
        images: [imageBytes],
      );

      if (response == null || response.content == null || response.content!.parts == null || response.content!.parts!.isEmpty) {
        throw Exception('Respuesta inválida de Gemini');
      }

      final responseText = response.content!.parts!.last.text ?? 'No se pudo obtener una respuesta válida';

      return responseText.isNotEmpty ? responseText : 'La respuesta está vacía. Por favor, intenta de nuevo.';
    } catch (e) {
      return 'No se pudo analizar la imagen. Error: ${e.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade700,
                Colors.green.shade500,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 6.0,
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.recycling,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              "Guía de Reciclaje",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[100]!, Colors.green[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green[400]!, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                        ),
                        child: Image.file(widget.image),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_isLoading)
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(),
                      )
                    else if (_hasError)
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _recyclingInfo,
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          _recyclingInfo,
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
