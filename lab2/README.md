# MyWebApp – Task Tracker Service

## Overview

A web-based task tracking service. The system allows users to create tasks, view them, and mark them as completed.

The application can be deployed in two ways:

1. **Script-based deployment**
2. **Containerized deployment using Docker Compose**

The system consists of:

* Java web application
* MariaDB database
* Nginx reverse proxy

---

## Architecture

### VM-based

```
client → nginx (port 80) → web app (127.0.0.1:3000) → MariaDB (localhost)
```

### Docker-based

```
client → nginx → app → database
             │        │
         (container network)
```

* Services communicate via Docker network using service names (`app`, `db`)

---

## Features

* Create tasks
* List all tasks
* Mark tasks as completed
* Health check endpoints
* Supports both JSON and HTML responses

---

## API Endpoints

### Health

* `GET /health/alive`
  Always returns `200 OK`

* `GET /health/ready`
  Returns:

  * `200 OK` if DB is connected
  * `500` otherwise

---

### Task Management

* `GET /tasks`
  Returns all tasks

* `POST /tasks?title=...`
  Creates a new task

* `POST /tasks/{id}/done`
  Marks task as completed

---

### Root Endpoint

* `GET /`
  Returns HTML page with available endpoints

---

## Response Formats

Controlled via `Accept` header:

* `application/json` → JSON output
* `text/html` → simple HTML table

---

## Database

### Engine

MariaDB

### Table: tasks

| Column     | Type      |
| ---------- | --------- |
| id         | INT (PK)  |
| title      | VARCHAR   |
| status     | VARCHAR   |
| created_at | TIMESTAMP |

---

# Deployment

## Option 1 — script-based

### Requirements

* Ubuntu
* 2 CPU cores
* 2 GB RAM
* 10 GB disk

---

### Automated Deployment

Build:

```
mvn clean package
```

Run:

```
sudo ./scripts/deploy.sh
```

This will:

* update system
* install dependencies
* create users
* configure database
* deploy application
* create system socket
* create systemd service
* configure nginx
* configure operator sudo
* create gradebook file
* disable default user

---

## Option 2 — Docker Compose

### Requirements

* Docker
* Docker Compose

---

### Run services

```
docker compose up -d
```

This will start:

* `db` — MariaDB container
* `app` — Java application container
* `nginx` — reverse proxy

---

### Stop services

```
docker compose down
```

---

### Remove all data (including DB)

```
docker compose down -v
```

---

## Docker Architecture Details

### Networking

* Custom bridge network is used
* Services communicate via DNS:

  * `db` → database
  * `app` → backend

---

### Database Persistence

* Data stored in Docker volume
* Survives:

  * container restart
  * Docker restart
  * system reboot

---

### Database Initialization

* Schema is applied automatically via `migrate.sql`
* Executed via init scripts

---

### Application Container

* Runs Java `.jar`
* Uses environment:

  * DB host: `db`
* Binds to:

  * `0.0.0.0:3000`

---

### Nginx Container

* Listens on port `80`
* Proxies to:

  ```
  http://app:3000
  ```

---

## System Users (script only)

| User     | Role            |
| -------- | --------------- |
| student  | admin           |
| teacher  | admin           |
| operator | limited control |
| app      | runs service    |

Default password: `12345678` (must be changed on first login)

---

## Service Management (script only)

### systemd socket

```
mywebapp socket
```

Socket implementation is provided, but not used because the chosen framework does not support systemd socket activation.

---

### systemd service

```
mywebapp.service
```

---

### Commands (operator allowed)

```
sudo systemctl start mywebapp
sudo systemctl stop mywebapp
sudo systemctl restart mywebapp
sudo systemctl status mywebapp
sudo systemctl reload nginx
```

---

## Nginx

### script-based

* Proxies to `127.0.0.1:3000`

### Docker-based

* Proxies to `app:3000`

---

* Logs stored in:

  * `/var/log/nginx/mywebapp_access.log`
  * `/var/log/nginx/mywebapp_error.log`

---

## Testing

### script-based

```
systemctl status mywebapp
```

---

### Docker-based

```
docker compose up
docker logs mywebapp-app
```

---

### Test endpoints

```
curl http://localhost
curl http://localhost/tasks
curl -X POST "http://localhost/tasks?title=test"
curl -X POST http://localhost/tasks/1/done
```

---

## Repository Structure

```
/docks               → documentation and research files
/scripts             → deployment script
/src                 → java source code
/target              → jar file
docker-compose.yml
Dockerfile.app
migrate.sql
nginx.conf
pom.xml
.dockerignore
```

---

## Notes

* script deployment uses system-level services
* Docker deployment uses container orchestration
* In Docker:

  * `localhost` is not shared between services
  * service names are used instead
* Only nginx is exposed externally

---
