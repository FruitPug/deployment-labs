# MyWebApp – Task Tracker Service

## Overview

A web-based task tracking service. The system allows users to create tasks, view them, and mark them as completed.

The application is deployed on a Linux virtual machine and consists of:

* Java web application
* MariaDB database
* Nginx reverse proxy
* systemd-managed service

---

## Architecture

```
client → nginx (port 80) → web app (127.0.0.1:3000) → MariaDB (localhost)
```

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

## Running the Application

### Build

```
mvn clean package
```

### Run manually

```
java -jar target/mywebapp-1.0-SNAPSHOT.jar
```

---

## Deployment

### Requirements

* Ubuntu
* 2 CPU cores
* 2 GB RAM
* 10 GB disk

---

### Automated Deployment

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
* disable debault user

---

## System Users

| User     | Role            |
| -------- | --------------- |
| student  | admin           |
| teacher  | admin           |
| operator | limited control |
| app      | runs service    |

Default password: `12345678` (must be changed on first login)

---

## Service Management

### systemd socket
```
mywebapp socket
``` 
Socket implementation is provided, but not actually used because the library I chose doesn't support systemd socket activation, so the socket unit is provided, but the application uses standard TCP binding. I understand that the choice of programming language and framework is my responsibility, but I don't want to rewrite all the code, so I'll take the L on this one.

### systemd service

```
mywebapp.service
```

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

* Listens on port 80
* Proxies requests to `127.0.0.1:3000`
* Allows access only to determined endpoints
* Logs stored in:

  * `/var/log/nginx/mywebapp_access.log`
  * `/var/log/nginx/mywebapp_error.log`

---

## Testing

### Check service

```
systemctl status mywebapp
```

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
/mywebapp       → source code
/scripts        → deployment script
README.md       → main documentation
```

---

## Notes

* Database migrations run automatically on service start
* Application runs under restricted system user (app)
* Only nginx is exposed externally

---
