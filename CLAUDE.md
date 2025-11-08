# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a learning project focused on understanding phantom reads in database systems. Phantom reads occur when a transaction reads a set of rows that satisfy a condition, but a concurrent transaction inserts or deletes rows that would affect the result set if the query were re-executed.

## Architecture

- **Database**: PostgreSQL 17 running in Docker container
- **Port**: 15432 (host) -> 5432 (container)
- **Database Name**: phantom_read_db
- **Demonstration Method**: Interactive SQL scripts executed in multiple terminal sessions

### File Structure
- `docker-compose.yml` - PostgreSQL container configuration
- `setup.sql` - Initial schema and sample data (auto-loaded on container start)
- `transaction1.sql` - First transaction (observes phantom reads)
- `transaction2.sql` - Second transaction (inserts new rows)
- `phantom-read-explanation.md` - Conceptual explanation of phantom reads
- `phantom-read-demo.md` - Detailed step-by-step demonstration instructions
- `README.md` - Quick start guide

## Development Commands

### Starting the Environment
```bash
# Start PostgreSQL container
docker-compose up -d

# Connect to database (Terminal 1)
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db

# Connect to database (Terminal 2)
docker exec -it phantom-read-postgres psql -U postgres -d phantom_read_db
```

### Running the Demonstration
```sql
-- Terminal 1: Execute transaction1.sql step by step
\i transaction1.sql

-- Terminal 2: Execute transaction2.sql after Terminal 1 completes step 1
\i transaction2.sql
```

### Cleanup
```bash
# Stop container
docker-compose down

# Stop and remove volumes (delete data)
docker-compose down -v
```

## Notes

For conceptual explanations and learning objectives, refer to `README.md` and `phantom-read-explanation.md`.
