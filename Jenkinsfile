pipeline {
    agent any
    
    environment {
        PROJECT_ID = 'orbital-age-427114-u7'
        REPOSITORY_NAME = 'rag'
        IMAGE_NAME = 'rag-controller'
        GCR_URL = "asia.gcr.io/${PROJECT_ID}/${REPOSITORY_NAME}/${IMAGE_NAME}"
        NAMESPACE = 'rag'
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    def ragDirectory = 'rag-controller'
                    echo 'Building RAG controller image for deployment ...'
                    docker.build("${GCR_URL}:v0.0.${BUILD_NUMBER}", "-f ${ragDirectory}/Dockerfile ${ragDirectory}")
                }
            }
        }

        stage('Scan Docker Image for Vulnerabilities') {
            steps {
                script {
                    echo 'Scanning RAG controller image ...'
                    sh(
                        "trivy image --ignore-unfixed --output v0.0.${BUILD_NUMBER}-vul.txt ${GCR_URL}:v0.0.${BUILD_NUMBER}"
                    )
                }
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    input message: 'Review the scan results and click "Proceed" to continue if there are no vulnerabilities.', ok: 'Proceed'
                }
            }
        }

        stage('Push to GCR') {
            steps {
                script {
                    docker.withRegistry('https://asia.gcr.io', 'gcr') {
                        docker.image("${GCR_URL}:v0.0.${BUILD_NUMBER}").push()
                    }
                }
            }
        }

        stage('Review') {
            steps {
                script {
                    input message: 'Review the CI process', ok: 'Proceed'
                }
            }
        }

        stage('Deploy to GKE ') {
            agent {
                kubernetes {
                    containerTemplate {
                        name 'helm' 
                        image 'asia.gcr.io/orbital-age-427114-u7/rag/jenkins_helm:v0.1' 
                    }
                }
            }
            steps {
                script {
                    steps
                    container('helm') {
                        sh("helm upgrade --install rag --set namespace=${NAMESPACE} \
                            --set deployment.image.name=${GCR_URL} \
                            --set deployment.image.version=v0.0.${BUILD_NUMBER} rag-controller/helm-charts/rag --namespace ${NAMESPACE}"
                        )
                    }
                }
            }
        }
    }
}