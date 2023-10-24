import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:stemmweather/model/currentWeatherModel.dart';

import '../model/forcastModel.dart';
import '../utils/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeneralController extends ChangeNotifier {
  bool isLocationPermission = false;
  String lat = "0.0";
  String long = "0.0";
  String slat = "0.0";
  String slong = "0.0";
  String apiKey = "c354ed1c31f569b6142df176fbc506b1";
  bool cLoading = false;
  bool sLoading = false;
  bool isLoading = false;
  bool isLatLongSelected = false;
  bool showMap = false;
  CurrentWeatherModel? currentWeatherModel;
  List<ForcastList> forcastList = [];
  List<ForcastList> sforcastList = [];
  Set<Marker> markers = {};
  bool isInternet = true;
  late StreamSubscription<ConnectivityResult> subscription;
  final Connectivity _connectivity = Connectivity();

  checkInternet() {
    subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isInternet = false;
        notifyListeners();
      } else {
        isInternet = true;
        notifyListeners();
      }
    });
  }

  checkPermission() async {
    isLoading = false;
    notifyListeners();
    var locationStatus = await Permission.location.status;
    if (locationStatus == PermissionStatus.granted) {
      isLocationPermission = true;
    }

    notifyListeners();
  }

  getLatLong() async {
    if (isLocationPermission) {
      Position position = await getLocation();
      lat = position.latitude.toString();
      long = position.longitude.toString();
    }
  }

  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.best, // You can adjust the accuracy level
    );
    return position;
  }

  getPermissions() async {
    if (isLocationPermission) {
      return;
    }
    return showDialog(
        context: getCurrentContext(),
        builder: (context) {
          return Dialog(
            child: Container(
                height: 160,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Permission Required",
                        style: TextStyle(color: primary, fontSize: 20),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Location",
                            style: TextStyle(fontSize: 16),
                          ),
                          Switch(
                            value: Provider.of<GeneralController>(context)
                                .isLocationPermission,
                            activeColor: primary,
                            onChanged: (value) async {
                              print(value);
                              if (value) {
                                final locationStatus =
                                    await Permission.location.status;

                                if (locationStatus.isPermanentlyDenied) {
                                  print("123");
                                  await openAppSettings();
                                } else {
                                  print("1234");
                                  await Permission.location.request();
                                }
                                await checkPermission();
                                await getReports();
                              }
                            },
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: Provider.of<GeneralController>(context)
                                    .isLocationPermission
                                ? () {
                                    getReports();
                                    Navigator.pop(context);
                                  }
                                : () {},
                            child: Text("Done",
                                style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Provider.of<GeneralController>(context)
                                                .isLocationPermission
                                            ? primary
                                            : Colors.grey)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          );
        });
  }

  getReports() {
    if (isLocationPermission) {
      getCurrentWeather();
      get5daysReport();
    }
  }

  getCurrentWeather() async {
    cLoading = true;
    notifyListeners();

    if (!isLocationPermission) {
      showSnackBar("Location Permission Required", kRed);
    }

    if (lat == "0.0" && long == "0.0") {
      await getLatLong();
    }

    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$apiKey'));

    if (response.statusCode == 200) {
      currentWeatherModel = currentWeatherModelFromJson(response.body);
    } else {
      showSnackBar('Failed to load weather data', kRed);
    }

    cLoading = false;
    notifyListeners();
  }

  get5daysReport() async {
    sLoading = true;
    notifyListeners();
    if (!isLocationPermission) {
      showSnackBar("Location Permission Required", kRed);
    }

    if (lat == "0.0" && long == "0.0") {
      await getLatLong();
    }

    String latt = isLatLongSelected ? slat : lat;
    String longg = isLatLongSelected ? slong : long;

    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latt&lon=$longg&appid=$apiKey'));

    if (response.statusCode == 200) {
      var val = forcastModelFromJson(response.body);
      forcastList = val.list;
    } else {
      showSnackBar('Failed to load weather data', kRed);
    }
    sLoading = false;
    notifyListeners();
  }

  addMarker(LatLng latLng) async {
    isLatLongSelected = true;
    markers.clear(); // Clear existing markers
    markers.add(
      Marker(
        markerId: MarkerId('TappedLocation'),
        position: latLng,
      ),
    );
    // You can access the latitude and longitude of the tapped location here.
    slat = latLng.latitude.toString();
    slong = latLng.longitude.toString();
    await get5daysReport();
    notifyListeners();
  }
}
