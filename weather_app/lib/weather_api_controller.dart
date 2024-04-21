import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;


/*
Geolocation

void getUserLocation() async {
  if (Navigator.geolocation != null) {
    try {
      Position position = await Navigator.geolocation.getCurrentPosition();
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    } catch (e) {
      print('Error getting user location: $e');
    }
  } else {
    print('Geolocation is not supported by this browser.');
  }
}

void requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
}
*/