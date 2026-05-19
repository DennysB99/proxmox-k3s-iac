packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_api_url" { 
  type        = string 
  description = "The Proxmox API URL"
}

variable "proxmox_api_token" { 
  type        = string
  sensitive   = true 
  description = "The Proxmox API Token ID/Secret"
}

source "proxmox-iso" "debian13" {
  proxmox_url = var.proxmox_api_url
  
  # Splits on the equals sign (=) to get the full "user@realm!tokenid" string
  username = split("=", var.proxmox_api_token)[0]
  
  # Splits on the equals sign (=) to isolate just the raw secret UUID token
  token = split("=", var.proxmox_api_token)[1]
  
  insecure_skip_tls_verify = true

  node                 = "pve"
  vm_id                = 9000
  vm_name              = "debian13-base-template"
  template_description = "Packer-built Debian 13 Golden Image with Pre-baked SSH and Guest Agent"

  # System Specs
  cores    = 2
  memory   = 2048
  os       = "l26"
  qemu_agent = true

  # Unified Modern Boot ISO Configuration
  boot_iso {
    type     = "scsi"
    iso_file = "local:iso/debian-13.5.0-amd64-netinst.iso" 
  }

  # Packer background execution keys
  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout  = "20m"

  # Storage Layout
  disks {
    disk_size    = "20G"
    storage_pool = "local-lvm"
    type         = "scsi"
  }

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Automating the boot loader menu commands
  boot_command = [
    "<esc><wait>",
    "install auto=true url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg netcfg/get_hostname=debian13-golden-template netcfg/get_domain=unassigned-domain <enter>"
  ]
  http_directory = "http"
}

build {
  sources = ["source.proxmox-iso.debian13"]

  # Once the OS is installed, run these final tuning configurations
  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    
    inline = [
      "apt-get update && apt-get install -y qemu-guest-agent sudo",
      "systemctl enable qemu-guest-agent",
      "useradd -m -s /bin/bash primeexe",
      "echo 'primeexe ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/primeexe",
      "mkdir -p /home/primeexe/.ssh",
      "echo '${trimspace(file("~/.ssh/id_ed25519.pub"))}' > /home/primeexe/.ssh/authorized_keys",
      "chown -R primeexe:primeexe /home/primeexe/.ssh",
      "chmod 700 /home/primeexe/.ssh",
      "chmod 600 /home/primeexe/.ssh/authorized_keys"
    ]
  }
}