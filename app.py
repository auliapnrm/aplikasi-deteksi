from flask import Flask, request, jsonify
from flask_mysqldb import MySQL
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import config
from db import mysql
import numpy as np
from PIL import Image
import io

app = Flask(__name__)
app.config.from_object(config.Config)

mysql.init_app(app)
jwt = JWTManager(app)

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username')
    nama_lengkap = data.get('nama_lengkap')
    password = data.get('password')
    hashed_password = generate_password_hash(password)

    cur = mysql.connection.cursor()
    cur.execute("INSERT INTO users (username, nama_lengkap, password) VALUES (%s, %s, %s)", 
                (username, nama_lengkap, hashed_password))
    mysql.connection.commit()
    cur.close()

    return jsonify({"message": "User registered successfully"}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM users WHERE username = %s", [username])
    user = cur.fetchone()
    cur.close()

    if user and check_password_hash(user[3], password):
        access_token = create_access_token(identity={'username': username, 'user_id': user[0], 'nama_lengkap': user[2]})
        return jsonify(access_token=access_token), 200
    else:
        return jsonify({"message": "Invalid credentials"}), 401

@app.route('/detect', methods=['POST'])
@jwt_required()
def detect():
    current_user = get_jwt_identity()
    user_id = current_user['user_id']
    
    if 'image' not in request.files:
        return jsonify({"message": "No image part"}), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify({"message": "No selected file"}), 400

    image = Image.open(file.stream)
    image_np = np.array(image)

    detection_result = perform_detection(image_np)

    detection_time = datetime.now()
    cur = mysql.connection.cursor()
    cur.execute(
        "INSERT INTO detections (user_id, detection_time, detection_result) VALUES (%s, %s, %s)",
        (user_id, detection_time, detection_result)
    )
    mysql.connection.commit()
    cur.close()

    return jsonify({"detection_result": detection_result}), 200

def perform_detection(image_np):
    return "dummy_detection_result"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')