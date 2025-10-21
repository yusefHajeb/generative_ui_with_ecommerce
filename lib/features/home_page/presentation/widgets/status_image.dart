import 'package:flutter/material.dart';

class StatusImage extends StatelessWidget {
  const StatusImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 77, 86, 255),
            Color(0xFFB590E3),
            Color(0xFFFDBDBE),
            Color.fromARGB(255, 255, 95, 77),
          ],
        ),
        //shape as circular with border radius
        shape: CircleBorder(side: BorderSide(color: Colors.transparent, width: 1)),
        shadows: [
          BoxShadow(color: Color(0x3D433000), blurRadius: 9, offset: Offset(0, 5), spreadRadius: 0),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Text(
          'Online',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF433000)),
        ),
      ),
    );
  }
}
