@Library('jenkins-shared-library@main')

def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]
pipeline {

  agent any
  
  parameters {
	choice(name: 'action', choices: 'create\nrollback', description: 'Create/rollback of the deployment')
    string(name: 'ImageName', description: "Name of the docker build")
	string(name: 'ImageTag', description: "Name of the docker build")
	string(name: 'AppName', description: "Name of the Application")
    string(name: 'docker_repo', description: "Name of docker repository")
  }
  
  environment {
        registryCredential = 'ecr:us-east-1:awscreds'
        appRegistry = '334671708617.dkr.ecr.us-east-1.amazonaws.com/ecr'
        awsRegistry = "https://334671708617.dkr.ecr.us-east-1.amazonaws.com"
        cluster = "Stage"
        service = "service-stage"
        SONARSERVER='sonarserver'
        SONARSCANNER='sonarscanner'
    }
 
    stages {
        
        stage('Git Checkout') {
            when {
				expression { params.action == 'create' }
			}
            steps {
                gitCheckout(
                    branch: "master",
                    url: "https://github.com/LondheShubham153/reddit-clone-k8s-ingress.git"
                )
            }
        }
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        stage('Sonar Analysis') {
            environment {
                scannerHome = tool "${SONARSCANNER}"
            }
            steps {
               withSonarQubeEnv("${SONARSERVER}") {
                   sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=RedditClone \
                   -Dsonar.projectName=Reddit \
                   -Dsonar.projectVersion=1.0 '''
            }
            
          }
        }
        stage("Waiting for Quality Gate Result"){
            
            steps{
                
                timeout(time: 2, unit: 'MINUTES') {
               waitForQualityGate abortPipeline: true
            }
                
            }
        }

        stage

    }
    post {
        always {
            echo 'Slack Notifications.'
            slackSend channel: '#ci-cd',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
    
    
    
    
    
    
    
    
}