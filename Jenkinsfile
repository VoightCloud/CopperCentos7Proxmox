def epoch
def ksisoname
def templateName
def password
def hash

node {
    stages {
        stage('Build') {
            steps {
                step('Checkout') {
                    def scmVars = checkout([
                            $class           : 'GitSCM',
                            userRemoteConfigs: scm.userRemoteConfigs,
                            branches         : scm.branches,
                            extensions       : scm.extensions
                    ])
                }
                step('Packer') {
                    withCredentials([usernamePassword(credentialsId: 'proxmox_token', passwordVariable: 'packer_token', usernameVariable: 'packer_username')]) {
                        dir('packer') {
                            epoch = sh(returnStdout: true, script: "date +\"%s\"").trim()
                            ksisoname = "ks-proxmox-${epoch}.iso"
                            templateName = "copper-centos7-${epoch}"
                            password = sh(returnStdout: true, script: "openssl rand -base64 9").trim()
                            hash = sh(returnStdout: true, script: "openssl passwd -6 ${password}").trim()

                            sh "sed -i -E 's|\\-\\-password=(.*)|--password=${hash}|g' http/ks-proxmox.cfg"

                            sh "apt install mkisofs"

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





