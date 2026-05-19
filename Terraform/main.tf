terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.106.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true 
}

resource "proxmox_virtual_environment_vm" "k3s_master" {
  name        = var.vm_name_k_master
  node_name   = "pve"
  vm_id       = var.vm_id_k_master

  cpu { 
    cores = 2
    type  = "host" 
  }

  memory { dedicated = 2048 }
  agent  { enabled = true }

  clone {
    vm_id = 9000 
  }

  network_device { 
    bridge = "vmbr0" 
  }
}

resource "proxmox_virtual_environment_vm" "k3s_worker_1" {
  name        = var.vm_name_k_worker_1
  node_name   = "pve"
  vm_id       = var.vm_id_k_worker_1   

  cpu { 
    cores = 2
    type  = "host" 
  }

  memory { dedicated = 2048 }
  agent  { enabled = true }

  clone {
    vm_id = 9000 
  }

  network_device { 
    bridge = "vmbr0" 
  }
}