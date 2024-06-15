pipeline {
    agent any
    
    environment {
        PROJECT_ID = 'legal-rag'
        REPOSITORY_NAME = 'test'
        GCR_URL = "gcr.io/${PROJECT_ID}/${REPOSITORY_NAME}"
    }
    
    stages {
        stage('SCM Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/lily4499/lil-node-app.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${GCR_URL}:${BUILD_NUMBER}")
                }
            }
        }
        
        stage('Push to GCR') {
            steps {
                script {
                    docker.withRegistry('https://gcr.io', 'gcp_credential') {
                        docker.image("${GCR_URL}:${BUILD_NUMBER}").push()
                    }
                }
            }
        }
    }
}