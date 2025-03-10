import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carsharing/pages/login_page.dart';
import 'reserved_car_page.dart';
import 'dart:developer';

class AvailableCarsPage extends StatefulWidget {
  const AvailableCarsPage({super.key});

  @override
  AvailableCarsPageState createState() => AvailableCarsPageState();
}

class AvailableCarsPageState extends State<AvailableCarsPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? selectedCity;
  List<Map<String, dynamic>> availableCars = [];
  bool isLoading = false;

  final List<String> cities = [
    'ALBA', 'ARAD', 'ARGES', 'BACAU', 'BIHOR', 'BISTRITA-NASAUD', 'BOTOSANI', 'BRAILA', 'BRASOV', 'BUZAU',
    'CALARASI', 'CARAS-SEVERIN', 'CLUJ', 'CONSTANTA', 'COVASNA', 'DAMBOVITA', 'DOLJ', 'GALATI', 'GIURGIU', 'GORJ',
    'HARGHITA', 'HUNEDOARA', 'IALOMITA', 'IASI', 'ILFOV', 'MARAMURES', 'MEHEDINTI', 'BUCURESTI', 'MURES', 'NEAMT',
    'OLT', 'PRAHOVA', 'SALAJ', 'SATU-MARE', 'SIBIU', 'SUCEAVA', 'TELEORMAN', 'TIMIS', 'TULCEA', 'VALCEA', 'VASLUI',
    'VRANCEA'
  ];

  Future<void> _logout(BuildContext context) async {
    await _storage.delete(key: 'jwt_token');
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> _fetchAvailableCars() async {
    if (selectedCity == null) return;

    setState(() {
      isLoading = true;
      availableCars = [];
    });

    String url;
    if(kIsWeb){
      url = 'http://localhost:3000/cars/$selectedCity';
    } else{
      url = 'http://10.0.2.2:3000/cars/$selectedCity';
    }
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          availableCars = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load cars');
      }
    } catch (e) {
      setState(() {
        availableCars = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _reserveCar(Map<String, dynamic> car) async {
    log('Reserving car: ${car['vin']}');
    log('Selected city: $selectedCity');

    String url;
    if(kIsWeb){
      url = 'http://localhost:3000/reserve/$selectedCity/${car['vin']}';
    } else {
      url = 'http://10.0.2.2:3000/reserve/$selectedCity/${car['vin']}';
    }
    final String? token = await _storage.read(key: 'jwt_token');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> carData = json.decode(response.body)['car'];

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReservedCarPage(car: carData)),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Car reserved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        log('Error parsing car reservation response: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process reservation. Invalid response.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      if (!mounted) return;
      final errorMessage = json.decode(response.body)['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reserve car: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
      if (errorMessage.contains('token')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: const Text('Car Sharing App'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your city:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedCity,
              hint: const Text('Choose a city'),
              items: cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: selectedCity == null ? null : _fetchAvailableCars,
                child: const Text('Search for Available Cars'),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : availableCars.isEmpty
                      ? const Center(child: Text('No cars available'))
                      : ListView.builder(
                          itemCount: availableCars.length,
                          itemBuilder: (context, index) {
                            final car = availableCars[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text('${car['full_name']}'),
                                subtitle: Text('Distance: ${index + 1} km'),
                                trailing: ElevatedButton(
                                  onPressed: () => _reserveCar(car),
                                  child: const Text('Reserve'),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
