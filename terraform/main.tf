terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "${var.container_name}_network"
}

resource "docker_image" "app_image" {
  name = var.docker_image
}

resource "docker_container" "app" {
  name  = var.container_name
  image = docker_image.app_image.image_id

  ports {
    internal = 3000
    external = var.app_port
  }

  networks_advanced {
    name = docker_network.app_network.name
  }
}
