#!/bin/bash
set -euo pipefail

# Bouw de Docker-image van de Todo-app
docker build -t todoapp ./TodoApp

# Maak een netwerk zodat de app MariaDB kan bereiken
docker network create todo-network 2>/dev/null || true

# Start de MariaDB-container
docker run -d 
  --name todoappdb 
  --network todo-network 
  -e MARIADB_ROOT_PASSWORD=sekrit 
  -e MARIADB_DATABASE=todo_db 
  -e MARIADB_USER=todo_usr 
  -e MARIADB_PASSWORD=letmeinplz 
  -v mariadb-data:/var/lib/mysql 
  -v "$WORKSPACE/TodoApp/schema.sql:/docker-entrypoint-initdb.d/schema.sql:ro" \
  mariadb:11

# Wacht tot MariaDB klaar is
until docker exec todoappdb healthcheck.sh --connect --innodb_initialized; do
  sleep 2
done

# Start de Todo-app
docker run -d 
  --name todoapp 
  --network todo-network 
  -p 8080:8080 
  -e ConnectionStrings__TodoDb="Server=todoappdb;Port=3306;Database=todo_db;User=todo_usr;Password=letmeinplz;" 
  -e ASPNETCORE_ENVIRONMENT=Development 
  todoapp

# Toon de actieve containers
docker ps -a
