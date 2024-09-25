import 'package:flutter/material.dart';

void main() {
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
      backgroundColor: Colors.green, // Fondo verde
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0), // Espacio en la parte superior
            child: Align(
              alignment: Alignment.topCenter, // Alineación en la parte superior y centrado
              child: Text(
                'Reciclaje',
                style: TextStyle(
                  fontSize: 40, // Tamaño del texto
                  fontWeight: FontWeight.bold, // Texto en negrita
                  color: Colors.white, // Color del texto
                ),
              ),
            ),
          ),
          Spacer(), // Espacio entre el título y los botones
          ElevatedButton(
            onPressed: () {
              // Acción cuando se presiona "Tomar foto"
            },
            child: Text('Tomar foto'),
          ),
          SizedBox(height: 20), // Espacio entre los botones
          ElevatedButton(
            onPressed: () {
              // Acción cuando se presiona "Historial de basura escaneada"
            },
            child: Text('Historial de basura escaneada'),
          ),
          Spacer(), // Espacio debajo de los botones
        ],
      ),
    );
  }
}
