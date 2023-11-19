import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/rutas.dart';
import 'package:govoltfrontend/pages/rutas/route_card.dart';
import 'package:govoltfrontend/services/rutas_service.dart';


class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RoutesState();
}

TextField printSearchBar(Function(String) onSearch) {
  String query = '';

  return TextField(
    decoration: const InputDecoration(
      hintText: 'Busca tu trayecto ...',
      prefixIcon: Icon(Icons.search),
    ),
    onChanged: (value) {
      query = value;
      onSearch(query); 
    },
  );
}

class _RoutesState extends State<RoutesScreen> {
  int _selectedIndex = 0; 
  final RutaService rutaService = RutaService(); 
  List<Ruta> _routes = []; 
  List<Ruta> filteredRoutes = []; 
  String query = '';
  DateTime? _selectedDateFilter; 
  double _currentPriceFilter = 50.0;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final List<Ruta> fetchedRoutes = await rutaService.getAllRutas();
    setState(() {
      _routes = fetchedRoutes;
      filteredRoutes = List.from(_routes); 
    });
  }

  void filterRoutes(String query, {DateTime? selectedDateFilter, double? selectedPriceFilter}) {
  setState(() {
    if (query.isNotEmpty || selectedDateFilter != null || selectedPriceFilter != null) {
      filteredRoutes = _routes.where((ruta) {
        bool matchesQuery = query.isEmpty ||
            ruta.beginning.toLowerCase().contains(query.toLowerCase()) ||
            ruta.destination.toLowerCase().contains(query.toLowerCase());

        bool matchesDateFilter = selectedDateFilter == null ||
            (ruta.date ==
                "${selectedDateFilter.year}-${selectedDateFilter.month}-${selectedDateFilter.day}");

        bool matchesPriceFilter = selectedPriceFilter == null ||
            double.parse(ruta.price) <= selectedPriceFilter; 

        return matchesQuery && matchesDateFilter && matchesPriceFilter;
      }).toList();
    } else {
      filteredRoutes = List.from(_routes);
    }
  });
}

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20.0),
                  const Text(
                    'Precio',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '0€ - ${_currentPriceFilter.round().toString()}€',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10.0),
                  Slider(
                    value: _currentPriceFilter,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '${_currentPriceFilter.round().toString()}€',
                    onChanged: (double value) {
                      setState(() {
                        _currentPriceFilter = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Fecha',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 10.0),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateFilter ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _selectedDateFilter) {
                        setState(() {
                          _selectedDateFilter = picked;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _selectedDateFilter != null
                              ? "${_selectedDateFilter!.year}-${_selectedDateFilter!.month}-${_selectedDateFilter!.day}"
                              : 'Selecciona una fecha',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          filterRoutes(query, selectedDateFilter: _selectedDateFilter, selectedPriceFilter: _currentPriceFilter);
                          Navigator.pop(context);
                        },
                        child: const Text('Aplicar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          filterRoutes(query); 
                          Navigator.pop(context); 
                        },
                        child: const Text('Quitar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if(_selectedIndex == 1)...{
            _buildSearchBar(filterRoutes),
            _buildRouteCards(),   
          }
          else...{
            // cosas de ruben :)
          }
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildSearchBar(Function(String) onSearch) {
    String query = '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Busca tu trayecto ...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                query = value;
                onSearch(query); 
              },
            ),
          ),
          const SizedBox(width: 8), 
          ElevatedButton(
            onPressed: () {
              _showFilterOptions(context);
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromHeight(50),
              backgroundColor: const Color(0xff4d5e6b),
            ),
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCards() {
    return Expanded(
      child: ListView.builder(
        itemCount: filteredRoutes.length,
        itemBuilder: (context, index) {
          return _buildRouteCard(ruta: filteredRoutes[index]);
        },
      ),
    );
  }

  Widget _buildRouteCard({required Ruta ruta}) {
    return RouteCard(ruta: ruta);
  }

  Widget _buildBottomButton({required String text, required bool selected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 4,
            color: selected ? const Color(0xff4d5e6b) : const Color.fromARGB(0, 255, 255, 255), 
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? const Color(0xff4d5e6b) : Colors.white, 
          fontWeight: selected ? FontWeight.bold : FontWeight.normal, 
        ),
      ),
    );
  }

  Widget _buildCircleButton({required VoidCallback onPressed, required IconData icon}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        fixedSize: const Size.square(50),
        backgroundColor: const Color(0xff4d5e6b), // Cambiar el color del botón
      ),
      child: const SizedBox(
        width: 50,
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "+",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
