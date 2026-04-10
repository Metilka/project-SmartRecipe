from flask import Flask
from config import Config
from app.extensions import db, bcrypt, jwt, jwt_blocklist


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    bcrypt.init_app(app)
    jwt.init_app(app)

    @jwt.token_in_blocklist_loader
    def check_if_token_revoked(jwt_header, jwt_payload):
        return jwt_payload["jti"] in jwt_blocklist

    from app import models

    from app.routes import main
    app.register_blueprint(main)

    from app.auth.routes import auth
    app.register_blueprint(auth)

    return app