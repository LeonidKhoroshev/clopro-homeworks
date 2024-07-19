
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

variable "lamp_sa_name" {
  type        = string
  default     = "lamp-service-account"
}

### Variables for Service Account

variable "sa_name" {
  type        = string
  default     = "leo"
}

### Variables for Object storage

variable "student_name" {
  type        = string
  default     = "khoroshevleonid"
}

variable "acl" {
  type        = string
  default     = "public-read"
}

### Variables for Yandex_storage_object

variable "image_file_name" {
  type        = string
  default     = "image.jpg"
}

variable "image_file_path" {
  type        = string
  default     = "/home/leo/clopro-homeworks/image.jpg"
}


### Variablables for KMS

variable "kms_key_name"  {
  type        = string
  default     = "kms-key"
}

variable "kms_key_description" {
  type        = string
  default     = "symmetric key for object storage"
}

variable "default_algorithm" {
  type        = string
  default     = "AES_128"
}

variable "prevent_destroy" {
  type        = bool
  default     = true
}

### Variables for LAMP group

#variable "lamp_name" {
#  type        = string
#  default     = "lamp-group"
#}
  

#variable "lamp_platform" {
#  type        = string
#  default     = "standard-v1"
#}

#variable "lamp_memory" {
#  type        = number
#  default     = 2
#}

#variable "lamp_cores" {
#  type        = number
#  default     = 2
#}

#variable "lamp_core_fraction" {
#  description = "guaranteed vCPU, for yandex cloud - 20, 50 or 100 "
#  type        = number
#  default     = "20"
#}


#variable "lamp_disk_image_id" {
#  type        = string
#  default     = "fd827b91d99psvq5fjit"
#}

#variable "lamp_scheduling_policy" {
#  type        = bool
#  default     = "true"
#}

#variable "lamp_size" {
#  type        = number
#  default     = 3
#}

#variable "lamp_max_unavailable" {
#  type        = number
#  default     = 1
#}

#variable "lamp_max_expansion" {
#  type        = number
#  default     = 3
#}

#variable "lamp_interval" {
#  type        = number
#  default     = 10
#}

#variable "lamp_timeout" {
#  type        = number
#  default     = 5
#}

#variable "healthy_threshold" {
#  type        = number
#  default     = 2
#}

#variable "unhealthy_threshold" {
#  type        = number
#  default     = 2
#}

#variable "lamp_port" {
#  type        = number
#  default     = 80
#}

### Variables for Load balancer

#variable "balancer_name" {
#  type        = string
#  default     = "balancer"
#}


#variable "balancer_listener_name" {
#  type        = string
#  default     = "http"
#}

#variable "balancer_listener_port" {
#  type        = number
#  default     = 80
#}

#variable "balancer_interval" {
#  type        = number
#  default     = 2
#}

#variable "balancer_timeout" {
#  type        = number
#  default     = 1
#}

#variable "unhealthy_threshold" {
#  type        = number
#  default     = 2
#}

#variable "healthy_threshold" {
#  type        = number
#  default     = 5
#}


### Variables for NAT instance

#variable "nat_name" {
#  type        = string
#  default     = "nat-instance"
#}

#variable "nat_cores" {
#  type        = number
#  default     = 2
#}

#variable "nat_memory" {
#  type        = number
#  default     = 2
#}

#variable "nat_disk_image_id" {
#  type        = string
#  default     = "fd80mrhj8fl2oe87o4e1"
#}

variable "nat" {
  type        = bool
  default     = true
}

variable "nat_primary_v4_address" {
  type        = string
  default     = "192.168.10.254"
}


### Variables for public_vm

#variable "public_vm_name" {
#  type        = string
#  default     = "public-vm"
#}

#variable "public_vm_platform" {
#  type        = string
#  default     = "standard-v1"
#}

#variable "public_vm_core" { 
#  type        = number
#  default     = "4"
#}

#variable "public_vm_memory" {
#  type        = number
#  default     = "8"
#}

#variable "public_vm_core_fraction" {
#  description = "guaranteed vCPU, for yandex cloud - 20, 50 or 100 "
#  type        = number
#  default     = "20"
#}

#variable "public_vm_disk_size" {
#  type        = number
#  default     = "50"
#}

#variable "public_vm_image_id" {
#  type        = string
#  default     = "fd893ak78u3rh37q3ekn"
#}

#variable "scheduling_policy" {
#  type        = bool
#  default     = "true"
#}

### Variables for Private route table

#variable "destination_prefix" {
#  type        = string
#  default     = "0.0.0.0/0"
#}

### Variables for private_vm

#variable "private_vm_name" {
#  type        = string
#  default     = "private-vm"
#}

#variable "private_vm_platform" {
#  type        = string
#  default     = "standard-v1"
#}

#variable "private_vm_core" {
#  type        = number
#  default     = "4"
#}

#variable "private_vm_memory" {
#  type        = number
#  default     = "8"
#}

#variable "private_vm_core_fraction" {
#  description = "guaranteed vCPU, for yandex cloud - 20, 50 or 100 "
#  type        = number
#  default     = "20"
#}

#variable "private_vm_disk_size" {
#  type        = number
#  default     = "50"
#}

#variable "private_vm_image_id" {
#  type        = string
#  default     = "fd893ak78u3rh37q3ekn"
#}

#variable "private_scheduling_policy" {
#  type        = bool
#  default     = "true"
#}
