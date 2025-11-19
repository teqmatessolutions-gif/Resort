# Resort Demo - Local Development Running ✅

## Services Status

### ✅ Running Services

1. **Admin Dashboard**
   - URL: http://localhost:3000/admin
   - Status: ✅ Running
   - Port: 3000

2. **User Frontend**
   - URL: http://localhost:3002
   - Status: ✅ Running
   - Port: 3002

### ⏳ Backend API

- URL: http://localhost:8012/api
- Port: 8012
- Status: Starting (may need database setup)

## Access URLs

- **Admin Dashboard:** http://localhost:3000/admin
- **User Frontend:** http://localhost:3002
- **API Docs:** http://localhost:8012/docs (when backend is running)
- **API Base:** http://localhost:8012/api

## Backend Database Setup

The backend requires a PostgreSQL database. To set it up:

### Option 1: Create PostgreSQL Database

```powershell
# If PostgreSQL is installed locally
psql -U postgres
```

Then run:
```sql
CREATE DATABASE rdb;
CREATE USER resortuser WITH PASSWORD 'resort123';
GRANT ALL PRIVILEGES ON DATABASE rdb TO resortuser;
\c rdb
GRANT ALL ON SCHEMA public TO resortuser;
```

### Option 2: Use SQLite for Local Development (Quick Start)

You can temporarily modify the `.env` file to use SQLite:

```env
DATABASE_URL=sqlite:///./resort.db
```

Then restart the backend.

## Stopping Services

To stop all services, press `Ctrl+C` in each terminal window, or:

```powershell
# Find and stop processes
Get-Process | Where-Object { $_.ProcessName -eq "node" -or $_.ProcessName -eq "python" } | Stop-Process
```

## Troubleshooting

### Backend Not Starting
- Check if PostgreSQL is running
- Verify database `rdb` exists
- Check `.env` file configuration
- View backend logs in the terminal

### Frontend Not Loading
- Check if ports 3000 and 3002 are available
- Verify npm dependencies are installed
- Check browser console for errors

### Database Connection Issues
- Ensure PostgreSQL service is running
- Verify database credentials in `.env`
- Check firewall settings

## Next Steps

1. **Set up database** (PostgreSQL or SQLite)
2. **Access admin dashboard** at http://localhost:3000/admin
3. **Access user frontend** at http://localhost:3002
4. **Test API endpoints** at http://localhost:8012/docs

---

**Status:** Frontends running ✅ | Backend pending database setup ⏳

