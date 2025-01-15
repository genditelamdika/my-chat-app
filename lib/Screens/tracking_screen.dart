import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationTrackingScreen extends StatelessWidget {
  final CollectionReference locationCollection =
      FirebaseFirestore.instance.collection('user_locations');

  void trackAndSaveLocation() async {
    // Minta izin lokasi
    LocationPermission permission = await Geolocator.requestPermission();
    
    if (permission == LocationPermission.denied) {
      // Handle jika izin ditolak
      print('Izin lokasi ditolak');
      return;
    }
    
    // Dapatkan posisi pengguna
    Position position = await Geolocator.getCurrentPosition();
    
    // Simpan lokasi ke Firestore
    await locationCollection.add({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': Timestamp.now(), // Optional: tambahkan timestamp
    });

    print('Lokasi disimpan: ${position.latitude}, ${position.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Tracking'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: trackAndSaveLocation,
          child: Text('Track My Location'),
        ),
      ),
    );
  }
}