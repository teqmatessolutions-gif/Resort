#!/usr/bin/env python3
"""Create admin user for Resort Demo"""
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from app.database import SessionLocal
from app.models.user import User, Role
from app.utils.auth import verify_password, get_password_hash

def create_admin_user():
    """Create admin user with default credentials"""
    db = SessionLocal()
    try:
        # Check if admin user already exists
        admin_user = db.query(User).filter(User.email == "admin@resort.com").first()
        if admin_user:
            print(f"Admin user already exists: {admin_user.email}")
            print("To reset password, delete the user first or update it manually.")
            return False
        
        # Check if admin role exists, create if not
        admin_role = db.query(Role).filter(Role.name == "admin").first()
        if not admin_role:
            print("Creating 'admin' role...")
            admin_role = Role(name="admin", permissions='["/dashboard", "/bookings", "/rooms", "/users", "/services", "/expenses", "/food-orders", "/food-categories", "/food-items", "/billing", "/roles", "/packages", "/reports", "/employees", "/guest-profile", "/user-history", "/userfrontend-data"]')
            db.add(admin_role)
            db.commit()
            db.refresh(admin_role)
            print("OK Admin role created")
        else:
            print("OK Admin role already exists")
        
        # Create admin user
        print("Creating admin user...")
        admin_user = User(
            email="admin@resort.com",
            hashed_password=get_password_hash("admin123"),
            name="Resort Administrator",
            is_active=True,
            role_id=admin_role.id
        )
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)
        
        print("\n" + "="*50)
        print("OK OK OK Admin user created successfully!")
        print("="*50)
        print(f"Email:    admin@resort.com")
        print(f"Password: admin123")
        print(f"Role:     {admin_role.name}")
        print("="*50)
        print("\nYou can now login to the admin dashboard with these credentials.")
        print("URL: http://localhost:3000/admin")
        print("="*50 + "\n")
        
        return True
        
    except Exception as e:
        print(f"ERROR: Failed to create admin user: {e}")
        db.rollback()
        return False
    finally:
        db.close()

if __name__ == "__main__":
    create_admin_user()

