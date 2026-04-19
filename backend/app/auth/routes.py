import re
import secrets
from datetime import datetime, timedelta

from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt_identity,
    get_jwt,
)
from flask_mail import Message

from app.extensions import db, bcrypt, jwt_blocklist, mail
from app.models import User

auth = Blueprint("auth", __name__)


@auth.route("/auth/register", methods=["POST"])
def register():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email and password required"}), 400

    if not re.match(r"^[^@]+@[^@]+\.[^@]+$", email):
        return jsonify({"error": "Invalid email format"}), 400

    if len(password) < 8:
        return jsonify({"error": "Password must be at least 8 characters"}), 400

    existing_user = User.query.filter_by(email=email).first()
    if existing_user:
        return jsonify({"error": "User already exists"}), 400

    password_hash = bcrypt.generate_password_hash(password).decode("utf-8")

    token = secrets.token_urlsafe(32)
    expires_at = datetime.utcnow() + timedelta(hours=24)

    new_user = User(
        email=email,
        password_hash=password_hash,
        created_at=datetime.utcnow(),
        verification_token=token,
        verification_token_expires_at=expires_at,
    )

    db.session.add(new_user)
    db.session.commit()

    verify_url = f"http://localhost:5000/auth/verify-email?token={token}"
    msg = Message(
        subject="Подтвердите вашу почту — SmartRecipe",
        recipients=[email],
        body=f"Здравствуйте!\n\nДля подтверждения почты перейдите по ссылке:\n{verify_url}\n\nСсылка действительна 24 часа.",
    )
    mail.send(msg)

    return jsonify({
        "message": "User created. Please check your email to verify your account.",
        "user_id": new_user.id,
    }), 201


@auth.route("/auth/verify-email", methods=["GET"])
def verify_email():
    token = request.args.get("token")
    if not token:
        return jsonify({"error": "Token is required"}), 400

    user = User.query.filter_by(verification_token=token).first()
    if not user:
        return jsonify({"error": "Invalid token"}), 400

    if user.verification_token_expires_at < datetime.utcnow():
        return jsonify({"error": "Token has expired"}), 400

    if user.is_verified:
        return jsonify({"message": "Email already verified"}), 200

    user.is_verified = True
    user.verification_token = None
    user.verification_token_expires_at = None
    db.session.commit()

    return jsonify({"message": "Email verified successfully"}), 200


@auth.route("/auth/login", methods=["POST"])
def login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email and password required"}), 400

    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"error": "Invalid credentials"}), 401

    if not bcrypt.check_password_hash(user.password_hash, password):
        return jsonify({"error": "Invalid credentials"}), 401

    if not user.is_verified:
        return jsonify({"error": "Please verify your email before logging in"}), 403

    access_token = create_access_token(identity=str(user.id))
    refresh_token = create_refresh_token(identity=str(user.id))

    return jsonify({
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user_id": user.id,
    })


@auth.route("/auth/logout", methods=["POST"])
@jwt_required()
def logout():
    jti = get_jwt()["jti"]
    jwt_blocklist.add(jti)
    return jsonify({"message": "Successfully logged out"})


@auth.route("/auth/refresh", methods=["POST"])
@jwt_required(refresh=True)
def refresh():
    user_id = get_jwt_identity()
    new_access_token = create_access_token(identity=user_id)
    return jsonify({"access_token": new_access_token})


@auth.route("/auth/change-password", methods=["POST"])
@jwt_required()
def change_password():
    user_id = int(get_jwt_identity())
    user = db.session.get(User, user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json() or {}
    old_password = data.get("old_password")
    new_password = data.get("new_password")

    if not old_password or not new_password:
        return jsonify({"error": "old_password and new_password required"}), 400

    if not bcrypt.check_password_hash(user.password_hash, old_password):
        return jsonify({"error": "Invalid current password"}), 401

    if len(new_password) < 8:
        return jsonify({"error": "Password must be at least 8 characters"}), 400

    user.password_hash = bcrypt.generate_password_hash(new_password).decode("utf-8")
    db.session.commit()

    return jsonify({"message": "Password changed successfully"})