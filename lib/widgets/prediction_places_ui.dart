import 'package:flutter/material.dart';

class PredictionPlacesUi extends StatelessWidget {
  String? predictionPlacesData;

  PredictionPlacesUi({super.key, this.predictionPlacesData});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed:() {

        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
        child: SizedBox(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              Row(
                children: [
                  const Icon(
                    Icons.share_location,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          predictionPlacesData!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3,),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
    );
  }
}

