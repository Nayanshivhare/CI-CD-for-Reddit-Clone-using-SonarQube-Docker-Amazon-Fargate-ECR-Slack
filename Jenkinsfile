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
        registry = 'nayanshiv1/redit'
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
        stage("Docker Build and Push") {
	        when {
				expression { params.action == 'create' }
			}
	        steps {
	            dir("${params.AppName}") {
	                dockerBuild ( "${params.ImageName}", "${params.docker_repo}" )
	            }
	        }
	    }

        stage('Kubernetes Deploy') {
            agent { label 'KOPS' }
            steps {
                    sh "helm upgrade --install --force vproifle-stack helm/vprofilecharts --set appimage=${registry}:${BUILD_NUMBER} --namespace prod"
            }
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