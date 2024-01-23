packer {
  required_plugins {
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
  }
}

variable "esxi_datastore" {
  type = string
}

variable "esxi_host" {
  type = string
}

variable "esxi_password" {
  type = string
}

variable "esxi_username" {
  type = string
}

source "vmware-iso" "WindowsServer-2022-Datacenter" {
  floppy_files        = ["config/autounattend.xml", "scripts/ssh_server.ps1", "scripts/enable-winrm.ps1"]
  communicator        = "winrm"
  cpus                = 2
  disk_adapter_type = "lsisas1068"
  disk_size           = 80560
  format              = "ova"
  guest_os_type       = "windows2019srvNext-64"
  headless            = true
  iso_checksum        = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  iso_urls            = ["iso/SERVER_EVAL_x64FRE_en-us.iso", "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"]
  keep_registered     = true
  memory              = 4096
  remote_datastore    = "${var.esxi_datastore}"
  remote_host         = "${var.esxi_host}"
  remote_password     = "${var.esxi_password}"
  remote_type         = "esx5"
  remote_username     = "${var.esxi_username}"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  skip_export         = false
  tools_upload_flavor = "windows"
  winrm_password   = "Passw0rd"
  winrm_timeout    = "20m"
  winrm_username   = "Administrator"
  vm_name             = "WindowsServer-2022-Datacenter"
  vmx_data = {
    "ethernet0.networkName" = "PfSense_LAN"
  }
  vnc_over_websocket = true
}

build {
  sources = ["source.vmware-iso.WindowsServer-2022-Datacenter"]

  provisioner "powershell" {
    elevated_user = "Administrator"
    elevated_password = build.Password
    scripts = ["scripts/ssh_server.ps1"]
  }

  provisioner "windows-shell" {
    inline = ["d:/setup64 /s /v \"/qb REBOOT=R\""]
    valid_exit_codes = [3010]
  }
}
