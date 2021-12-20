
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
                withCredentials([usernamePassword(credentialsId: 'proxmox_token', passwordVariable: 'packer_token', usernameVariable: 'packer_username')]) {
                    def epoch = sh(returnStdout: true, script: "date +"%s")
                    def ksisoname = "ks-proxmox-${epoch}.iso"
                    def templateName = "copper-centos7-${date}"

                    def password = sh(returnStdout: true, script: "openssl rand -base64 9").trim()
                    def hash =  sh(returnStdout: true, script: "openssl passwd -6 ${password}").trim()
                    sh "sed -i -E 's|\\-\\-password=(.*)|--password=${hash}|g' packer/http/ks-proxmox.cfg"

                    sh "mkisofs -o ${ksisoname} http"

                    sh "curl -s -X POST 'https://peach.voight.org:8006/api2/json/nodes/ugli/storage/local/upload' -H 'Authorization: PVEAPIToken=$packer_username=$packer_token'  -F 'content=iso' -F 'filename=@${ksisoname}'"

                    sh "sed -i -E 's|\\-\\-password=(.*)|--password=randpass|g' packer/http/ks-proxmox.cfg"

                    container('packer'){
                        dir('packer'){

                                sh "packer init proxmox.pkr.hcl"
                                sh "packer build --force proxmox.pkr.hcl"
                        }
                    }
                    sh "curl -s -X DELETE 'https://peach.voight.org:8006/api2/json/nodes/ugli/storage/local/content//local:iso/${ksisoname}' -H 'Authorization: PVEAPIToken=$packer_username=$packer_token'"

                    sh "rm ${ksisoname}"
                }
            }
        }
    }
}


