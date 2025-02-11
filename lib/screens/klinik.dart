import 'package:flutter/material.dart';
import 'package:imunisasiku/screens/home_screen.dart';

void main() {
  runApp(Klinik());
}

class Klinik extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Klinik')),
      body: Center(child: Text('Halaman Klinik')),
    );
  }
}
