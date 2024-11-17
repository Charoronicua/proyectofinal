import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'camera_screen.dart';
import 'package:proyectofinal/historial_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:proyectofinal/RecyclingCentersScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    dotenv.load(),
    SharedPreferences.getInstance(),
  ]);


  String? apiKey = dotenv.env['GEMINI_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('Error: API key not found.');
  } else {
    // Inicializar Gemini con la API Key
    Gemini.init(apiKey: apiKey);
    print("API Key: $apiKey");
  }

  runApp(ReciclajeApp());
}

class ReciclajeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      home: InicioScreen(),
    );
  }
}

class InicioScreen extends StatefulWidget {
  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _historialCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHistorialCount();
  }

  Future<void> _loadHistorialCount() async {
    final prefs = await SharedPreferences.getInstance();
    final historial = prefs.getStringList('historial') ?? [];
    setState(() {
      _historialCount = historial.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade700,
              Colors.green.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Patrón de fondo
              Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundPatternPainter(),
                ),
              ),
              // Contenido principal
              Center(  // Centramos todo el contenido
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,  // Importante: solo ocupa el espacio necesario
                      children: [
                        SizedBox(height: 20),
                        // Logo y título
                        _buildHeader(),
                        SizedBox(height: 40),
                        // Tarjeta principal
                        _buildMainCard(),
                        SizedBox(height: 30),
                        // Botones de acción
                        _buildActionButtons(context),
                        // Stats solo si hay elementos en el historial
                        if (_historialCount > 0) ...[
                          SizedBox(height: 30),
                          _buildStats(),
                        ],
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.recycling,
            size: 60,
            color: Colors.green.shade700,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'EcoScan',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        Text(
          'Tu guía de reciclaje inteligente',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.camera_enhance,
            size: 48,
            color: Colors.green.shade700,
          ),
          SizedBox(height: 16),
          Text(
            '¿Qué deseas reciclar hoy?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Toma una foto de tus residuos y obtén recomendaciones instantáneas de reciclaje',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.camera_alt, color: Colors.white),
          label: Text(
            'Escanear Residuo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            minimumSize: Size(double.infinity, 56),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
            _loadHistorialCount();
          },
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.history, color: Colors.white),
          label: Text(
            'Ver Historial ($_historialCount)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            minimumSize: Size(double.infinity, 56),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistorialScreen()),
            );
            _loadHistorialCount();
          },
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.location_on, color: Colors.white),
          label: Text(
            'Ver Centros de Reciclaje',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            minimumSize: Size(double.infinity, 56),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecyclingCentersScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            'Tu Actividad',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.camera_alt,
                value: _historialCount.toString(),
                label: 'Escaneos Totales',
              ),
              _buildStatItem(
                icon: Icons.auto_awesome,
                value: (_historialCount > 0) ? 'Nivel ${((_historialCount / 5).floor() + 1)}' : 'Nivel 1',
                label: 'Experiencia',
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            '¡Continúa escaneando para subir de nivel!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green.shade100.withOpacity(0.4);
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 4, size.height - 100, size.width / 2, size.height)
      ..quadraticBezierTo(size.width * 3 / 4, size.height + 100, size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}