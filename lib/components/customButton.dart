
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text ;
  final VoidCallback onPressed ;
  final Color? backgroundColor ;

  const CustomButton({
    super.key,
    required this.text ,
    required this.onPressed,
    this.backgroundColor ,

  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.green ,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5)
      ),
        onPressed: onPressed,
        child: Text(
          text ,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold ,

          ),
        ),
    );
  }
}
