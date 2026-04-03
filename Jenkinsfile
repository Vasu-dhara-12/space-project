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
                sh "pwd"
                sh "ls -l"
                sh "ls -l project"
            }
        }

        // ✅ NEW: Maven Build
        stage('Build with Maven') {
            steps {
                dir('project') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        // ✅ NEW: SonarQube Analysis
        stage('SonarQube Analysis') {
            steps {
                dir('project') {
                    withSonarQubeEnv('sonarqube-server') {   // Jenkins Sonar config name
                        sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=vasundhara-app \
                        -Dsonar.host.url=http://<SONAR-IP>:9000 \
                        -Dsonar.login=<SONAR-TOKEN>
                        '''
                    }
                }
            }
        }

        // ✅ NEW: Nexus Deploy
        stage('Upload to Nexus') {
            steps {
                dir('project') {
                    sh 'mvn deploy -DskipTests'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                if [ ! -f project/Dockerfile ]; then
                    echo "Error: Dockerfile not found!"
                    exit 1
                fi
                '''
                sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ./project"
                sh "docker tag $IMAGE_NAME:$IMAGE_TAG $DOCKER_REGISTRY/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER_CREDS',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login $DOCKER_REGISTRY -u "$DOCKER_USER" --password-stdin
                    docker push $DOCKER_REGISTRY/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG
                    docker logout $DOCKER_REGISTRY
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                export KUBECONFIG=/var/lib/jenkins/.kube/config

                if [ ! -f deployment.yml ]; then
                    echo "Error: deployment.yml not found!"
                    exit 1
                fi

                kubectl apply -f deployment.yml
                '''
            }
        }

        stage('Run Docker Container') {
            steps {
                sh "docker stop $CONTAINER_NAME || true"
                sh "docker rm $CONTAINER_NAME || true"
                sh "docker run -d -p $PORT:$CONTAINER_PORT --name $CONTAINER_NAME $DOCKER_REGISTRY/$DOCKER_REPO/$IMAGE_NAME:$IMAGE_TAG"
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully! 🚀"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
