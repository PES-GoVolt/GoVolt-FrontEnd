import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/services/create_route_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class CrearViajeScreen extends StatefulWidget {
  @override
  _CrearViajeScreenState createState() => _CrearViajeScreenState();
}

class _CrearViajeScreenState extends State<CrearViajeScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  DateTime? _selectedDate;
  //TimeOfDay? _selectedTime;
  final applicationBloc = AplicationBloc();
  List<PlaceSearch>? searchResults;
  String? _ubicacionInicial;

  void valueChanged(var value) async {
    //await applicationBloc.searchCities(value);
    searchResults = applicationBloc.searchResults;
    setState(() {});
  }

  Widget customSearchBar() {
    return TextField(
      decoration:  InputDecoration(
        hintText: AppLocalizations.of(context)!.searchYourRoute,
      ),
      onChanged: (value) {
        valueChanged(value);
      },
    );
  }

  Widget hiddenFormField() {
    return TextFormField(
      initialValue: _ubicacionInicial,
      style: const TextStyle(color: Colors.transparent),
      decoration: const InputDecoration.collapsed(
        hintText: '',
      ),
    );
  }

  ListView printListView() {
    return ListView.builder(
      key: UniqueKey(),
      itemCount: searchResults?.length ?? 0,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            FocusScope.of(context).unfocus();
            print(applicationBloc.searchResults?[index].description);

            setState(() {
              _ubicacionInicial = applicationBloc.searchResults![index].description;
              searchResults?.clear();
            });
          },
          title: Text(
            applicationBloc.searchResults![index].description,
            style: const TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.routeCreation),
        backgroundColor: const Color.fromRGBO(125, 193, 165, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /*
                BARRA DE BUSQUEDA BUENA
                customSearchBar(),
                if (applicationBloc.searchResults != null &&
                    searchResults!.isNotEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: printListView(),
                  ),
                  */
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'ubicacion_inicial',
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.initialCity),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'ubicacion_final',
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.finalCity),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'precio',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration:  InputDecoration(labelText: AppLocalizations.of(context)!.price),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric()
                  ]),        
                ),
                const SizedBox(height: 16.0),
                FormBuilderTextField(
                  name: 'num_plazas',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.seatsAvailable),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric()
                  ]),
                ),
                const SizedBox(height: 16.0),
                FormBuilderDateTimePicker(
                  name: 'fecha',
                  inputType: InputType.date,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.date,
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onChanged: (dateTime) {
                    setState(() {
                      _selectedDate = dateTime;
                      /*
                      POR SI QUEREMOS PONER HORA AL CREAR
                      if (_selectedTime != null) {
                        _selectedDate = DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute,
                        );
                      }
                      */
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false ) {
                      var formData = Map<String, dynamic>.from(_formKey.currentState!.value);
                      formData['fecha'] = (_selectedDate != null) ? _selectedDate!.toString().split(' ')[0] : null;
                      await CreateRoutesService.createRuta(formData);
                      Navigator.of(context).pop();
                    }
                    
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color(0xff4d5e6b)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      AppLocalizations.of(context)!.createRoute,
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
