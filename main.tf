resource "yandex_vpc_network" "my_vpc" {
  name = var.VPC_name
}

resource "yandex_vpc_subnet" "public_subnet" {
  count = length(var.public_subnet_zones)
  name  = "${var.public_subnet_name}-${var.public_subnet_zones[count.index]}"
  v4_cidr_blocks = [
    cidrsubnet(var.public_v4_cidr_blocks[0], 4, count.index)
  ]
  zone       = var.public_subnet_zones[count.index]
  network_id = yandex_vpc_network.my_vpc.id
}

resource "yandex_compute_instance" "nat_instance" {
  name = var.nat_name

  resources {
    cores  = var.nat_cores
    memory = var.nat_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_disk_image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet[0].id
    nat       = var.nat
    ip_address = var.nat_primary_v4_address
  }
  metadata = {
    user-data = <<-EOF
      #cloud-config
      runcmd:
        - echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
        - sysctl -p
        - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    EOF
  }
}
resource "yandex_vpc_subnet" "private_subnet" {
  count = length(var.private_subnet_zones)
  name  = "${var.private_subnet_name}-${var.private_subnet_zones[count.index]}"
  v4_cidr_blocks = [
    cidrsubnet(var.private_v4_cidr_blocks[0], 4, count.index)
  ]
  zone       = var.private_subnet_zones[count.index]
  network_id = yandex_vpc_network.my_vpc.id
}

resource "yandex_vpc_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Security group for MySQL access"
  network_id  = yandex_vpc_network.my_vpc.id

  ingress {
    protocol      = "tcp"
    from_port     = 3306
    to_port       = 3306
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol      = "tcp"
    from_port     = 0
    to_port       = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_mdb_mysql_cluster" "example" {
  name                = var.cluster_name
  environment         = var.cluster_env
  network_id          = yandex_vpc_network.my_vpc.id
  security_group_ids  = [yandex_vpc_security_group.my_security_group.id]
  version             = var.version_mysql
  deletion_protection = var.deletion_protection

  backup_window_start {
    hours   = var.hours
    minutes = var.minutes
  }

  maintenance_window {
    type = "ANYTIME"
  }

  resources {
    resource_preset_id = var.resource_preset_id
    disk_type_id       = var.disk_type
    disk_size          = var.disk_size
  }

  dynamic "host" {
    for_each = var.private_subnet_zones
    content {
      zone      = host.value
      subnet_id = element(yandex_vpc_subnet.private_subnet[*].id, index(var.private_subnet_zones, host.value))
    }
  }
}

resource "yandex_mdb_mysql_database" "my_database" {
  name       = var.database_name
  cluster_id = yandex_mdb_mysql_cluster.example.id
}

resource "yandex_mdb_mysql_user" "app" {
  cluster_id = yandex_mdb_mysql_cluster.example.id
  name       = var.user_name
  password   = var.user_password
  permission {
    database_name = var.database_name
    roles         = var.user_roles
  }
}

resource "yandex_kms_symmetric_key" "key-a" {
  name              = var.kms_key_name
  description       = var.kms_key_description
  default_algorithm = var.default_algorithm
  lifecycle {
    prevent_destroy = false
  }
}

resource "yandex_iam_service_account" "k8s_service_account" {
  name = var.k8s_service_account_name
}

resource "yandex_iam_service_account_key" "k8s_sa_key" {
  service_account_id = yandex_iam_service_account.k8s_service_account.id
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_service_account" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_service_account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_service_account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_k8s_node" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_service_account.id}"
}

resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name        = var.k8s_cluster_name
  description = "My Kubernetes Cluster"

  network_id               = yandex_vpc_network.my_vpc.id
  service_account_id       = yandex_iam_service_account.k8s_service_account.id
  node_service_account_id  = yandex_iam_service_account.k8s_service_account.id
  master {
    regional {
      region = "ru-central1"  
      location {
        zone = "ru-central1-a"
        subnet_id = yandex_vpc_subnet.public_subnet[0].id
      }
  
      location {
        zone = "ru-central1-b"
        subnet_id = yandex_vpc_subnet.public_subnet[1].id
       }

      location {
        zone = "ru-central1-d"
        subnet_id = yandex_vpc_subnet.public_subnet[2].id
      }
     }     
  
}
 kms_provider {
    key_id = yandex_kms_symmetric_key.key-a.id
  }
 }

resource "yandex_kubernetes_node_group" "k8s_nodes_a" {
  cluster_id = yandex_kubernetes_cluster.k8s_cluster.id
  name       = "${var.k8s_cluster_name}-node-group-a"

  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 4
      cores  = 2
    }
    boot_disk {
      size = 50
      type = "network-ssd"
    }
    network_interface {
      subnet_ids = [yandex_vpc_subnet.public_subnet[0].id]
      nat = true
    }
  }

  scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 3
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }
}

#resource "yandex_kubernetes_node_group" "k8s_nodes_b" {
#  cluster_id = yandex_kubernetes_cluster.k8s_cluster.id
#  name       = "${var.k8s_cluster_name}-node-group-b"

#  instance_template {
#    platform_id = "standard-v1"
#    resources {
#      memory = 4
#      cores  = 2
#    }
#    boot_disk {
#      size = 50
#      type = "network-ssd"
#    }
#    network_interface {
#      subnet_ids = [yandex_vpc_subnet.public_subnet[1].id]
#    }
#  }

#  scale_policy {
#    auto_scale {
#      min     = 1
#      max     = 2
#      initial = 1
#    }
#  }

#  allocation_policy {
#    location {
#      zone = "ru-central1-b"
#    }
#  }
#}

#resource "yandex_kubernetes_node_group" "k8s_nodes_d" {
#  cluster_id = yandex_kubernetes_cluster.k8s_cluster.id
#  name       = "${var.k8s_cluster_name}-node-group-d"

#  instance_template {
#    platform_id = "standard-v1"
#    resources {
#      memory = 4
#      cores  = 2
#    }
#    boot_disk {
#      size = 50
#      type = "network-ssd"
#    }
#    network_interface {
#      subnet_ids = [yandex_vpc_subnet.public_subnet[2].id]
#    }
#  }

#  scale_policy {
#    auto_scale {
#      min     = 1
#      max     = 2
#      initial = 1
#    }
#  }

#  allocation_policy {
#    location {
#      zone = "ru-central1-d"
#    }
#  }
#}


#  allocation_policy {
#    location {
#      zone      = "ru-central1-a"
#      subnet_id = element(yandex_vpc_subnet.public_subnet.*.id, 0)
#    }
#    location {
#      zone      = "ru-central1-b"
#      subnet_id = element(yandex_vpc_subnet.public_subnet.*.id, 1)
#    }
#    location {
#      zone      = "ru-central1-d"
#      subnet_id = element(yandex_vpc_subnet.public_subnet.*.id, 2)
#    }
#  }
#}


resource "yandex_compute_instance" "public_vm" {
  name            = var.public_vm_name
  platform_id     = var.public_vm_platform
  resources {
    cores         = var.public_vm_core
    memory        = var.public_vm_memory
    core_fraction = var.public_vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_vm_image_id
      size     = var.public_vm_disk_size
    }
  }

  scheduling_policy {
    preemptible = var.scheduling_policy
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet[0].id
    nat       = var.nat
  }

  metadata = {
    user-data = "${file("/home/leo/kuber-homeworks/3.2/terraform/cloud-init.yaml")}"
 }
}
