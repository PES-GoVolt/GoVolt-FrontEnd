import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
    DateTime _selectedDay = DateTime(0);
    DateTime _focusedDay = DateTime.now();
    CalendarFormat _calendarFormat = CalendarFormat.month;
    List<DateTime> _events = [];
    List<Ruta> combinedRutas=[];
    List<Ruta> filteredRutas=[];

  @override
  void initState() {
    super.initState();
    _loadRoutes();
    _loadMyRutas();
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
            _buildCalendar(),
            _buildMyRouteCards(),
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

  Future<void> _loadMyRutas() async {
    // Tu lógica para cargar las rutas combinadas
    List<Ruta> combinedRutas = await _loadCombinedRutas();

    setState(() {
      // Inicializar la lista de fechas
      List<DateTime> dateList = [];

      combinedRutas.forEach((ruta) {
        List<int> dateParts = ruta.date.split('-').map(int.parse).toList();
        DateTime date = DateTime(dateParts[0], dateParts[1], dateParts[2]);

        // Agregar la fecha a la lista si no está presente
        if (!dateList.contains(date)) {
          dateList.add(date);
        }
      });

      // Asignar la lista de fechas a la variable _events
      _events = dateList;
    });
  }
Future<List<Ruta>> _filterRutas() async {

    filteredRutas = combinedRutas
        .where((ruta) =>
            _selectedDay.isAtSameMomentAs(DateTime(0)) ||
            DateTime.parse(ruta.date).isAtSameMomentAs(_selectedDay) ||
            (DateTime.parse(ruta.date).year == _selectedDay.year &&
                DateTime.parse(ruta.date).month == _selectedDay.month &&
                DateTime.parse(ruta.date).day == _selectedDay.day))
        .toList();

    return filteredRutas;
  }

  Future<List<Ruta>> _loadCombinedRutas() async {
    List<Ruta> myRutas = await rutaService.getMyRutas();
    List<Ruta> partRutas = await rutaService.getPartRutas();

    combinedRutas = [...myRutas, ...partRutas];


    return combinedRutas;
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

    Widget _buildMyRouteCards() {
        return Expanded(
          child: FutureBuilder<List<Ruta>>(
            future: _filterRutas(),
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
    return RouteCard(ruta: ruta ,showJoin: _selectedIndex==1);
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

  Widget _buildCalendar() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2029, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              if (isSameDay(_selectedDay, selectedDay)) {
                _selectedDay = DateTime(0);
                _focusedDay = DateTime(0);
              } else {
                _selectedDay = selectedDay;
              }
              _focusedDay = focusedDay;
            });
            print(_selectedDay);
          },
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (_events.any((eventDate) =>
                  eventDate.year == date.year &&
                  eventDate.month == date.month &&
                  eventDate.day == date.day)) {
                bool isSelectedDay = isSameDay(_selectedDay, date);
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: isSelectedDay
                        ? Colors.blue
                        : const Color.fromRGBO(125, 193, 165, 1),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              } else {
                // Devuelve un contenedor vacío si no necesitas marcar esta fecha
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}
