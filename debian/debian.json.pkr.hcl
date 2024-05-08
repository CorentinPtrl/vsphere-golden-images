packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "~> 1"
    }
  }
}

variable "vcenter_server" {
  type    = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance."
  default = ""
}

variable "vcenter_username" {
  type    = string
  description = "The username for authenticating to vCenter."
  default = ""
  sensitive = true
}

variable "vcenter_password" {
  type    = string
  description = "The plaintext password for authenticating to vCenter."
  default = ""
  sensitive = true
}

variable "vcenter_datacenter" {
  type    = string
  description = "Required if there is more than one datacenter in vCenter."
  default = ""
}

variable "vcenter_host" {
  type = string
  description = "The ESXi host where target VM is created."
  default = ""
}

variable "vcenter_datastore" {
  type    = string
  description = "Required for clusters, or if the target host has multiple datastores."
  default = ""
}

variable "vcenter_network" {
  type    = string
  description = "The network segment or port group name to which the primary virtual network adapter will be connected."
  default = ""
}

variable "vcenter_folder" {
  type    = string
  description = "The VM folder in which the VM template will be created."
  default = ""
}

locals {
  debian_preseed = file("preseed.cfg")
}

source "vsphere-iso" "debian_12" {
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_username
  password            = var.vcenter_password
  datacenter          = var.vcenter_datacenter
  datastore           = var.vcenter_datastore
  host                = var.vcenter_host
  folder              = var.vcenter_folder
  insecure_connection = true
  boot_command = [
    "<wait>",
    "<down><down><enter>",
    "<down><down><down><down><down><down><enter>",
    "<wait40>",
    "file:///mnt/cdrom2/preseed.cfg",
     #Open Shell and mount cdrom
    "<leftAltOn><f2><leftAltOff><wait2s>",
    "<enter><wait>",
    "mkdir /mnt/cdrom2<enter>",
    "mount /dev/sr1 /mnt/cdrom2<enter>",
    # go back to install menu
    "<leftAltOn><f1><leftAltOff>",
    "<right><enter><wait>",
    "<enter><wait>",
    "<down><enter>",
  ]
  cd_files = ["${path.root}/preseed.cfg"]
  cd_label = "cidata"
  boot_wait           = "2s"
  CPUs                = 1
  cpu_cores           = 2
  storage {
        disk_size = 15000
  }
  guest_os_type       = "ubuntu64Guest"
  iso_checksum        = "sha256:23ab444503069d9ef681e3028016250289a33cc7bab079259b73100daee0af66"
  iso_urls            = ["iso/debian-12.2.0-amd64-netinst.iso", "https://chuangtzu.ftp.acc.umu.se/debian-cd/current/amd64/iso-cd/debian-12.2.0-amd64-netinst.iso"]
  RAM                 = 4096
  shutdown_command    = "echo debian | sudo -S poweroff"
  ssh_password        = "debian"
  ssh_port            = 22
  ssh_username        = "debian"
  ssh_wait_timeout    = "20m"
  vm_name             = "debian-12.2"
  network_adapters {
    network = "pfSense_LAN"
  }
}

build {
  sources = ["source.vsphere-iso.debian_12"]
  post-processors {
      post-processor "vsphere-template" {
          host                = var.vcenter_server
          insecure            = true
          username            = var.vcenter_username
          password            = var.vcenter_password
          datacenter          = var.vcenter_datacenter
          folder              = var.vcenter_folder
          reregister_vm       = true
      }
    }
}
