packer {
  required_plugins {
    vsphere = {
      source  = "github.com/hashicorp/vsphere"
      version = "~> 1"
    }
  }
}

variable "vcenter_server" {
  type        = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance."
  default     = ""
}

variable "vcenter_username" {
  type        = string
  description = "The username for authenticating to vCenter."
  default     = ""
  sensitive   = true
}

variable "vcenter_password" {
  type        = string
  description = "The plaintext password for authenticating to vCenter."
  default     = ""
  sensitive   = true
}

variable "vcenter_datacenter" {
  type        = string
  description = "Required if there is more than one datacenter in vCenter."
  default     = ""
}

variable "vcenter_host" {
  type        = string
  description = "The ESXi host where target VM is created."
  default     = ""
}

variable "vcenter_datastore" {
  type        = string
  description = "Required for clusters, or if the target host has multiple datastores."
  default     = ""
}

variable "vcenter_network" {
  type        = string
  description = "The network segment or port group name to which the primary virtual network adapter will be connected."
  default     = ""
}

variable "vcenter_folder" {
  type        = string
  description = "The VM folder in which the VM template will be created."
  default     = ""
}

source "vsphere-iso" "WindowsServer-2022-Datacenter" {
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_username
  password            = var.vcenter_password
  datacenter          = var.vcenter_datacenter
  datastore           = var.vcenter_datastore
  host                = var.vcenter_host
  folder              = var.vcenter_folder
  insecure_connection = true

  floppy_files         = ["${path.root}/config/autounattend.xml", "${path.root}/scripts/ssh_server.ps1", "${path.root}/scripts/enable-winrm.ps1", "${path.root}/scripts/install_vmware_tools.ps1"]
  tools_upgrade_policy = true
  communicator         = "winrm"
  CPUs                 = 1
  cpu_cores            = 2
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size = 80000
  }
  guest_os_type = "windows2019srvNext_64Guest"
  iso_checksum  = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  iso_urls      = ["iso/SERVER_EVAL_x64FRE_en-us.iso", "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"]
  iso_paths = [
    "[] /usr/lib/vmware/isoimages/windows.iso"
  ]
  RAM              = 4096
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  winrm_password   = "Passw0rd"
  winrm_timeout    = "20m"
  winrm_username   = "Administrator"
  vm_name          = "WindowsServer-2022-Datacenter"
  network_adapters {
    network = "pfSense_LAN"
  }
}

build {
  sources = ["source.vsphere-iso.WindowsServer-2022-Datacenter"]

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = build.Password
    scripts           = ["${path.root}/scripts/ssh_server.ps1"]
  }

  post-processors {
    post-processor "vsphere-template" {
      host          = var.vcenter_server
      insecure      = true
      username      = var.vcenter_username
      password      = var.vcenter_password
      datacenter    = var.vcenter_datacenter
      folder        = var.vcenter_folder
      reregister_vm = true
    }
  }
}
