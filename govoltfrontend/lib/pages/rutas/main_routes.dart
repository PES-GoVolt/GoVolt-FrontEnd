import 'package:flutter/material.dart';
import 'package:govoltfrontend/pages/rutas/crear_viaje/create_route.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:govoltfrontend/models/rutas.dart';
import 'package:govoltfrontend/pages/rutas/route_card.dart';
import 'package:govoltfrontend/services/rutas_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RoutesState();
}

TextField printSearchBar(Function(String) onSearch) {
  String query = '';
  return TextField(
    decoration: InputDecoration(
      //hintText: AppLocalizations.of(context)!.searchYourRoute,    ESTA NO VA?????????????????
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
    List<Ruta> myRutas=[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
                  Text(
                    AppLocalizations.of(context)!.price,
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
                    activeColor: Color.fromRGBO(125, 193, 165, 1),
                    onChanged: (double value) {
                      setState(() {
                        _currentPriceFilter = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    AppLocalizations.of(context)!.date,
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
                              : AppLocalizations.of(context)!.dateSelect,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4d5e6b),
                        ),
                        child: Text(AppLocalizations.of(context)!.apply, style: TextStyle(color: Colors.white),),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          filterRoutes(query);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4d5e6b),
                        ),
                        child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.white),),
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
                  _loadData();
                  _selectedIndex = 0;
                });
              },
              child: _buildBottomButton(
                text: AppLocalizations.of(context)!.myRoutes, //myRoutes
                selected: _selectedIndex == 0,
              ),
            ),
            _buildCircleButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => CrearViajeScreen()))
                .then((value) {
                  _loadRoutes();
                  setState(() {
                    _selectedIndex = 1; 
                  });
                });
              },
              icon: Icons.add_circle_outline_outlined,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _loadData();
                  _selectedIndex = 1;
                });
              },
              child: _buildBottomButton(
                text: AppLocalizations.of(context)!.searchRoutes,
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
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchYourRoute,
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
            child: const Icon(Icons.filter_list, color: Colors.white,),
          ),
        ],
      ),
    );
  }

  Future<void> _loadMyRutas() async {
    myRutas = await _loadMyCreatedRutas();
    List<Ruta> partRutas = await _loadMyPartRutas();
    combinedRutas = await _loadAllMyRutas(myRutas, partRutas);

    setState(() {
      List<DateTime> dateList = [];

      combinedRutas.forEach((ruta) {
        List<int> dateParts = ruta.date.split('-').map(int.parse).toList();
        DateTime date = DateTime(dateParts[0], dateParts[1], dateParts[2]);

        if (!dateList.contains(date)) {
          dateList.add(date);
        }
      });

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

  Future<List<Ruta>> _loadAllMyRutas(myRutas, partRutas) async {
    combinedRutas = [...myRutas, ...partRutas];
    return combinedRutas;
  }

  Future<List<Ruta>> _loadMyCreatedRutas() async {
    List<Ruta> myRutas = await rutaService.getMyRutas();
    return myRutas;
    
  }

  Future<List<Ruta>> _loadMyPartRutas() async {
    List<Ruta> partRutas = await rutaService.getPartRutas();
    return partRutas;
    
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
                return Center(child: Text(AppLocalizations.of(context)!.noRoutes));
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
    final bool showCancel = _selectedIndex == 0 && myRutas.contains(ruta);
    return RouteCard(ruta: ruta, showJoin: _selectedIndex == 1, showCancel: showCancel);
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
        backgroundColor: const Color(0xff4d5e6b),
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
              color: Color(0xff4d5e6b),
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
                        ? const Color(0xff4d5e6b)
                        : const Color.fromRGBO(125, 193, 165, 1),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}
