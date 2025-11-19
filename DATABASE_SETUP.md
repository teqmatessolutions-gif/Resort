# PostgreSQL Database Setup for Resort Demo

## Quick Setup

The backend requires a PostgreSQL database named `rdb`. Follow these steps:

### Option 1: Using psql Command Line

```powershell
# Connect to PostgreSQL
psql -U postgres

# Then run these SQL commands:
CREATE DATABASE rdb;
CREATE USER resortuser WITH PASSWORD 'resort123';
GRANT ALL PRIVILEGES ON DATABASE rdb TO resortuser;
\c rdb
GRANT ALL ON SCHEMA public TO resortuser;
\q
```

### Option 2: Using pgAdmin

1. Open pgAdmin
2. Connect to your PostgreSQL server
3. Right-click on "Databases" → "Create" → "Database"
4. Name: `rdb`
5. Right-click on "Login/Group Roles" → "Create" → "Login/Group Role"
6. Name: `resortuser`
7. Password: `resort123`
8. Privileges: Grant all on database `rdb`

### Option 3: Single Command (PowerShell)

```powershell
$env:PGPASSWORD='postgres_password'
psql -U postgres -c "CREATE DATABASE rdb;"
psql -U postgres -c "CREATE USER resortuser WITH PASSWORD 'resort123';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE rdb TO resortuser;"
psql -U postgres -d rdb -c "GRANT ALL ON SCHEMA public TO resortuser;"
```

## Verify Database

```powershell
# List all databases
psql -U postgres -l

# Connect to rdb
psql -U postgres -d rdb

# Check tables (after backend creates them)
\dt
```

## Connection Details

- **Database:** `rdb`
- **User:** `resortuser`
- **Password:** `resort123`
- **Host:** `localhost`
- **Port:** `5432`
- **Connection String:** `postgresql+psycopg2://resortuser:resort123@localhost:5432/rdb`

## Troubleshooting

### "database does not exist"
- Create the database using the commands above

### "password authentication failed"
- Check PostgreSQL is running: `Get-Service postgresql*`
- Verify user exists and password is correct

### "permission denied"
- Grant privileges to the user on the database and schema

### "connection refused"
- Check PostgreSQL service is running
- Verify port 5432 is not blocked by firewall

