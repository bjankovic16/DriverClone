import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as LocationPackage;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project_udemy_app/auth/signin_page.dart';
import 'package:project_udemy_app/global.dart';
import 'package:project_udemy_app/pages/select_destination_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {

  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  LocationPackage.LocationData? currentLocation;
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  late String addressFrom;
  String addressTo = "Select Your Location";
  final String orsApiKey =
      '5b3ce3597851110001cf6248109f3dc55d6a457eb1712471bbe4b284';
  double searchContainerHeight = 220;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  getUserInfoAndCheckBlockStatus() async{
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("users").child(FirebaseAuth.instance.currentUser!.uid);
    await reference.once().then((dataSnap){
      if(dataSnap.snapshot.value != null) {
        if((dataSnap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (dataSnap.snapshot.value as Map)["name"];
            userPhone = (dataSnap.snapshot.value as Map)["phone"];

          });
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> SigninPage()));
          associateMethods.showSnackBarMsg("you are blocked contack admin", context);
        }
      } else {
        FirebaseAuth.instance.signOut();
      }
    });
  }


  Future<String> _getAddressFromLatLng(double latitude, double longitude) async {
    String address = "Address not found";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];

      setState(() {
        address = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      });
      return address.substring(0, 50);
    } catch (e) {
      print('Failed to get address: $e');
    }
    return address;
  }

  Future<void> _getCurrentLocation() async {
    var location = LocationPackage.Location();
    try {
      var userLocation = await location.getLocation();
      addressFrom = await _getAddressFromLatLng(userLocation.latitude!, userLocation.longitude!);
      await getUserInfoAndCheckBlockStatus();
      setState(() {
        currentLocation = userLocation;
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(userLocation.latitude!, userLocation.longitude!),
            child:
            const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
          ),
        );
      });
    } on Exception {
      currentLocation = null;
    }

    location.onLocationChanged.listen((LocationPackage.LocationData newLocation) {
      setState(() {
        currentLocation = newLocation;
      });
    });
  }

  Future<void> _getRoute(LatLng destination) async {
    if (currentLocation == null) return;

    final start =
    LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords =
      data['features'][0]['geometry']['coordinates'];
      setState(() {
        routePoints =
            coords.map((coord) => LatLng(coord[1], coord[0])).toList();
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: destination,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
          ),
        );
      });
    } else {
      // Handle errors
      print('Failed to fetch route');
    }
  }

  Future<void> _addDestinationMarker(LatLng point) async {
    setState(() {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: point,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
        ),
      );
    });
    addressTo = await _getAddressFromLatLng(point.latitude!, point.longitude!);
    _getRoute(point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: SizedBox(
        width: 256,
        child: Container(
          color: Colors.grey,
          child: ListView(
            children: [
              SizedBox(
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/avatar.webp",
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(width: 16),
                       Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          SizedBox(height: 4),
                          const Text(
                            "profile",
                            style: TextStyle(
                              color: Colors.grey,
                            )
                          )
                        ],
                      )
                    ],
                  )
                )
              ),
              GestureDetector(
                onTap: (){},
                child: const ListTile(
                  leading: Icon(Icons.history, color: Colors.black),
                  title: Text("History", style: TextStyle(color: Colors.black),),
                )
              ),
              GestureDetector(
                  onTap: (){},
                  child: const ListTile(
                    leading: Icon(Icons.info, color: Colors.black),
                    title: Text("About", style: TextStyle(color: Colors.black),),
                  )
              ),
              GestureDetector(
                  onTap: (){
                    FirebaseAuth.instance.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> SigninPage()));
                  },
                  child: const ListTile(
                    leading: Icon(Icons.logout, color: Colors.black),
                    title: Text("Logout", style: TextStyle(color: Colors.black),),
                  )
              ),
            ],
          )
        )
      ),
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
          children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(
                  currentLocation!.latitude!, currentLocation!.longitude!),
              initialZoom: 15.0,
              onTap: (tapPosition, point) => _addDestinationMarker(point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: markers,
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 1,
                    );
                  },
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 1,
                    );
                  },
                  child: const Icon(Icons.zoom_out),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: searchContainerHeight),
                  child: FloatingActionButton(
                    onPressed: () {
                      //_getCurrentLocation();
                      if (currentLocation != null) {
                        mapController.move(
                          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                          15.0,
                        );
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                )
              ],
            ),
          ),
          
          Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: AnimatedSize(
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 122),
                  child: Container(
                    height: searchContainerHeight,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(21),
                        topLeft: Radius.circular(21),
                      )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.add_location_alt_outlined, color: Colors.grey,),
                              const SizedBox(width: 13.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("From", style: TextStyle(fontSize: 12),),
                                  Text(addressFrom ?? 'Fetching address...', style: const TextStyle(fontSize: 12),),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10.0,),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16.0,),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.grey,),
                              const SizedBox(width: 13.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("To", style: TextStyle(fontSize: 12),),
                                  Text(addressTo ?? 'Fetching address...', style: const TextStyle(fontSize: 12),),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16.0,),
                          ElevatedButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (c)=> SelectDestinationPage(addressFrom: addressFrom)));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "Select Destination",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        ]
                      )
                    ),
                  )
              )
          )
        ],
      ),
    );
  }
}