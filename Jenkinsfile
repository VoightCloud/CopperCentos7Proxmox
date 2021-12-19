
stage ("Build") {
    podTemplate(
            label: "build",
            containers: [
                    containerTemplate(name: 'packer',
                            image: 'hashicorp/packer:1.7.8',
                            alwaysPullImage: false,
                            ttyEnabled: true,
                            command: 'cat',
                            privileged: false),
                    containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest-jdk11', args: '${computer.jnlpmac} ${computer.name}')
            ],
            nodeSelector: 'kubernetes.io/arch=amd64'
    ) {
        stage('Build') {
            node('build') {
                def scmVars = checkout([
                        $class           : 'GitSCM',
                        userRemoteConfigs: scm.userRemoteConfigs,
                        branches         : scm.branches,
                        extensions       : scm.extensions
                ])

                def password = sh(returnStdout: true, script: "openssl rand -base64 9").trim()
                def hash =  sh(returnStdout: true, script: "openssl passwd -6 ${password}").trim()
                sh "sed -i -E 's|\\-\\-password=(.*)|--password=${hash}|g' packer/http/ks-proxmox.cfg"

                container('packer'){
                    dir('packer'){
                        withCredentials([usernamePassword(credentialsId: 'proxmox_token', passwordVariable: 'packer_token', usernameVariable: 'packer_username')]) {
                            sh "packer init proxmox.pkr.hcl"
                            sh "packer build --force proxmox.pkr.hcl"
                        }
                    }
                }
                sh "sed -i -E 's|\\-\\-password=(.*)|--password=randpass|g' packer/http/ks-proxmox.cfg"
            }
        }
    }
}


