
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

                def scmVars = checkout([
                        $class           : 'GitSCM',
                        userRemoteConfigs: scm.userRemoteConfigs,
                        branches         : scm.branches,
                        extensions       : scm.extensions
                ])

                withCredentials([usernamePassword(credentialsId: 'proxmox_token', passwordVariable: 'packer_token', usernameVariable: 'packer_username')]) {

                    dir('packer') {
                        epoch = sh(returnStdout: true, script: "date +%s").trim()
                        ksisoname = "ks-proxmox-${epoch}.iso"
                        templateName = "copper-centos7-${epoch}"
                        password = sh(returnStdout: true, script: "openssl rand -base64 9").trim()
                        hash = sh(returnStdout: true, script: "openssl passwd -6 ${password}").trim()

                        sh "sed -i -E 's|\\-\\-password=(.*)|--password=${hash}|g' http/ks.cfg"

                        sh "mkisofs -o ${ksisoname} http"
                        ksisochecksum = sh(returnStdout: true, script: "sha256sum ${ksisoname}").split("\\s")[0]
                        sh "echo checksum:${ksisochecksum}"

                        sh "curl -k -s -X POST https://192.168.137.7:8006/api2/json/nodes/ugli/storage/local/upload -H 'Authorization: PVEAPIToken=$packer_username=$packer_token'  -F 'content=iso' -F 'filename=@${ksisoname}'"


                        sh "sed -i -E 's|\\-\\-password=(.*)|--password=randpass|g' http/ks.cfg"

                        withEnv(["KSISONAME=${ksisoname}", "KSISOCHECKSUM=${ksisochecksum}", "TEMPLATENAME=${templateName}", "PASSWORD=${password}"]) {
//                            sh "env"
                            sh "packer init proxmox.pkr.hcl"
                            sh "PACKER_LOG=1 packer build --force proxmox.pkr.hcl"
                        }
                        sh "rm ${ksisoname}"
                        sh "curl -s -X DELETE 'https://192.168.137.7:8006/api2/json/nodes/ugli/storage/local/content/local:iso/${ksisoname}' -H 'Authorization: PVEAPIToken=$packer_username=$packer_token'"
                    }
                }
            }
        }
    }
}





