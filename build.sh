#!/bin/bash
set -euo pipefail
docker rm -f todoapp 2>/dev/null || true
docker rm -f todoappdb 2>/dev/null || true

docker pull mariadb:11
docker volume create mariadb-data
docker run -d --name todoappdb -p 3306:3306 -e MARIADB_ROOT_PASSWORD=sekrit -e MARIADB_DATABASE=todo_db -e MARIADB_USER=todo_usr -e MARIADB_PASSWORD=letmeinplz -v mariadb-data:/var/lib/mysql:Z mariadb:11

docker exec -i todoappdb mariadb -h localhost --port=3306 -utodo_usr -pletmeinplz todo_db < TodoApp/schema.sql

cd TodoApp
ConnectionStrings__TodoDb="Server=localhost;Port=3306;Database=todo_db;User=todo_usr;Password=letmeinplz;"
dotnet run
