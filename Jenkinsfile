pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage ("clean workspace") {
            steps {
                cleanWs()
            }
        }
        stage ("Git checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/ShubhamPawar-3333/Amazon-Prime-App_CI-CD_Deployment.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=amazon-prime \
                        -Dsonar.projectKey=amazon-prime '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            } 
        }
        stage("Install NPM Dependencies") {
            steps {
                sh "npm install"
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage("Transfer Files over ssh") {
            steps {
                script {
                    def WORKSPACE = pwd()
                    echo "Workspace path: ${workspace}"
                    
                    sshagent(['project-setup-ssh-key']){
                        sh """
                            echo "Creating jenkins_workspace folder on tools server..."
                            ssh -o StrictHostKeyChecking=no ubuntu@65.2.148.205 "mkdir -p /home/ubuntu/jenkins_workspace"
                            
                            echo "Transferring files to tools server..."
                            scp -v -o StrictHostKeyChecking=no -r ${WORKSPACE}/* ubuntu@65.2.148.205:/home/ubuntu/jenkins_workspace/
                        """
                    }
                }
            }
        }
        stage("Trivy FS Scan") {
            steps {
                script {
                    sshagent(['project-setup-ssh-key']){
                        sh """
                            echo "Running Trivy scan on tools server..."
                            ssh -o StrictHostKeyChecking=no ubuntu@65.2.148.205 "trivy fs /home/ubuntu/jenkins_workspace/ > trivy.txt"
                        """
                    }
                }
            }
        }
        stage("Build Docker Image") {
            steps {
                script  {
                    sshagent(['project-setup-ssh-key']) {
                        sh """
                            echo "Building Docker image..."
                            ssh -o StrictHostKeyChecking=no ubuntu@65.2.148.205 "cd ./jenkins_workspace && docker build -t amazon-prime ."
                        """
                    }
                }
            }
        }
        stage ("Tag & Push to DockerHub") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sshagent(['project-setup-ssh-key']){
                            sh """
                                echo "Tagging Docker image..."
                                ssh -o StrictHostKeyChecking=no ubuntu@65.2.148.205 "docker tag amazon-prime ${DOCKER_USERNAME}/amazon-prime:latest "
                                
                                echo "Pushing Docker image to Docker Hub..."
                                ssh -o StrictHostKeyChecking=no ubuntu@65.2.148.205 "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD} && docker push ${DOCKER_USERNAME}/amazon-prime:latest"
                            """
                        }
                    }
                }
            }
        }
        stage('Docker Scout Image') {
            steps {
                script  {
                    sshagent(['project-setup-ssh-key']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@65.2.148.205 "docker-scout quickview shubhamp368/amazon-prime:latest && docker-scout cves shubhamp368/amazon-prime:latest && docker-scout recommendations shubhamp368/amazon-prime:latest"
                        """
                    }
                }
            }
        }
        stage('Deploy to Conatiner') {
            steps {
                script {
                    sshagent(['project-setup-ssh-key']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@65.2.148.205 "docker run -d --name amazon-prime -p 3000:3000 shubhamp368/amazon-prime:latest"
                        """
                    }
                }
            }
        }
    }
    post {
    always {
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: """
                <html>
                <body>
                    <div style="background-color: #FFA07A; padding: 10px; margin-bottom: 10px;">
                        <p style="color: white; font-weight: bold;">Project: ${env.JOB_NAME}</p>
                    </div>
                    <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                        <p style="color: white; font-weight: bold;">Build Number: ${env.BUILD_NUMBER}</p>
                    </div>
                    <div style="background-color: #87CEEB; padding: 10px; margin-bottom: 10px;">
                        <p style="color: white; font-weight: bold;">URL: ${env.BUILD_URL}</p>
                    </div>
                </body>
                </html>
            """,
            to: 'shuubham.pawar.368@gmail.com',
            mimeType: 'text/html',
            attachmentsPattern: 'trivy.txt'
        }
    }
}
