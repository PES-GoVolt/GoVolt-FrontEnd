import 'package:govoltfrontend/models/route.dart';

class RouteVoltList {
  List<RouteVolt> routeList = [];
  RouteVolt carRoute = RouteVolt();
  RouteVolt bicycleRoute = RouteVolt();
  RouteVolt walkingRoute = RouteVolt();
  RouteVolt tempRouteToCharger = RouteVolt();
  int i = 0;

  RouteVoltList() {
    routeList = [carRoute, bicycleRoute, walkingRoute, tempRouteToCharger];
  }

  void clearData()
  {
    carRoute.clearData();
    bicycleRoute.clearData();
    walkingRoute.clearData();
    tempRouteToCharger.clearData();
    i =0;
  }

  int getDistance()
  {
    return routeList[i].distance;
  }

  String getTime()
  {
    return routeList[i].time;
  }

}
