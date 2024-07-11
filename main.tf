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
  route_table_id = yandex_vpc_route_table.private_route_table.id
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
    subnet_id = yandex_vpc_subnet.public_subnet.id
    nat       = var.nat
    ip_address = var.nat_primary_v4_address
  }

  metadata = {
    user-data = "${file("/home/leo/clopro-homeworks/cloud-init.yaml")}"
  }
}

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
    subnet_id = yandex_vpc_subnet.public_subnet.id
    nat       = var.nat
  }

  metadata = {
    user-data = "${file("/home/leo/kuber-homeworks/3.2/terraform/cloud-init.yaml")}"
 }
}

resource "yandex_vpc_route_table" "private_route_table" {
  network_id = yandex_vpc_network.my_vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.nat_primary_v4_address
  }
}

resource "yandex_compute_instance" "private_vm" {
  name            = var.private_vm_name
  platform_id     = var.private_vm_platform

  resources {
    cores         = var.private_vm_core
    memory        = var.private_vm_memory
    core_fraction = var.private_vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.private_vm_image_id
      size     = var.private_vm_disk_size
    }
  }

  scheduling_policy {
    preemptible = var.private_scheduling_policy
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_subnet.id
    nat       = false
  }

  metadata = {
    user-data = "${file("/home/leo/kuber-homeworks/3.2/terraform/cloud-init.yaml")}"
 }
}
