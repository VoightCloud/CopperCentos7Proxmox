
podTemplate(label: "build",
        containers: [
                containerTemplate(name: 'packer-terraform',
                        image: 'voight/packer-terraform:1.1',
                        alwaysPullImage: false,
                        ttyEnabled: true,
                        privileged: true,
                        command: 'cat'),
                containerTemplate(name: 'jnlp', image: 'jenkins/inbound-agent:latest-jdk11', args: '${computer.jnlpmac} ${computer.name}')
        ]) {
    node('build') {
        stage('Build') {
            container('packer-terraform') {
                environment {
                    EPOCH = 'EPOCH'
                    KSISONAME = 'KSISONAME'
                    KSISOCHECKSUM = 'KSISOCHECKSUM'
                    TEMPLATENAME = 'TEMPLATENAME'
                    PASSWORD = 'PASSWORD'
                    HASH = 'HASH'
                }

                def scmVars = checkout([
                        $class           : 'GitSCM',
                        userRemoteConfigs: scm.userRemoteConfigs,
                        branches         : scm.branches,
                        extensions       : scm.extensions
                ])

                withCredentials([usernamePassword(credentialsId: 'proxmox_token', passwordVariable: 'packer_token', usernameVariable: 'packer_username')]) {

                    dir('packer') {
                        EPOCH = sh(returnStdout: true, script: "date +%s").trim()
                        KSISONAME = "ks-proxmox-${EPOCH}.iso"
                        TEMPLATENAME = "copper-centos7-${EPOCH}"
                        PASSWORD = sh(returnStdout: true, script: "openssl rand -base64 9").trim()
                        HASH = sh(returnStdout: true, script: "openssl passwd -6 ${PASSWORD}").trim()

                        sh "sed -i -E 's|\\-\\-password=(.*)|--password=${HASH}|g' http/ks-proxmox.cfg"

                        sh "mkisofs -o ${KSISONAME} http"
                        KSISOCHECKSUM = "sha256:" + sh(returnStdout: true, script: "sha256sum ${KSISONAME}").split("\\s")[0]
                        sh "echo checksum:${KSISOCHECKSUM}"

                        sh "curl -k -s -X POST https://192.168.137.7:8006/api2/json/nodes/ugli/storage/local/upload -H 'Authorization: PVEAPIToken=$packer_username=$packer_token'  -F 'content=iso' -F 'filename=@${KSISONAME}'"


                        sh "sed -i -E 's|\\-\\-password=(.*)|--password=randpass|g' http/ks-proxmox.cfg"

                        sh "env"
                        sh "packer init proxmox.pkr.hcl"
                        sh "packer build --force proxmox.pkr.hcl"
                        sh "rm ${KSISONAME}"
                        sh "curl -s -X DELETE 'https://192.168.137.7:8006/api2/json/nodes/ugli/storage/local/content//local:iso/${KSISONAME}' -H 'Authorization: PVEAPIToken=$packer_username=$packer_token'"
                    }
                }
            }
        }
    }
}





