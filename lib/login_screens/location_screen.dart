import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utility/loaction_utility.dart'; // Update the import path as needed.

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition; // Make it nullable for safety.
  String _currentAddress = 'Fetching address...'; // Default message.
  bool _serviceEnabled = false;
  LocationPermission _permission = LocationPermission.denied;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      // Check if location services are enabled.
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services.')),
        );
        return;
      }

      // Check location permissions.
      _permission = await Geolocator.checkPermission();
      if (_permission == LocationPermission.denied) {
        _permission = await Geolocator.requestPermission();
        if (_permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is denied.')),
          );
          return;
        }
      }

      if (_permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permissions are permanently denied. Please enable them in settings.'),
          ),
        );
        return;
      }

      // Get current position.
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      // Fetch address from coordinates.
      if (_currentPosition != null) {
        _getAddressFromLatLng();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      // Convert coordinates into a readable address.
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placemarks[0];
      String formattedAddress =
          "${place.street}, ${place.subLocality}, ${place.postalCode}, ${place.country}";

      // Update UI.
      setState(() {
        _currentAddress = formattedAddress;
      });

      // Save location data to the utility class.
      LocationUtility.setLocation(
          _currentPosition!.latitude, _currentPosition!.longitude,
          formattedAddress);

      // Save data to SharedPreferences for persistence.
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', _currentPosition!.latitude);
      await prefs.setDouble('longitude', _currentPosition!.longitude);
      await prefs.setString('address', formattedAddress);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching address: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Start alignment for the column.
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Location image
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/location_image.png', // Replace with your image asset
                height: 200, // Set the size as needed
                width: 200,
              ),
            ),
            const SizedBox(height: 24),

            // Heading
            const Text(
              'Where is your Location?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),

            // Subheading
            const Text(
              'Enjoy your personalized selling and buying experience by telling us your location.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 32),

            // Current address text
            Text(
              _currentAddress,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Spacer to push the button to the bottom
            const Spacer(),

            // "Continue" button
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}