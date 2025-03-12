class Car:
    def __init__(self, model, vin, location, used_by):
        self.model = model
        self.vin = vin
        self.location = location
        self.used_by = used_by
        self.locked = False
        self.door_closed = True
        self.lights = False
        self.engine = False
    
    def toggle_lock(self):
        self.locked = not self.locked
    
    def toggle_lights(self):
        self.lights = not self.lights
    
    def toggle_engine(self):
        self.engine = not self.engine
    
    def toggle_doors(self):
        self.door_closed = not self.door_closed
    
    def assign_driver(self, driver):
        self.used_by = driver
    
    def is_locked(self):
        return self.locked == True
    
    def get_lights_status(self):
        return self.lights
    
    def get_engine_status(self):
        return self.engine
    
    def are_doors_closed(self):
        return self.door_closed == True
    
    def __str__(self):
        return (f"Car(model={self.model}, vin={self.vin}, location={self.location}, "
                f"locked={self.locked}, lights={self.lights}, engine={self.engine}, "
                f"used_by={self.used_by})")