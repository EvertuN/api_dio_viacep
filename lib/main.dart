import 'package:api_dio_viacep/views/homePage.dart';
import 'package:flutter/material.dart';

Future<void> main () async {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AddressSearchScreen(),
  ));
}