pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "thibaut16"
        IMAGE_NAME = "edureka-app"
        IMAGE_TAG = "latest"
        FULL_IMAGE = "${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Thibaut16/Git-DevOps.git'
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
                sh 'docker build -t $FULL_IMAGE .'
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh 'docker push $FULL_IMAGE'
            }
        }

        stage('Run Container (optional)') {
            steps {
                sh '''
                  docker rm -f edureka-app || true
                  docker run -d -p 8000:8000 --name edureka-app $FULL_IMAGE
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Build & Push erfolgreich'
        }
        failure {
            echo '❌ Pipeline fehlgeschlagen'
        }
        always {
            sh 'docker logout || true'
        }
    }
}

