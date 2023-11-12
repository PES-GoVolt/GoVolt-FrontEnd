import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/rutas.dart';

import 'route_card.dart';

class RoutesScreen extends StatefulWidget {
  RoutesScreen();

  @override
  State<StatefulWidget> createState() => _RoutesState();
}


TextField printSearchBar() {
    return TextField(
      decoration: const InputDecoration(
          hintText: 'Busca tu trayecto ...',
          prefixIcon: Icon(Icons.search)),
      onChanged: (value) {
        value = value;
      },
    );
  }

class _RoutesState extends State<RoutesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildSearchBar(),
          _buildRouteCards(),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: printSearchBar(),
          ),
          SizedBox(width: 8), // Espacio entre la barra de búsqueda y el botón de filtro
          ElevatedButton(
            onPressed: () {
              // Lógica para el botón de filtro
              // Puedes abrir un cuadro de diálogo, mostrar opciones, etc.
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromHeight(50),
            ),
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCards() {
  return Expanded(
    child: ListView(
      children: [
        _buildRouteCard(
          ruta: Ruta(
            id: '1',
            inicio: 'Barcelona',
            destino: 'Gava',
            creador: 'Paula',
            fecha: DateTime(2023, 11, 10),
            tiempoAproximado: 30,
            precio: 10.5,
          ),
        ),
        _buildRouteCard(
          ruta: Ruta(
            id: '2',
            inicio: 'Barcelona',
            destino: 'Gava',
            creador: 'Paula',
            fecha: DateTime(2023, 11, 10),
            tiempoAproximado: 30,
            precio: 10.5,
          ),
        ),
        // Agrega más instancias de Ruta según sea necesario
      ],
    ),
  );
}

  Widget _buildRouteCard({required Ruta ruta}) {
  return RouteCard(ruta: ruta);
}

  Widget _buildBottomButtons() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color.fromRGBO(125, 193, 165, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomButton(
            onPressed: () {
              // Lógica para el botón My Routes
            },
            text: 'My Routes',
          ),
          _buildCircleButton(
            onPressed: () {
              // Lógica para el botón con símbolo '+'
            },
            text: '+',
          ),
          _buildBottomButton(
            onPressed: () {
              // Lógica para el botón Search Routes
            },
            text: 'Search Routes',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({required VoidCallback onPressed, required String text}) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: Size.fromHeight(50),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildCircleButton({required VoidCallback onPressed, required String text}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        fixedSize: Size.square(50),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
    );
  }
}


