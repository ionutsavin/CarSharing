# CarSharing

A simplified CarSharing system that simulates the interactions between a mobile user app, a backend service, and a vehicle's telematics module. This project demonstrates how a user can register, find nearby cars, and start/end rentals using a modern client-server architecture.

## Phone Application (Flutter)

The mobile app is built with **Flutter** and allows the user to:

- Create a client profile
- Register with the car-sharing company
- Find available cars in proximity
  
  ![Screenshot 2025-05-20 180322](https://github.com/user-attachments/assets/f810c852-3c95-483e-931a-9cdc53e062bb)

- Start the rental process for a selected car
  
  ![Screenshot 2025-05-20 180435](https://github.com/user-attachments/assets/18d1b5ed-ac39-4d20-a60a-9214bceaeeb0)
  
- Toggle with the lights, doors and engine before ending the rental
  
  ![Screenshot 2025-05-20 180534](https://github.com/user-attachments/assets/aabf27d3-2f15-406e-89aa-a4bb43d5ffad)
  
- End the rental after usage

### Features:
- User-friendly UI for authentication and car discovery
- Integration with backend via HTTP requests
- Real-time updates on car availability and rental status

## Backend (Node.js + Express)

The backend server is built with **Node.js** and manages the core logic of the CarSharing system:

- Maintains a list of all registered cars with:
  - Vehicle Identification Number (VIN)
  - Current location
- Receives and processes requests from the mobile application
- Communicates with the telematics module to:
  - Start the rental (unlock car)
  - End the rental (lock car)
  - Check car status for request approval

### Key Functions:
- Client profile registration
- Proximity-based car queries
- Rental lifecycle management
- Secure request validation

## Telematics Module (Python)

The telematics module simulates car behavior and is written in **Python**. It acts as a standalone service, responding to backend commands:

- Unlocks the car on rental start
- Locks the car on rental end
- Provides status information to the phone app as a simulator

This module emulates hardware-like behavior in software for testing and development purposes.
