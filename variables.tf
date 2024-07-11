
### Cloud vars

variable "token" {
  description = "Yandex Cloud OAuth token"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "default_zone" {
  description = "Default zone for Yandex Cloud resources"
  type        = string
}

### Variables for VPC

variable "VPC_name" {
  type        = string
  default     = "my-vpc"
}

### Variables for Public subnet

variable "subnet_name" {
  type        = string
  default     = "public"
}

variable "v4_cidr_blocks" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
}

variable "subnet_zone" {
  type        = string
  default     = "ru-central1-a"
}


### Variables for Private subnet

variable "private_subnet_name" {
  type        = string
  default     = "private"
}

variable "private_v4_cidr_blocks" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
}

variable "private_subnet_zone" {
  type        = string
  default     = "ru-central1-a"
}


### Variables for NAT instance

variable "nat_name" {
  type        = string
  default     = "nat-instance"
}

variable "nat_cores" {
  type        = number
  default     = 2
}

variable "nat_memory" {
  type        = number
  default     = 2
}

variable "nat_disk_image_id" {
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
}

variable "nat" {
  type        = bool
  default     = true
}

variable "nat_primary_v4_address" {
  type        = string
  default     = "192.168.10.254"
}


### Variables for public_vm

variable "public_vm_name" {
  type        = string
  default     = "public-vm"
}

variable "public_vm_platform" {
  type        = string
  default     = "standard-v1"
}

variable "public_vm_core" { 
  type        = number
  default     = "4"
}

variable "public_vm_memory" {
  type        = number
  default     = "8"
}

variable "public_vm_core_fraction" {
  description = "guaranteed vCPU, for yandex cloud - 20, 50 or 100 "
  type        = number
  default     = "20"
}

variable "public_vm_disk_size" {
  type        = number
  default     = "50"
}

variable "public_vm_image_id" {
  type        = string
  default     = "fd893ak78u3rh37q3ekn"
}

variable "scheduling_policy" {
  type        = bool
  default     = "true"
}

### Variables for Private route table

variable "destination_prefix" {
  type        = string
  default     = "0.0.0.0/0"
}

### Variables for private_vm

variable "private_vm_name" {
  type        = string
  default     = "private-vm"
}

variable "private_vm_platform" {
  type        = string
  default     = "standard-v1"
}

variable "private_vm_core" {
  type        = number
  default     = "4"
}

variable "private_vm_memory" {
  type        = number
  default     = "8"
}

variable "private_vm_core_fraction" {
  description = "guaranteed vCPU, for yandex cloud - 20, 50 or 100 "
  type        = number
  default     = "20"
}

variable "private_vm_disk_size" {
  type        = number
  default     = "50"
}

variable "private_vm_image_id" {
  type        = string
  default     = "fd893ak78u3rh37q3ekn"
}

variable "private_scheduling_policy" {
  type        = bool
  default     = "true"
}
