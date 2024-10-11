from flask import Flask
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_socketio import SocketIO

from config.jwt import Config
from config.mongodb import get_db, init_app as init_db
from controllers import (
    user_controller,
    community_controller,
    event_controller,
    calendar_controller,
    comment_controller,
    notification_controller,
)
from core.application.user_service import UserService
from core.application.community_service import CommunityService
from core.application.event_service import EventService
from core.application.calendar_service import CalendarService
from core.application.comment_service import CommentService
from core.application.notification_service import NotificationService
from core.infrastructure.user_repository import UserRepository
from core.infrastructure.community_repository import CommunityRepository
from core.infrastructure.event_repository import EventRepository
from core.infrastructure.calendar_repository import CalendarRepository
from core.infrastructure.comment_repository import CommentRepository
from core.infrastructure.notification_repository import NotificationRepository

import logging
import sys


socketio = SocketIO()


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    init_db(app)

    CORS(app)
    jwt = JWTManager(app)

    socketio.init_app(
        app, cors_allowed_origins=app.config["SOCKETIO_CORS_ALLOWED_ORIGINS"]
    )

    init_services(app)

    register_blueprints(app)

    return app


def init_services(app):
    """Initialize repositories and services within app context."""
    with app.app_context():
        db = get_db()

        user_repository = UserRepository(db)
        community_repository = CommunityRepository(db)
        event_repository = EventRepository(db)
        calendar_repository = CalendarRepository(db)
        comment_repository = CommentRepository(db)
        notification_repository = NotificationRepository(db)

        app.user_service = UserService(user_repository)
        app.notification_service = NotificationService(
            notification_repository, user_repository
        )
        app.community_service = CommunityService(
            community_repository, user_repository, app.notification_service
        )
        app.event_service = EventService(
            event_repository, user_repository, app.notification_service
        )
        app.calendar_service = CalendarService(
            calendar_repository, event_repository, app.notification_service
        )
        app.comment_service = CommentService(
            comment_repository, user_repository, app.notification_service
        )


def register_blueprints(app):
    """Register controllers (blueprints)"""
    app.register_blueprint(user_controller.user_controller)
    app.register_blueprint(community_controller.community_controller)
    app.register_blueprint(event_controller.event_controller)
    app.register_blueprint(calendar_controller.calendar_controller)
    app.register_blueprint(comment_controller.comment_controller)
    app.register_blueprint(notification_controller.notification_controller)


if __name__ == "__main__":

    logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

    app = create_app()
    socketio.run(app, debug=True, log_output=True, host="0.0.0.0", port=5000)
