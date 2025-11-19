#!/usr/bin/env python3
"""Setup PostgreSQL database for Resort Demo"""
import psycopg2
from psycopg2 import sql

# PostgreSQL admin connection
ADMIN_CONN = 'postgresql://postgres:qwerty123@localhost:5432/postgres'
DB_NAME = 'rdb'
DB_USER = 'resortuser'
DB_PASSWORD = 'resort123'

def setup_database():
    """Create database and user with proper privileges"""
    try:
        # Connect as postgres admin
        print("Connecting to PostgreSQL as admin...")
        admin_conn = psycopg2.connect(ADMIN_CONN)
        admin_conn.autocommit = True  # Required for CREATE DATABASE
        admin_cur = admin_conn.cursor()
        
        # Check if database exists
        admin_cur.execute(
            "SELECT 1 FROM pg_database WHERE datname = %s",
            (DB_NAME,)
        )
        db_exists = admin_cur.fetchone()
        
        if not db_exists:
            print(f"Creating database '{DB_NAME}'...")
            admin_cur.execute(sql.SQL("CREATE DATABASE {}").format(
                sql.Identifier(DB_NAME)
            ))
            print(f"OK Database '{DB_NAME}' created")
        else:
            print(f"OK Database '{DB_NAME}' already exists")
        
        # Check if user exists
        admin_cur.execute(
            "SELECT 1 FROM pg_user WHERE usename = %s",
            (DB_USER,)
        )
        user_exists = admin_cur.fetchone()
        
        if not user_exists:
            print(f"Creating user '{DB_USER}'...")
            admin_cur.execute(
                sql.SQL("CREATE USER {} WITH PASSWORD %s").format(
                    sql.Identifier(DB_USER)
                ),
                (DB_PASSWORD,)
            )
            admin_conn.commit()
            print(f"OK User '{DB_USER}' created")
        else:
            print(f"OK User '{DB_USER}' already exists")
        
        # Grant privileges on database
        print(f"Granting privileges on database '{DB_NAME}' to '{DB_USER}'...")
        admin_cur.execute(
            sql.SQL("GRANT ALL PRIVILEGES ON DATABASE {} TO {}").format(
                sql.Identifier(DB_NAME),
                sql.Identifier(DB_USER)
            )
        )
        print("OK Database privileges granted")
        
        admin_cur.close()
        admin_conn.close()
        
        # Connect to the new database to grant schema privileges
        print(f"Connecting to database '{DB_NAME}'...")
        db_conn = psycopg2.connect(f'postgresql://postgres:qwerty123@localhost:5432/{DB_NAME}')
        db_cur = db_conn.cursor()
        
        # Grant schema privileges
        print(f"Granting schema privileges to '{DB_USER}'...")
        db_cur.execute(
            sql.SQL("GRANT ALL ON SCHEMA public TO {}").format(
                sql.Identifier(DB_USER)
            )
        )
        db_conn.commit()
        print("OK Schema privileges granted")
        
        db_cur.close()
        db_conn.close()
        
        # Test connection with new user
        print(f"Testing connection as '{DB_USER}'...")
        test_conn = psycopg2.connect(
            f'postgresql://{DB_USER}:{DB_PASSWORD}@localhost:5432/{DB_NAME}'
        )
        test_cur = test_conn.cursor()
        test_cur.execute("SELECT version()")
        version = test_cur.fetchone()[0]
        print(f"OK Connection successful!")
        print(f"   Database: {DB_NAME}")
        print(f"   User: {DB_USER}")
        print(f"   PostgreSQL: {version[:60]}...")
        
        test_cur.close()
        test_conn.close()
        
        print("\nOK OK OK Database setup complete!")
        return True
        
    except Exception as e:
        print(f"ERROR: {e}")
        return False

if __name__ == "__main__":
    setup_database()

