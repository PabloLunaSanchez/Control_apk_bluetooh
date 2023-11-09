import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData? icon;
  final String? imageAssetPath; // Ruta de la imagen en los recursos
  final Function onPressed;

  CustomButton({this.icon, this.imageAssetPath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (imageAssetPath != null) {
      return GestureDetector(
          onTap: () {
            onPressed();
          },
          child: Image.asset(
            imageAssetPath!,
            width: 80,
            height: 80,
          ));
    } else if (icon != null) {
      return IconButton(
        icon: Icon(icon),
        onPressed: () {
          onPressed();
        },
        iconSize: 80,
        color: Colors.white,
      );
    } else {
      // Manejar un caso sin ícono ni imagen (opcional)
      return Container();
    }
  }
}
