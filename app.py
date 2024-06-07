from flask import Flask, request, jsonify
from flask_mysqldb import MySQL
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash
import config
from db import mysql
import MySQLdb
from datetime import datetime
from PIL import Image
import numpy as np

app = Flask(__name__)
app.config.from_object(config.Config)

mysql.init_app(app)
jwt = JWTManager(app)

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    username = data.get('username').strip()
    nama_lengkap = data.get('nama_lengkap').strip()
    password = data.get('password').strip()
    hashed_password = generate_password_hash(password)

    print(f"Register attempt: {username}, {password}, {hashed_password}")

    cur = mysql.connection.cursor()
    try:
        cur.execute("INSERT INTO users (username, password, nama_lengkap) VALUES (%s, %s, %s)", 
                    (username, hashed_password, nama_lengkap))
        mysql.connection.commit()
        print(f"User registered: {username}, {hashed_password}")
        return jsonify({"message": "User registered successfully"}), 201
    except MySQLdb.IntegrityError:
        print(f"Username already exists: {username}")
        return jsonify({"message": "Username already exists"}), 409
    finally:
        cur.close()

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username').strip()
    password = data.get('password').strip()
    print(f"Login attempt: {username}, {password}")

    cur = mysql.connection.cursor()
    cur.execute("SELECT id, username, password, nama_lengkap FROM users WHERE username = %s", [username])
    user = cur.fetchone()
    cur.close()

    if user:
        user_id, db_username, db_hashed_password, db_nama_lengkap = user
        print(f"User found: {user}")
        print(f"Hashed password in DB: {db_hashed_password}")
        print(f"Input password: {password}")
        print(f"Length of hashed password from DB: {len(db_hashed_password)}")

        # Pengecekan hash secara manual
        try:
            password_check = check_password_hash(db_hashed_password, password)
            print(f"Password check result: {password_check}")
        except Exception as e:
            print(f"Error checking password hash: {e}")
            password_check = False
        
        if password_check:
            access_token = create_access_token(identity={'username': db_username, 'user_id': user_id, 'nama_lengkap': db_nama_lengkap})
            print("Password matched")
            return jsonify({
                "access_token": access_token,
                "username": db_username,
                "user_id": user_id,
                "nama_lengkap": db_nama_lengkap
            }), 200
        else:
            print("Invalid password")
            return jsonify({"message": "Invalid credentials"}), 401
    else:
        print("User not found")
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
