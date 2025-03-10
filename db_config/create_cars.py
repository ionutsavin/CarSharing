import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()

db_params = {
    'dbname': os.environ['DB_NAME'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD'],
    'host': os.environ['DB_HOST'],
    'port': os.environ['DB_PORT'],
}

conn = psycopg2.connect(**db_params)
cursor = conn.cursor()


def create_cars_table():
    create_table_query = '''
    CREATE TABLE IF NOT EXISTS cars (
        id SERIAL PRIMARY KEY,
        brand VARCHAR(50) NOT NULL,
        full_name VARCHAR(100) NOT NULL,
        vin VARCHAR(17) UNIQUE NOT NULL,
        location VARCHAR(50) NOT NULL,
        status VARCHAR(50) DEFAULT 'available' NOT NULL -- Track the car's status
    );
    '''
    cursor.execute(create_table_query)
    conn.commit()


def insert_sample_cars():
    cars = [
        ('Tesla', 'Tesla Model 3', '5YJ3E1EA7KF317435', 'BUCURESTI'),
        ('BMW', 'BMW 3 Series', 'WBA8A9C53E5J63761', 'BUCURESTI'),
        ('Audi', 'Audi A4', 'WAUZZZ8K2EA506634', 'BUCURESTI'),
        ('Ford', 'Ford Focus', '1FADP3F22JL212345', 'BUCURESTI'),

        ('Toyota', 'Toyota Corolla', 'JTDBU4EE0B1524236', 'CLUJ'),
        ('Honda', 'Honda Civic', '2HGFC2F58FH501233', 'CLUJ'),

        ('Mercedes-Benz', 'Mercedes-Benz A-Class', 'WDDHF4AB7KF165354', 'BRASOV'),
        ('Volkswagen', 'Volkswagen Golf', 'WVWAZZ1JZ8C123456', 'BRASOV'),

        ('Nissan', 'Nissan Leaf', '1N4AZ0CP2BC149226', 'IASI'),
        ('Skoda', 'Skoda Octavia', 'TMBGH21Z7A2202189', 'IASI'),

        ('Chevrolet', 'Chevrolet Spark', 'KL1TD5DE8BB174325', 'TIMIS'),
        ('Hyundai', 'Hyundai Elantra', '5NPD84LF5JH121903', 'TIMIS'),

        ('Peugeot', 'Peugeot 208', 'VSSFZCFXB8D547328', 'ARAD'),
        ('Renault', 'Renault Clio', 'VF1B0H00455234512', 'ARAD'),

        ('Fiat', 'Fiat Panda', 'ZFA31200008564321', 'BRAILA'),
        ('Opel', 'Opel Astra', 'WOLOJ6EE2FZ845672', 'BRAILA'),

        ('Mazda', 'Mazda 3', 'JM1BL1U79A1456789', 'SIBIU'),
        ('Kia', 'Kia Sportage', 'KNDP6A7C9D7445123', 'SIBIU'),

        ('Ford', 'Ford Fiesta', 'WF0JXXGCB8JB12345', 'GALATI'),
        ('Citroen', 'Citroen C3', 'VF7RC9HT7FD763412', 'GALATI'),

        ('Dacia', 'Dacia Logan', 'UU1DGH3AABK234345', 'BISTRITA-NASAUD'),
        ('Renault', 'Renault Megane', 'VF1J6V5A3G1234579', 'BISTRITA-NASAUD'),

        ('Ford', 'Ford Mondeo', 'WFOAXXGBB8GC43123', 'ARGES'),
        ('BMW', 'BMW X5', '5UXTY5C56BLD74324', 'ARGES'),

        ('Fiat', 'Fiat 500', 'ZFA312A0V02456291', 'BIHOR'),
        ('Peugeot', 'Peugeot 508', 'VSSZZZ3D1B0023467', 'BIHOR')
    ]

    for car in cars:
        insert_query = '''
        INSERT INTO cars (brand, full_name, vin, location, status) 
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (vin) DO NOTHING;
        '''
        cursor.execute(insert_query, (car[0], car[1], car[2], car[3], 'available'))  # Default status

    conn.commit()

create_cars_table()
insert_sample_cars()

cursor.close()
conn.close()

print("Cars table created and populated successfully!")
