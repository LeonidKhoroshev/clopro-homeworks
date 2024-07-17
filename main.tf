resource "yandex_vpc_network" "my_vpc" {
  name = var.VPC_name
}

resource "yandex_vpc_subnet" "public_subnet" {
  name           = var.subnet_name
  v4_cidr_blocks = var.v4_cidr_blocks
  zone           = var.subnet_zone
  network_id     = yandex_vpc_network.my_vpc.id
}

resource "yandex_vpc_subnet" "private_subnet" {
  name           = var.private_subnet_name
  v4_cidr_blocks = var.private_v4_cidr_blocks
  zone           = var.private_subnet_zone
  network_id     = yandex_vpc_network.my_vpc.id
}

resource "yandex_iam_service_account" "sa" {
  name = var.sa_name
}

resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-storage-put" {
  folder_id = var.folder_id
  role      = "storage.uploader"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "mystorage" {
  bucket                = "${var.student_name}-${formatdate("YYYYMMDD", timestamp())}"
  access_key            = yandex_iam_service_account_static_access_key.static-key.access_key
  secret_key            = yandex_iam_service_account_static_access_key.static-key.secret_key
  acl                   = var.acl
}

resource "yandex_storage_object" "image" {
  access_key            = yandex_iam_service_account_static_access_key.static-key.access_key
  secret_key            = yandex_iam_service_account_static_access_key.static-key.secret_key
  bucket = "${var.student_name}-${formatdate("YYYYMMDD", timestamp())}"
  key    = var.image_file_name
  source = var.image_file_path
  depends_on = [yandex_storage_bucket.mystorage]
  acl    = var.acl
}

resource "yandex_resourcemanager_folder_iam_member" "sa-vpc-user" {
  folder_id = var.folder_id
  role      = "vpc.user"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_compute_instance_group" "lamp_group" {
  name = var.lamp_name
  service_account_id = yandex_iam_service_account.sa.id
  instance_template {
    platform_id = var.lamp_platform   
    resources {
      memory = var.lamp_memory
      cores  = var.lamp_cores
      core_fraction = var.lamp_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.lamp_disk_image_id
    }
  }
  network_interface {
    subnet_ids = [yandex_vpc_subnet.public_subnet.id]
    nat = var.nat
  }  
  scheduling_policy {
    preemptible = var.lamp_scheduling_policy
  }

  metadata = {
      user-data = "${file("/home/leo/clopro-homeworks/cloud-init.yaml")}"
   }
  }
  
  scale_policy {
    fixed_scale {
      size = var.lamp_size
    }
  }

  deploy_policy {
    max_unavailable = var.lamp_max_unavailable
    max_expansion   = var.lamp_max_expansion
  }

  health_check {
    interval = var.lamp_interval
    timeout  = var.lamp_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    tcp_options {
      port = var.lamp_port
    }
  }

  allocation_policy {
    zones = [var.subnet_zone]
  }

  load_balancer {
        target_group_name = "lamp-group"
  }
}


resource "yandex_lb_network_load_balancer" "balancer" {
  name        = var.balancer_name
  folder_id   = var.folder_id
  listener {
    name = var.balancer_listener_name
    port = var.balancer_listener_port
    external_address_spec {
      ip_version = "ipv4"
    }
  }
attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp_group.load_balancer.0.target_group_id
    healthcheck {
      name = var.balancer_listener_name
      interval = var.balancer_interval
      timeout = var.balancer_timeout
      unhealthy_threshold = var.unhealthy_threshold
      healthy_threshold = var.healthy_threshold
      http_options {
        port = var.balancer_listener_port
        path = "/"
      }
    }
  }
}
#resource "yandex_compute_instance" "nat_instance" {
#  name = var.nat_name

#  resources {
#    cores  = var.nat_cores
#    memory = var.nat_memory
#  }

#  boot_disk {
#    initialize_params {
#      image_id = var.nat_disk_image_id
#    }
#  }

#  network_interface {
#    subnet_id = yandex_vpc_subnet.public_subnet.id
#    nat       = var.nat
#    ip_address = var.nat_primary_v4_address
#  }

#  metadata = {
#    user-data = "${file("/home/leo/clopro-homeworks/cloud-init.yaml")}"
#  }
#}

#resource "yandex_compute_instance" "public_vm" {
#  name            = var.public_vm_name
#  platform_id     = var.public_vm_platform
#  resources {
#    cores         = var.public_vm_core
#    memory        = var.public_vm_memory
#    core_fraction = var.public_vm_core_fraction
#  }

#  boot_disk {
#    initialize_params {
#      image_id = var.public_vm_image_id
#      size     = var.public_vm_disk_size
#    }
#  }

#  scheduling_policy {
#    preemptible = var.scheduling_policy
#  }

#  network_interface {
#    subnet_id = yandex_vpc_subnet.public_subnet.id
#    nat       = var.nat
#  }

#  metadata = {
#    user-data = "${file("/home/leo/kuber-homeworks/3.2/terraform/cloud-init.yaml")}"
# }
#}

resource "yandex_vpc_route_table" "private_route_table" {
  network_id = yandex_vpc_network.my_vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.nat_primary_v4_address
  }
}

#resource "yandex_compute_instance" "private_vm" {
#  name            = var.private_vm_name
#  platform_id     = var.private_vm_platform

#  resources {
#    cores         = var.private_vm_core
#    memory        = var.private_vm_memory
#    core_fraction = var.private_vm_core_fraction
#  }

#  boot_disk {
#    initialize_params {
#      image_id = var.private_vm_image_id
#      size     = var.private_vm_disk_size
#    }
#  }

#  scheduling_policy {
#    preemptible = var.private_scheduling_policy
#  }

#  network_interface {
#    subnet_id = yandex_vpc_subnet.private_subnet.id
#    nat       = false
#  }

#  metadata = {
#    user-data = "${file("/home/leo/kuber-homeworks/3.2/terraform/cloud-init.yaml")}"
# }
#}
