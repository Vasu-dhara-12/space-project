pipeline {
    agent any

    environment {
        IMAGE_NAME = "vasundhara-nginx-app"
        CONTAINER_NAME = "vasundhara-nginx-container"
        PORT = "4000"
        CONTAINER_PORT = "80"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh "docker build -t $IMAGE_NAME ."
            }
        }

        stage('Run Docker Container') {
            steps {
                echo "Stopping existing container if any..."
                sh "docker stop $CONTAINER_NAME || true"
                sh "docker rm $CONTAINER_NAME || true"

                echo "Running new container on port $PORT..."
                sh "docker run -d -p $PORT:$CONTAINER_PORT --name $CONTAINER_NAME $IMAGE_NAME"
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully! Website is live on port $PORT."
        }
        failure {
            echo "Pipeline failed. Check logs for errors."
        }
    }
}
