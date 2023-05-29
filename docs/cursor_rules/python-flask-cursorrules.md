# Python Flask Application - Rules for AI

This file provides guidance for working with Python Flask web applications.

## Project Structure

```
app/
├── __init__.py        # Flask application initialization
├── routes/            # Route definitions
│   ├── __init__.py
│   ├── auth.py        # Authentication routes
│   └── main.py        # Main application routes
├── models/            # Database models
│   ├── __init__.py
│   └── user.py        # User model
├── templates/         # Jinja2 templates
│   ├── base.html      # Base template
│   ├── auth/          # Authentication templates
│   └── main/          # Main application templates
├── static/            # Static files (CSS, JS, images)
│   ├── css/
│   ├── js/
│   └── img/
├── utils/             # Utility functions
│   └── __init__.py
├── config.py          # Configuration settings
└── extensions.py      # Flask extensions initialization
tests/                 # Test files
├── __init__.py
├── conftest.py        # Test configuration
└── test_*.py          # Test modules
.env                   # Environment variables
.flaskenv              # Flask-specific environment variables
requirements.txt       # Project dependencies
```

## General Guidelines

1. Follow the Flask application factory pattern
2. Use Blueprints to organize routes
3. Implement proper error handling
4. Use environment variables for configuration
5. Follow RESTful API design principles
6. Implement proper authentication and authorization
7. Use SQLAlchemy for database operations
8. Write comprehensive tests

## Implementation Details

### Application Factory

```python
# app/__init__.py
from flask import Flask
from app.extensions import db, migrate, login_manager
from app.config import config

def create_app(config_name='default'):
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    
    # Register blueprints
    from app.routes.main import main_bp
    from app.routes.auth import auth_bp
    app.register_blueprint(main_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')
    
    # Register error handlers
    from app.utils.errors import register_error_handlers
    register_error_handlers(app)
    
    return app
```

### Blueprints

```python
# app/routes/main.py
from flask import Blueprint, render_template, jsonify

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    return render_template('main/index.html')

@main_bp.route('/api/status')
def status():
    return jsonify({'status': 'ok'})
```

### Models

```python
# app/models/user.py
from app.extensions import db, login_manager
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, index=True)
    email = db.Column(db.String(120), unique=True, index=True)
    password_hash = db.Column(db.String(128))
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
        
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

@login_manager.user_loader
def load_user(id):
    return User.query.get(int(id))
```

## How to Use

1. Create a `.cursorrules` file in the root of your Flask project
2. Copy the content from this file
3. Customize it to match your project's specific structure and requirements
4. Commit the file to your repository

## Benefits

- Consistent project structure
- Standardized implementation patterns
- Better code organization
- Improved maintainability
- Easier onboarding for new developers
- Enhanced collaboration with Cursor AI

## Additional Resources

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Flask-SQLAlchemy](https://flask-sqlalchemy.palletsprojects.com/)
- [Flask-Migrate](https://flask-migrate.readthedocs.io/)
- [Flask-Login](https://flask-login.readthedocs.io/)
- [Flask Application Factory Pattern](https://flask.palletsprojects.com/en/2.0.x/patterns/appfactories/) 