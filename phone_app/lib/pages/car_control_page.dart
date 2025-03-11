import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'available_cars_page.dart';

class CarControlPage extends StatefulWidget {
  final String vin;

  const CarControlPage({super.key, required this.vin});

  @override
  CarControlPageState createState() => CarControlPageState();
}

class CarControlPageState extends State<CarControlPage> {
  bool _isEngineOn = false;
  bool _areLightsOn = false;
  bool _isCarLocked = false;

  Future<void> _toggleFeature(String action) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/update_status'),
      body: jsonEncode({'vin': widget.vin, 'action': action}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        if (action == 'engine') {
          _isEngineOn = !_isEngineOn;
        } else if (action == 'lights') {
          _areLightsOn = !_areLightsOn;
        } else if (action == 'lock') {
          _isCarLocked = !_isCarLocked;
        }
      });
    } else {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to toggle $action'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _endRental() async {
    String url;
    if(kIsWeb){
      url = 'http://localhost:3000/end-rental/${widget.vin}';
    } else {
      url = 'http://10.0.2.2:3000/end-rental/${widget.vin}';
    }
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rental ended successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AvailableCarsPage()),
      );
    } else {
      if(!mounted) return;
      final errorMessage = jsonDecode(response.body)['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to end rental: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Lock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(
                        _isCarLocked ? Icons.lock : Icons.lock_open,
                        color: _isCarLocked ? Colors.green : Colors.red,
                        size: 50,
                      ),
                      onPressed: () => _toggleFeature('lock'),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('Lights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(
                        _areLightsOn ? Icons.lightbulb : Icons.lightbulb_outline,
                        color: _areLightsOn ? Colors.orange : Colors.grey,
                        size: 50,
                      ),
                      onPressed: () => _toggleFeature('lights'),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 30),

            Column(
              children: [
                Text('Engine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(
                    _isEngineOn ? Icons.power : Icons.power_off,
                    color: _isEngineOn ? Colors.green : Colors.red,
                    size: 50,
                  ),
                  onPressed: () => _toggleFeature('engine'),
                ),
              ],
            ),

            SizedBox(height: 50),

            Center(
              child: ElevatedButton(
                onPressed: _endRental,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'End Rental',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
