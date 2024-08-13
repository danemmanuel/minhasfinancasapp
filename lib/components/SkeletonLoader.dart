import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.2), // Cor de base com opacidade
      highlightColor:
          Colors.white.withOpacity(0.5), // Cor de destaque com opacidade
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8),
        itemCount: 10, // Número de skeletons que você deseja exibir
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: Container(
              height: 80.0,
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.2), // Cor de fundo com opacidade
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 15.0,
                            color: Colors.white.withOpacity(0.2),
                            margin: EdgeInsets.only(bottom: 5.0),
                          ),
                          Container(
                            height: 5.0,
                            color: Colors.white.withOpacity(0.2),
                            margin: EdgeInsets.only(bottom: 5.0),
                          ),
                          Container(
                            height: 5.0,
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 100.0,
                    padding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 75.0,
                          height: 15.0,
                          color: Colors.white.withOpacity(0.2),
                          margin: EdgeInsets.only(bottom: 5.0),
                        ),
                        Container(
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.circle,
                                color: Colors.white.withOpacity(0.2),
                                size: 24.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
