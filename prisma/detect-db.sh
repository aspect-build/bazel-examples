#! /bin/sh

# A fake script detecting the DB to connect to.
echo "postgres://localhost:5432/"

# A real world example could run something like `docker compose port` to detect
# the specific port the DB container is running on.
