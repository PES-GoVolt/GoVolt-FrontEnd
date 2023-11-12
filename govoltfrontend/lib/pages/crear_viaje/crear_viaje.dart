import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

// ... (previous imports)

class CrearViajeScreen extends StatefulWidget {
  @override
  _CrearViajeScreenState createState() => _CrearViajeScreenState();
}

class _CrearViajeScreenState extends State<CrearViajeScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creación de Viaje'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormBuilderTextField(
                  name: 'ciudadInicial',
                  decoration: InputDecoration(labelText: 'Ciudad Inicio'),
                ),
                SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'ciudadLlegada',
                  decoration: InputDecoration(labelText: 'Ciudad Fin'),
                ),
                SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'numPlazasDisponibles',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Plazas Disponibles'),
                ),
                SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'precio',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Precio (Euros)'),
                ),
                SizedBox(height: 16.0),
                FormBuilderDateTimePicker(
                  name: 'fecha',
                  inputType: InputType.date,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                FormBuilderDateTimePicker(
                  name: 'hora',
                  inputType: InputType.time,
                  decoration: InputDecoration(
                    labelText: 'Hora',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onChanged: (time) {
                    setState(() {
                      final dateString = time as DateTime;
                      _selectedTime = TimeOfDay.fromDateTime(time);
                    });
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      // Form data is valid, handle submission
                      var formData = _formKey.currentState?.value;
                      print(formData);
                      // Add your logic to handle the form submission
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Crear Viaje',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
