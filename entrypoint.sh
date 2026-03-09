#!/bin/bash
set -e

echo "Waiting for database..."
# Simple wait loop for postgres
until pg_isready -h db -U postgres; do
  echo "Database is unavailable - sleeping"
  sleep 1
done

echo "Database is ready."

# Check if backups exist
BACKUP_DIR="/app/backups"
has_backups=false
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR/*.sql 2>/dev/null)" ]; then
    has_backups=true
fi

if [ "$has_backups" = true ]; then
    echo "========================================================"
    echo "                 BACKUP RESTORE CHECK"
    echo "========================================================"
    echo "Backups found in $BACKUP_DIR."
    echo "Do you want to restore the latest backup? (y/n)"
    echo "Waiting 10 seconds for input... (Default: n)"
    
    # Read with timeout
    read -t 10 -r response || response="n"
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        # Find latest backup
        LATEST_BACKUP=$(ls -t $BACKUP_DIR/*.sql | head -n1)
        echo "Restoring from $LATEST_BACKUP..."
        
        # Drop and recreate schema/data? Or just pipe?
        # Assuming clean restore on top of existing might fail if conflicts,
        # but psql usually handles it if the dump has drop statements.
        # pg_dump from our script uses defaults which might not include DROP.
        # Let's hope the user knows what they are doing or the dump is clean.
        # Ideally we should drop public schema.
        
        export PGPASSWORD=$POSTGRES_PASSWORD
        psql -h db -U $POSTGRES_USER -d $POSTGRES_DB -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
        psql -h db -U $POSTGRES_USER -d $POSTGRES_DB -f "$LATEST_BACKUP"
        
        echo "Restore complete."
    else
        echo "Skipping restore. Using current database state."
    fi
    echo "========================================================"
else
    echo "No backups found. Skipping restore check."
fi

# Initialize DB if empty? (reset_db.js logic?)
# For now, we assume the user handles init or the app does it.
# Actually, if it's a fresh container, DB is empty.
# We might want to run the migrations if no restore happened and DB is empty.
# Check if table 'eleves' exists.
export PGPASSWORD=$POSTGRES_PASSWORD
TABLE_EXISTS=$(psql -h db -U $POSTGRES_USER -d $POSTGRES_DB -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'eleves');")

if [ "$TABLE_EXISTS" = "f" ]; then
    echo "Database seems empty. running reset_db.js to initialize schema..."
    # We need to ensure we run this with correct env vars
    # But wait, reset_db.js uses 'pool' which uses DATABASE_URL.
    # docker-compose should set DATABASE_URL.
    node reset_db.js
fi

echo "Starting Application..."
exec node ./dist/server/entry.mjs
