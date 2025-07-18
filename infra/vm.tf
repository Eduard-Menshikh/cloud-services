data "yandex_compute_image" "image" {
  family = var.image_family
}

resource "yandex_compute_instance" "vm_1" {
  name     = var.vm_1_name
  hostname = var.vm_1_name
  zone     = var.zone
  platform_id = var.platform_id

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      type     = var.disk_type
      image_id = data.yandex_compute_image.image.id
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id            = yandex_vpc_subnet.infra_subnet_kittygram[0].id
    nat                  = var.nat
    security_group_ids   = [yandex_vpc_security_group.infra_sg.id]
  }

  metadata = {
    serial-port-enable = "1"
    user-data = templatefile("${path.module}/templates/cloud-init.yaml",
      {
        SSH_KEY = var.ssh_key
        USERNAME = var.username
      })
  }
}

output "external_ip" {
  description = "Внешний IP-адрес виртуальной машины"
  value       = yandex_compute_instance.vm_1.network_interface.0.nat_ip_address
}

output "user_data" {
  value = templatefile("${path.module}/templates/cloud-init.yaml", {
    SSH_KEY  = var.ssh_key,
    USERNAME = var.username
  })
}