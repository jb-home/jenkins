pipeline {
  agent any

  environment {
    IMAGENAME = "jbhome/dind-jenkins"
    DOCKER_ID = "jbhome"
    DOCKER_PASSWORD = credentials('DOCKER_PASSWORD')
    DOCKER_BUILDKIT = 1
  }

  stages {
    stage('Init') {
      steps{
        sh "chmod +x ./get-version.sh"
        sh "./get-version.sh"	// Get latest version number and store in version.properties
        load "./version.properties"
        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_ID --password-stdin'
      }
    }
    stage('Build') {
      steps{
        sh 'docker buildx build --push --platform linux/arm/v7 -t $IMAGENAME:latest .'
      }
    }
    stage('Publish') {
      steps{
        sh 'docker buildx build --push --platform linux/arm/v7,linux/amd64 -t $IMAGENAME:latest .'
        sh 'docker buildx build --push --platform linux/arm/v7,linux/amd64 -t $IMAGENAME:$JENKINS_VERSION .'
      }
    }
    stage('Cleanup') {
      steps{
        sh "docker rmi debian:bullseye-slim"
        catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS')
        {
          sh "docker rmi \$(docker images -f dangling=true -q)"
        }
      }
    }
  }
}
