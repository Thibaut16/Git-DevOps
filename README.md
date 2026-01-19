# Git-DevOps
# 🚀 CI/CD Pipeline with Jenkins, Docker & Node.js (Part 1)

## 📌 Project Objective

The objective of this project is to build a **fully automated CI/CD pipeline** using:

* GitHub (Source Control)
* Jenkins (Automation Server)
* Docker (Containerization)
* Node.js (Sample Application)
* Ubuntu Linux (CI/CD Host OS)

By the end of this project, every code change pushed to GitHub is automatically:

1. Downloaded by Jenkins
2. Tested
3. Packaged into a Docker image
4. Uploaded to Docker Hub
5. Deployed as a running container

This repository documents the **real-world problems, errors, and fixes** encountered during setup — exactly as they happen in real DevOps environments.

This is **Part 1: Local CI/CD Pipeline on Ubuntu**.

---

## 🖥️ System Environment

| Component | Version               |
| --------- | --------------------- |
| OS        | Ubuntu 22.04 LTS      |
| Jenkins   | Latest LTS            |
| Docker    | Docker Engine 24+     |
| Node.js   | 18 (Alpine in Docker) |
| Git       | 2.43                  |

---

## 🗂️ Project Architecture

```
Developer → GitHub → Jenkins → Test → Build → Docker Hub → Run Container
```

---

## 1️⃣ Installing Jenkins on Ubuntu 22.04

### Step 1: Install Java

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
java -version
```

---

## 2️⃣ Installing Docker on Ubuntu 22.04

### ❌ Problem: Broken Docker Installation

We initially faced repeated issues:

* Docker packages conflicting with Ubuntu default repositories
* GPG key errors
* Repository signature problems
* Old Jenkins and Docker keys still registered in the system

Typical errors included:

```
NO_PUBKEY
Repository is not signed
Conflicting Signed-By options
```

---

## 🧟 Zombie Jenkins & Docker Keys Problem

Even after uninstalling Jenkins and Docker, Ubuntu kept loading:

* Old Jenkins GPG keys
* Old Jenkins repository files
* Cached APT metadata

These are called **"zombie configurations"** — removed software that still affects the system.

---

## 🧹 Full Cleanup Procedure (Critical Step)

We performed a **deep system cleanup**:

```bash
sudo systemctl stop jenkins
sudo apt remove --purge -y jenkins docker docker.io containerd runc
sudo rm -rf /var/lib/jenkins
sudo rm -rf /etc/jenkins
```

Remove leftover keys and repositories:

```bash
sudo rm -f /usr/share/keyrings/jenkins*
sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /etc/apt/trusted.gpg.d/jenkins*
sudo rm -f /var/lib/apt/lists/*
sudo apt clean
```

Verify zombie keys were removed:

```bash
sudo apt-key list | grep -i jenkins
```

Only then was the system clean.

---

## 3️⃣ Correct Docker Installation Method

Using the **official Docker repository only**:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
```

Enable Docker for Jenkins user:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart docker jenkins
```

---

## 4️⃣ Jenkins Pipeline Overview

Our Jenkins pipeline performs the following stages:

| Stage                | Purpose                    |
| -------------------- | -------------------------- |
| Checkout             | Download source code       |
| Install dependencies | Install Node.js modules    |
| Test app             | Validate JavaScript syntax |
| Build Docker Image   | Create application image   |
| Docker Hub Login     | Authenticate securely      |
| Push Image           | Publish to registry        |
| Run Container        | Deploy application         |

---

## 5️⃣ Jenkinsfile Used

```groovy
pipeline {
    agent any

    environment {
        DOCKER_USER = 'thibaut16'
        IMAGE_NAME = 'edureka-app'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Thibaut16/Git-DevOps.git'
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Test app') {
            steps {
                sh 'node -c main.js'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_USER/$IMAGE_NAME:latest .'
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-pass', variable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh 'docker push $DOCKER_USER/$IMAGE_NAME:latest'
            }
        }

        stage('Run Container') {
            steps {
                sh 'docker rm -f edureka-app || true'
                sh 'docker run -d -p 8000:8000 --name edureka-app $DOCKER_USER/$IMAGE_NAME:latest'
            }
        }
    }

    post {
        always {
            sh 'docker logout'
            echo '✅ Build & Push erfolgreich'
        }
    }
}
```

---

## 6️⃣ Why This Pipeline Is Production-Grade

This pipeline implements real enterprise DevOps principles:

* Immutable builds (Docker images)
* Automated testing
* Secure secrets handling
* Fully automated deployment

No manual server access is required after setup.

---

## 7️⃣ Key Lessons Learned

| Problem                  | Cause                       | Solution           |
| ------------------------ | --------------------------- | ------------------ |
| Docker install fails     | Mixed repositories          | Full APT cleanup   |
| Jenkins not starting     | Corrupt config              | Purge & reinstall  |
| GPG key conflicts        | Zombie keys                 | Manual key removal |
| Docker permission denied | Jenkins not in docker group | usermod -aG docker |

---

## 📦 Result

Every commit now automatically:

```
GitHub → Jenkins → Test → Build → Push → Deploy
```

This completes **Part 1: Local CI/CD Automation**.

➡️ Part 2 will extend this pipeline to cloud deployment and versioned releases.
