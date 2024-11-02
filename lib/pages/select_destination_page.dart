import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project_udemy_app/widgets/prediction_places_ui.dart';

class SelectDestinationPage extends StatefulWidget {
  final String addressFrom;

  const SelectDestinationPage({Key? key, required this.addressFrom})
      : super(key: key);

  @override
  State<SelectDestinationPage> createState() => _SelectDestinationPageState();
}

class _SelectDestinationPageState extends State<SelectDestinationPage> {
  TextEditingController pickUpDestinationController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();
  List<String> _suggestions = [];

  void _onTextChanged(String query) async {
    if (query.isNotEmpty) {
      List<String> suggestions = await fetchSuggestions(query);
      setState(() {
        _suggestions = suggestions;
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<List<String>> fetchSuggestions(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&countrycodes=RS'
      ),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<String>((item) => item['display_name']).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  @override
  Widget build(BuildContext context) {
    pickUpDestinationController.text = widget.addressFrom;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 14,
              child: Container(
                height: 250, // Set a height for the container
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                                Icons.arrow_back, color: Colors.black),
                          ),
                          const Center(
                            child: Text(
                              "Search destination",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Image.asset(
                            "assets/initial.png",
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: TextField(
                                  controller: pickUpDestinationController,
                                  decoration: const InputDecoration(
                                    hintText: "pickup address",
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 11, top: 9, bottom: 9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Image.asset(
                            "assets/final.png",
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: TextField(
                                      controller: destinationTextEditingController,
                                      onChanged: _onTextChanged,
                                      decoration: const InputDecoration(
                                        hintText: "search destination here...",
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 11, top: 9, bottom: 9),
                                      ),
                                    ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            (_suggestions.length > 0)
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  child: ListView.separated(
                    itemCount: _suggestions.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 3,),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        child: PredictionPlacesUi(predictionPlacesData: _suggestions[index],)
                      );
                    }
                  )
                )
                : Container()
          ],
        ),
      ),
    );
  }
}
