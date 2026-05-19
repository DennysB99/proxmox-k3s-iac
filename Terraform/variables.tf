variable "proxmox_endpoint" {
  type        = string
  description = "The Proxmox API URL"
}

variable "proxmox_api_token" {
  type        = string
  description = "The Proxmox API Token ID/Secret"
  sensitive   = true
}

variable "vm_name_k_master" {
  type    = string
  default = "debian13-k3s-master"
}

variable "vm_id_k_master" {
  type    = number
  default = 300
}

variable "vm_name_k_worker_1" {
  type    = string
  default = "debian13-k3s-worker-1"
}

variable "vm_id_k_worker_1" {
  type    = number
  default = 301
}

