packer {
  required_plugins {
    proxmox = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_url" {
  type    = string
  default = "https://192.168.137.7:8006/api2/json"
}

variable "token" {
  type    = string
  default = env("packer_token")
}

variable "username" {
  type    = string
  default = env("packer_username")
}

variable "node" {
  type    = string
  default = "ugli"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:689531cce9cf484378481ae762fae362791a9be078fda10e4f6977bf8fa71350"
}

variable "iso_file" {
  type    = string
  default = "local:iso/CentOS-7-x86_64-Everything-2009.iso"
}

variable "iso_storage_pool" {
  type    = string
  default = "local"
}

variable "password" {
  type    = string
  default = env("PASSWORD")
}

variable "templateName" {
  type    = string
  default = env("TEMPLATENAME")
}

variable "ksisoname" {
  type    = string
  default = env("KSISONAME")
}

variable "ksisochecksum" {
  type    = string
  default = env("KSISOCHECKSUM")
}

variable "memory" {
  type    = number
  default = 8192
}

variable "cores" {
  type    = number
  default = 2
}

variable "disk_size" {
  type    = string
  default = "48G"
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "cpu_type" {
  type    = string
  default = "host"
}

variable "os" {
  type    = string
  default = "l26"
}

variable "ssh_username" {
  type    = string
  default = "centos"
}

variable "vmname" {
  type    = string
  default = "centos-7.9-x86_64"
}

source "proxmox" "autogenerated_1" {
  boot_command = ["<up>e<down><down><end> text ks=hda/ks.cfg<leftCtrlON>x<leftCtrlOff>"]
  boot_wait    = "5s"
  disks {
    disk_size           = var.disk_size
    storage_pool        = var.storage_pool
    storage_pool_type   = "lvm"
    type                = "scsi"
  }

  additional_iso_files {
    device              = "ide0"
    iso_file             = "local:iso/${var.ksisoname}"
    unmount             = true
    iso_checksum        = var.ksisochecksum
  }

  os                    = var.os
  proxmox_url           = var.proxmox_url
  node                  = var.node
  insecure_skip_tls_verify = true
  username              = var.username
  token                 = var.token
  http_directory        = "http"
  iso_checksum          = var.iso_checksum
  iso_file              = var.iso_file
  iso_storage_pool      = var.iso_storage_pool
  memory                = var.memory
  cores                 = var.cores
  network_adapters {
    model               = "virtio"
    bridge              = "vmbr0"
  }
  unmount_iso          = true
  scsi_controller      = "virtio-scsi-pci"
  bios                 = "ovmf"
  efidisk              = var.storage_pool
  machine              = "q35"
  ssh_password         = var.password
  ssh_port             = 22
  ssh_username         = var.ssh_username
  ssh_wait_timeout     = "1800s"
  template_name        = var.templateName
  template_description = "centos copper image"
  cloud_init           = true
  cloud_init_storage_pool = var.storage_pool
}

build {
  sources = ["source.proxmox.autogenerated_1"]

  provisioner "file" {
    destination = "/home/centos/sudoers"
    source      = "files/sudoers"
  }

  provisioner "file" {
    destination = "/home/centos/cloud.cfg"
    source      = "files/cloud.cfg"
  }

  provisioner "file" {
    destination = "/home/centos/voight-ca.pem"
    source      = "files/voight-ca.pem"
  }

  provisioner "shell" {
    environment_vars = ["DNA=${var.iso_file}"]
    remote_folder    = "/home/centos"
    script           = "scripts/ansible.sh"
  }

  provisioner "ansible-local" {
    playbook_file = "scripts/init.yaml"
  }

  provisioner "shell" {
    remote_folder = "/home/centos"
    script        = "scripts/cleanup.sh"
  }

}
