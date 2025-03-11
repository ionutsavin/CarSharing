from flask import Flask, request, jsonify
from car import Car

app = Flask(__name__)

active_cars = {}

@app.route('/start_rental', methods=['POST'])
def start_rental():
    """Handles rental start request from backend."""
    data = request.json
    vin = data.get("vin")

    if vin in active_cars:
        return jsonify({"error": "Car is already rented"}), 400

    car = Car(
        model=data["model"],
        vin=vin,
        location=data["location"],
        used_by=data["user"]
    )
    active_cars[vin] = car

    return jsonify({"message": f"Rental started for {car.model} (VIN: {vin})"}), 200

@app.route('/update_status', methods=['POST'])
def update_status():
    """Handles status updates from phone app (lock/unlock, lights, engine)."""
    data = request.json
    vin = data.get("vin")

    if vin not in active_cars:
        return jsonify({"error": "Car not found"}), 404

    car = active_cars[vin]

    action = data.get("action")
    if action == "lock":
        car.toggle_lock()
    elif action == "lights":
        car.toggle_lights()
    elif action == "engine":
        car.toggle_engine()
    else:
        return jsonify({"error": "Invalid action"}), 400
    
    return jsonify({"message": f"Car {vin} updated: {car}"}), 200

@app.route('/end_rental', methods=['POST'])
def end_rental():
    """Handles rental end request from backend."""
    data = request.json
    vin = data.get("vin")

    if vin not in active_cars:
        return jsonify({"error": "Car not found"}), 404

    car = active_cars[vin]

    if not car.locked or car.lights or car.engine:
        return jsonify({
            "error": "Car is not in the expected state",
            "details": {
                "locked": car.locked,
                "lights": car.lights,
                "engine": car.engine
            }
        }), 400

    del active_cars[vin]
    return jsonify({"message": f"Rental ended for {vin}, car removed from system"}), 200

if __name__ == '__main__':
    app.run(port=5000)
