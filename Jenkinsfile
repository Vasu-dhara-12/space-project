pipeline {
    agent any

    environment {
        IMAGE_NAME = "vasundhara-nginx-app"
        CONTAINER_NAME = "vasundhara-nginx-container"
        PORT = "5000"
        CONTAINER_PORT = "80"
        DOCKER_REGISTRY = "docker.io"
        DOCKER_REPO = "vasudhara12"
        IMAGE_TAG = "latest"
    }

    stages {

        stage('Debug Workspace') {
            steps {
                echo "Checking workspace and project folder..."
                sh "pwd"
                sh "ls -l"
                sh "ls -l project"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image from project folder..."

                sh '''
                if [ ! -f project/Dockerfile ]; then
                    echo "Error: Dockerfile not found in project folder!"
                    exit 1
                fi
                '''

                sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ./project"
                sh "docker tag $IMAGE_NAME:$IMAGE_TAG $DOCKER_REGISTRY/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Logging in to Docker Hub..."

                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER_CREDS',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo $DOCKER_PASS | docker login $DOCKER_REGISTRY -u $DOCKER_USER --password-stdin
                    docker push $DOCKER_REGISTRY/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG
                    docker logout $DOCKER_REGISTRY
                    '''
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                echo "Stopping existing container if any..."
                sh "docker stop $CONTAINER_NAME || true"
                sh "docker rm $CONTAINER_NAME || true"

                echo "Running new container on port $PORT..."
                sh "docker run -d -p $PORT:$CONTAINER_PORT --name $CONTAINER_NAME $DOCKER_REGISTRY/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG"
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
