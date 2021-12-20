def epoch
def ksisoname
def templateName
def password
def hash

stage ("Build") {
    podTemplate(
        label: "build",
        containers: [
                containerTemplate(name: 'packer',
                        image: 'hashicorp/packer:full-1.7.8',
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
                    container('packer'){
                        dir('packer'){
                            epoch = sh(returnStdout: true, script: "date +\"%s\"").trim()
                            ksisoname = "ks-proxmox-${epoch}.iso"
                            templateName = "copper-centos7-${epoch}"
                            password = sh(returnStdout: true, script: "openssl rand -base64 9").trim()
                            hash =  sh(returnStdout: true, script: "openssl passwd -6 ${password}").trim()

                            sh "sed -i -E 's|\\-\\-password=(.*)|--password=${hash}|g' http/ks-proxmox.cfg"

                            sh "mkisofs -o ${ksisoname} http"


                            sh('curl -k -v -s verbose-X POST https://192.168.137.7:8006/api2/json/nodes/ugli/storage/local/upload -H "Authorization: PVEAPIToken=$packer_username=$packer_token"  -F "content=iso" -F "filename=@${ksisoname}"')


                            sh "sed -i -E 's|\\-\\-password=(.*)|--password=randpass|g' http/ks-proxmox.cfg"


                            sh "packer init proxmox.pkr.hcl"
                            sh "packer build --force proxmox.pkr.hcl"
                            sh "rm ${ksisoname}"
                            sh "curl -s -X DELETE 'https://192.168.137.7:8006/api2/json/nodes/ugli/storage/local/content//local:iso/${ksisoname}' -H 'Authorization: PVEAPIToken=$packer_username=$packer_token'"
                        }
                    }
                }
            }
        }
    }
}

