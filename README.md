# Docker Swarm Cronjobs

## Docker Swarm – Complete Overview

### 1. What is Docker Swarm?
Docker Swarm is Docker’s native container orchestration tool.  
It allows you to group multiple Docker hosts (machines) into a single cluster, called a Swarm, and manage containers (services) across them as if they were one system.

**In simple terms:**  
Docker Swarm helps you run, scale, and manage containers across multiple servers automatically.

### 2. Why Use Docker Swarm?
Because it allows you to:  
- Scale applications easily across multiple nodes (servers)  
- Ensure high availability — if one node fails, others keep running containers  
- Deploy services across a cluster with a single command  
- Load balance requests automatically between containers  
- Self-heal containers (restarts them automatically if they fail)  

### 3. Use Cases
- Deploying microservices  
- High availability web apps  
- Periodic jobs (cronjob containers)  
- CI/CD environments  
- Multi-node application scaling  

---

## Cronjobs – Complete Explanation

### 1. What is a Cronjob?
A cronjob is a scheduled task that runs automatically at specific intervals — daily, hourly, weekly, or at any custom schedule — without manual execution.  
Think of a cronjob like an alarm clock for your computer: it wakes up at the right time and performs a specific task automatically.

### 2. What is Cron?
Cron is a time-based job scheduler in Unix/Linux systems.  
It reads a list of commands (jobs) from a configuration file called a crontab (cron table) and executes them at predefined times.

### 3. Cronjob Syntax
A typical cronjob entry looks like this:

## * * * * *

| Field | Meaning      | Valid Values  |
| ----- | ------------ | ------------- |
| 1st   | Minute       | 0–59          |
| 2nd   | Hour         | 0–23          |
| 3rd   | Day of Month | 1–31          |
| 4th   | Month        | 1–12          |
| 5th   | Day of Week  | 0–6 (Sun–Sat) |

**Example Cronjobs:**

| Schedule      | Command         | Description |
|---------------|----------------|-------------|
| 0 * * * *     | echo "Hello"    | Runs every hour |
| 30 2 * * *    | /backup.sh      | Runs every day at 2:30 AM |
| */5 * * * *   | uptime          | Runs every 5 minutes |
| 0 0 * * 0     | cleanup.sh      | Runs every Sunday at midnight |

### 4. The Crontab File

crontab -e # View or edit cron jobs

crontab -l # List all cron jobs

crontab -r # Remove cron jobs


### 5. Where Cronjobs are Used
- Database backups  
- Log cleanup  
- Sending scheduled reports  
- Monitoring scripts  
- Automated deployment tasks  

---

## Topic: Docker Swarm Cronjobs for NGINX Server

### 🧠 Overview
Docker Swarm does not have a native “CronJob” feature (like Kubernetes does).  
However, we can simulate cronjobs using:  
- A dedicated service that runs periodically (via shell scripts or cron inside a container)  
- Docker service update or recreate commands scheduled using cron on the host  
- External tools like GitHub Actions or Jenkins to trigger swarm updates on a schedule  

Here, we’ll do it directly within Docker Swarm, using a small cron container that interacts with the NGINX service.

---

### ✅ What is Crontab.guru?
It’s an online tool for creating and interpreting cron schedule expressions (the five-field format: minute, hour, day of month, month, day of week).  
[crontab.guru](https://crontab.guru/)  

You input something like `*/5 * * * *` and it tells you “Every 5 minutes” (or similar) which makes scheduling easier.  
Very useful for verifying your cron syntax so you don’t make a mistake like “runs at minute 60” or “wrong day of week”.

<img width="960" height="383" alt="Screenshot 2025-10-18 141921" src="https://github.com/user-attachments/assets/374063d1-b4cc-4a11-8544-02fb1948028a" />


---

## ⚙️ Prerequisites
- Docker Engine + Swarm mode enabled  
- A running NGINX service in the swarm  
- A manager node to run the cron container  

---

## 🧱 Step 1 – Install Git and Clone GitHub Repo
```bash
yum install git -y
git clone strapi-12
cd strapi-12
```

## 🧱 Step 2 – Initialize Docker Swarm
```bash
yum install docker -y && systemctl start docker
docker swarm init
```
If you want to add worker nodes, paste the command in server-2 after installing Docker.

docker node ls

<img width="903" height="54" alt="Screenshot 2025-10-18 134552" src="https://github.com/user-attachments/assets/9383dc77-c3db-4edd-9454-602dc9f95383" />

## 🧱 Step 3 – Deploy an NGINX Service
```bash
docker network create -d overlay monitor-net
docker network ls
docker service create --name nginx-service --network monitor-net --publish 80:80 nginx:latest
docker service ls
```

<img width="808" height="38" alt="Screenshot 2025-10-18 135123" src="https://github.com/user-attachments/assets/aae8178f-8426-4b5d-bdd8-5a973caee078" />

- You can access the NGINX server via the public IP of any server (Manager / Worker).

## 🧱 Step 4 – Create a Cronjob Container to Run Tasks
vim Dockerfile
```bash
FROM alpine:latest
RUN apk add --no-cache curl bash
COPY monitor.sh /monitor.sh
RUN chmod +x /monitor.sh
CMD ["sh", "-c", "while true; do /monitor.sh; sleep 300; done"]
```

vim monitor.sh
```bash
LOG_FILE="/var/log/nginx-monitor.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://nginx-service:80)

if [ "$STATUS_CODE" -eq 200 ]; then
    echo "$TIMESTAMP - ✅ NGINX is UP (Status: $STATUS_CODE)" | tee -a $LOG_FILE
else
    echo "$TIMESTAMP - ❌ NGINX is DOWN (Status: $STATUS_CODE)" | tee -a $LOG_FILE
fi
```

### 🧱 Step 5 – Build and Push the Image
```bash
docker build -t sairambadari/nginx-monitor:latest .
docker login
docker tag sairambadari/nginx-monitor:latest
docker push sairambadari/nginx-monitor:latest
```

## 🧱 Step 6 – Deploy the Monitoring Service
```bash
docker service create --name nginx-monitor-cronjob --network monitor-net sairambadari/nginx-monitor:latest
docker service ls
docker service logs nginx-monitor-cronjob
```
<img width="924" height="143" alt="Screenshot 2025-10-18 145402" src="https://github.com/user-attachments/assets/10176cb2-6266-4921-8a68-c9b3a0b55294" />


📊 Results

The monitor container continuously checks the NGINX endpoint.

Logs are stored in /var/log/nginx-monitor.log inside the container.

Acts like a cronjob with a 5-minute interval.

--- 

🚀 Conclusion

This setup demonstrates how to simulate cronjob-like behavior in Docker Swarm using looping containers.

You can extend this for:

- Database backups

- Log cleanup

- Health checks

- Periodic notifications

--- 

🧩 Next Steps

For more production-grade scheduling:

- Use docker-swarm-cronjob

- Integrate with GitHub Actions or external CI/CD pipelines

