import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:govoltfrontend/models/rutas.dart';
import 'package:govoltfrontend/pages/rutas/route_card.dart';
import 'package:govoltfrontend/services/rutas_service.dart';

class RoutesScreen extends StatefulWidget {
  RoutesScreen();

  @override
  State<StatefulWidget> createState() => _RoutesState();
}

TextField printSearchBar() {
  return TextField(
    decoration: const InputDecoration(
        hintText: 'Busca tu trayecto ...', prefixIcon: Icon(Icons.search)),
    onChanged: (value) {
      value = value;
    },
  );
}

class _RoutesState extends State<RoutesScreen> {
  int _selectedIndex = 0; // Estado para controlar el botón seleccionado
  final RutaService rutaService = RutaService(); // Instancia del servicio
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if (_selectedIndex == 1) ...{
            _buildSearchBar(),
            _buildRouteCards(),
          } else ...{
            // cosas de ruben :)
            _buildCalendar()
          }
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        color: const Color.fromRGBO(125, 193, 165, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: _buildBottomButton(
                text: 'My Routes',
                selected: _selectedIndex == 0,
              ),
            ),
            _buildCircleButton(
              onPressed: () {
                // cosas de pol :)
              },
              icon: Icons.add_circle_outline_outlined,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: _buildBottomButton(
                text: 'Search Routes',
                selected: _selectedIndex == 1,
              ),
            ),
          ],
        ),
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
          SizedBox(
              width:
                  8), // Espacio entre la barra de búsqueda y el botón de filtro
          ElevatedButton(
            onPressed: () {
              // Lógica para el botón de filtro
              // Puedes abrir un cuadro de diálogo, mostrar opciones, etc.
            },
            style: ElevatedButton.styleFrom(
                fixedSize: Size.fromHeight(50),
                backgroundColor: Color(0xff4d5e6b)),
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCards() {
    return Expanded(
      child: FutureBuilder<List<Ruta>>(
        future: rutaService.getAllRutas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron rutas.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _buildRouteCard(ruta: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildRouteCard({required Ruta ruta}) {
    return RouteCard(ruta: ruta);
  }

  Widget _buildBottomButton({required String text, required bool selected}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 4,
            color: selected
                ? Color(0xff4d5e6b)
                : const Color.fromARGB(0, 255, 255, 255),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Color(0xff4d5e6b) : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      {required VoidCallback onPressed, required IconData icon}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        fixedSize: Size.square(50),
        backgroundColor: const Color(0xff4d5e6b), // Cambiar el color del botón
      ),
      child: Container(
        width: 50,
        height: 50,
        child: Center(
          child: Icon(
            icon,
            size: 40,
            color: Colors.white, // Cambiar el color del ícono a blanco
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
        ),
      ],
    );
  }
}
