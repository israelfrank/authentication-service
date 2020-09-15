// authentication-service
pipeline {
  agent any
    stages {
      stage('get_commit_msg') {
        steps {
          script {
            env.GIT_COMMIT_MSG = sh (script: 'git log -1 --pretty=%B ${GIT_COMMIT}', returnStdout: true).trim()
            env.GIT_SHORT_COMMIT = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
            env.GIT_COMMITTER_EMAIL = sh (script: "git --no-pager show -s --format='%ae'", returnStdout: true  ).trim()
            env.GIT_REPO_NAME = scm.getUserRemoteConfigs()[0].getUrl().tokenize('/')[3].split("\\.")[0]

            env.BRANCH_FOR_URL = sh([script: "echo ${GIT_BRANCH} | sed 's;/;%2F;g'", returnStdout: true]).trim()
            env.JOB_PATH = sh([script: "echo ${JOB_NAME} | sed 's;/;%2F;g'", returnStdout: true]).trim() 
            env.JOB_WITHOUT_BRANCH = sh([script: "echo ${env.JOBNAME1} | sed 's;${BRANCH1};'';g'", returnStdout: true]).trim() 
            env.JOB_FOR_URL = sh([script: "echo ${JOBNAME2}|rev | cut -c 4- | rev", returnStdout: true]).trim()  
            echo "${env.JOB_FOR_URL}"  
          }
        }
      }
        stage('build dockerfile of tests') {
            steps {
              sh "docker build -t unittest/${env.GIT_REPO_NAME}:${env.GIT_SHORT_COMMIT} -f test.Dockerfile ." 
            }  
          }
        stage('run unit tests') {   
            steps {
                sh "docker run unittest/${env.GIT_REPO_NAME}:${env.GIT_SHORT_COMMIT}"  
            }
        post {
          always {
            discordSend description: '**service**: '+ env.GIT_REPO_NAME + '\n **Build**:' + " " + env.BUILD_NUMBER + '\n **Branch**:' + " " + env.GIT_BRANCH + '\n **Status**:' + " " +  currentBuild.result + '\n \n \n **Commit ID**:'+ " " + env.GIT_SHORT_COMMIT + '\n **commit massage**:' + " " + env.GIT_COMMIT_MSG + '\n **commit email**:' + " " + env.GIT_COMMITTER_EMAIL, footer: '', image: '', link: 'http://jnk-devops-ci-cd.northeurope.cloudapp.azure.com/blue/organizations/jenkins/'+env.JOB_FOR_URL+'/detail/'+env.GIT_BRANCH+'/'+env.BUILD_NUMBER+'/pipeline', result: currentBuild.result, thumbnail: '', title: ' link to result', webhookURL: 'https://discord.com/api/webhooks/735056754051645451/jYad6fXNkPMnD7mopiCJx2qLNoXZnvNUaYj5tYztcAIWQCoVl6m2tE2kmdhrFwoAASbv'   
          }
         }
        }
          stage('login to azure container registry') {
            steps{  
              withCredentials([usernamePassword(credentialsId:'ISRAEL_ACR',usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                sh "docker login  israel.azurecr.io -u ${USER} -p ${PASS}"
              }
            }
          }  
          stage('build dockerfile of system only for master and develop and push them to acr') {
            // when {
            //   anyOf {
            //      branch 'master'; branch 'develop'
            //   }
            // }
            steps {
             // script{
                //if(env.GIT_BRANCH == 'master') {
                  sh "docker build -t  israel.azurecr.io/${env.GIT_REPO_NAME}/master:${env.GIT_SHORT_COMMIT} ."
                  sh "docker push  israel.azurecr.io/${env.GIT_REPO_NAME}/master:${env.GIT_SHORT_COMMIT}"
                //}
               // else if(env.GIT_BRANCH == 'develop') {
                  sh "docker build -t  israel.azurecr.io/${env.GIT_REPO_NAME}/develop ."
                  sh "docker push  israel.azurecr.io/${env.GIT_REPO_NAME}/develop"  
                //}
             // } 
            }
          }      
    }   
}