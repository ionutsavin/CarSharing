import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'available_cars_page.dart';

class ReservedCarPage extends StatefulWidget {
  final Map<String, dynamic> car;

  const ReservedCarPage({super.key, required this.car});

  @override
  ReservedCarPageState createState() => ReservedCarPageState();
}

class ReservedCarPageState extends State<ReservedCarPage> {
  Timer? _timer;
  int _secondsLeft = 60;
  bool _isCanceled = false;

  @override
  void initState() {
    super.initState();
    _startAutoCancelTimer();
  }

  void _startAutoCancelTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _cancelReservation();
        }
      });
    });
  }

  Future<void> _cancelReservation() async {
    if (_isCanceled) return;
    _isCanceled = true;
    _timer?.cancel();

    String url;

    if(kIsWeb){
      url = 'http://localhost:3000/cancel-reservation/${widget.car['id']}';
    } else {
      url = 'http://10.0.2.2:3000/cancel-reservation/${widget.car['vin']}';
    }

    final response = await http.post(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: response.statusCode == 200
            ? const Text('Reservation canceled.')
            : const Text('Failed to cancel reservation.'),
        backgroundColor: response.statusCode == 200 ? Colors.orange : Colors.red,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AvailableCarsPage()),
    );
    });
  }

  void _startRental() {
    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rental started successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${widget.car['full_name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Location: ${widget.car['location']}'),
                const SizedBox(height: 10),
                Text('Time left: $_secondsLeft seconds', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startRental,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Start Rental'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _cancelReservation,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel Reservation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
