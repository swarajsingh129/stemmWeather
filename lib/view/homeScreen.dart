import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:stemmweather/controller/authController.dart';
import 'package:stemmweather/utils/constant.dart';

import '../controller/generalController.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GeneralController genralController;

  @override
  void initState() {
    genralController = Provider.of<GeneralController>(context, listen: false);
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      genralController.checkInternet();

      await genralController.checkPermission();
      await genralController.getPermissions();

      genralController.getReports();
    });
  }

  @override
  void dispose() {
    super.dispose();
    genralController.subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(
          child: Text("STEMM WEATHER"),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Provider.of<AuthController>(context, listen: false)
                    .signout(context);
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Consumer<GeneralController>(builder: (context, controller, child) {
        if (!controller.isInternet) {
          return Center(
            child: Lottie.asset('assets/lottie/animation_lo4aweff.json',
                repeat: false, width: 200),
          );
        }
        if (controller.isLoading) {
          return Center(
            child: progressIndicator(),
          );
        }
        if (!controller.isLocationPermission) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Location Permission Required"),
                SizedBox(
                  height: 5,
                ),
                TextButton(
                    onPressed: () async {
                      await genralController.getPermissions();
                    },
                    child: Text("Grant"))
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(14.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Current : ",
                      style: TextStyle(fontSize: 20),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        controller.getCurrentWeather();
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                controller.cLoading
                    ? Center(child: progressIndicator())
                    : controller.currentWeatherModel != null
                        ? ListTile(
                            leading: Image.network(
                                "https://openweathermap.org/img/wn/${controller.currentWeatherModel!.weather[0].icon}@2x.png"),
                            title: Text(
                                "${(controller.currentWeatherModel!.main.temp! - 273.15).toStringAsFixed(2)} °C    ${controller.currentWeatherModel!.weather[0].main}"),
                          )
                        : Text("No data"),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      "5 Days Forcast: ",
                      style: TextStyle(fontSize: 20),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        controller.get5daysReport();
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Text("Location   :  "),
                    Text(
                        " ${controller.isLatLongSelected ? "${controller.slat},\n${controller.slong}" : controller.showMap ? "Tap to select" : "Current Location"}"),
                    Spacer(),
                    controller.showMap
                        ? IconButton(
                            onPressed: () {
                              controller.showMap = false;
                              controller.isLatLongSelected = false;
                              controller.get5daysReport();
                              setState(() {});
                            },
                            icon: Icon(Icons.cancel))
                        : IconButton(
                            onPressed: () {
                              controller.showMap = true;
                              controller.forcastList = [];
                              setState(() {});
                            },
                            icon: Icon(Icons.gps_fixed))
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                controller.showMap
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.5,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                double.parse(controller.lat),
                                double.parse(
                                    controller.long)), // Initial map location
                            zoom: 15.0,
                          ),
                          markers: controller.markers,
                          onMapCreated: (GoogleMapController controller) {
                            // Map controller is ready
                          },
                          onTap: (argument) {
                            controller.addMarker(argument);
                          },
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                controller.sLoading
                    ? Center(
                        child: progressIndicator(),
                      )
                    : ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children:
                            controller.forcastList.asMap().entries.map((entry) {
                          final e = entry.value;
                          final isLastItem =
                              entry.key == controller.forcastList.length - 1;
                          final isDateChanged = entry.key == 0 ||
                              e.dtTxt.day !=
                                  controller
                                      .forcastList[entry.key - 1].dtTxt.day;

                          List<Widget> itemWidgets = [];

                          if (isDateChanged) {
                            // Add a Divider and a Date header if the date changes
                            itemWidgets.add(Divider());
                            itemWidgets.add(
                              ListTile(
                                title: Text(
                                  formatDate(
                                      e.dtTxt, 'MMMM d, y'), // Format the date
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }

                          itemWidgets.add(
                            ListTile(
                              leading: Image.network(
                                  "https://openweathermap.org/img/wn/${e.weather[0].icon}@2x.png"),
                              title: Text(
                                  "${(e.main.temp - 273.15).toStringAsFixed(2)} °C    ${controller.currentWeatherModel!.weather[0].main}"),
                              subtitle: Text(formatDate(
                                  e.dtTxt, 'h:mm a')), // Format the time
                            ),
                          );

                          if (isLastItem) {
                            itemWidgets.add(Divider());
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: itemWidgets,
                          );
                        }).toList(),
                      )
              ],
            ),
          ),
        );
      }),
    );
  }
}
