resource "yandex_lb_network_load_balancer" "app_balancer" {
  name      = "app-balancer"
  folder_id = var.folder_id

  listener {
    name = "http-listener"
    port = var.port

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp_group.load_balancer.0.target_group_id

    healthcheck {
      name                = "http-check"
      timeout             = var.balancer_timeout
      interval            = var.balancer_interval
      healthy_threshold   = var.healthy_threshold
      unhealthy_threshold = var.unhealthy_threshold

      http_options {
        path = "/"
        port = var.port
      }
    }
  }
}
