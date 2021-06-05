terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    restapi = {
      source = "fmontezuma/restapi"
    }
  }
}

variable "gandi_key" {}

variable "host_name" {
  default = "westmarchesdelacave"
}

variable "ssh_key_id" {
  default = "def22f15-3be9-4fbc-ae46-49de416bd66a"
}

provider "restapi" {
  uri = "https://api.gandi.net/v5/livedns"
  id_attribute = "rrset_name"
  headers = {
    Authorization = "Apikey ${var.gandi_key}"
  }
}

data "scaleway_account_ssh_key" "ssh" {
  ssh_key_id = var.ssh_key_id
}

resource "scaleway_instance_ip" "public_ip" {}

resource "scaleway_instance_volume" "data" {
  type = "b_ssd"
  size_in_gb = 20
}

resource "scaleway_instance_security_group" "front" {
  inbound_default_policy = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action = "accept"
    port = "22"
  }

  inbound_rule {
    action = "accept"
    port = "80"
  }

  inbound_rule {
    action = "accept"
    port = "443"
  }

  inbound_rule {
    action = "accept"
    port = "30000"
  }
}

resource "scaleway_instance_server" "main" {
  type = "DEV1-S"
  image = "ubuntu_focal"
  ip_id = scaleway_instance_ip.public_ip.id
  tags = ["foundry", "kanka"]
  additional_volume_ids = [scaleway_instance_volume.data.id]
  security_group_id = scaleway_instance_security_group.front.id

  provisioner "local-exec" {
    command = "ansible-playbook -i inventory deploy.yml"
    working_dir = "${path.module}/ansible"

    environment = {
      SCW_VOLUME_ID=element(split("/", scaleway_instance_volume.data.id), 1)
      FOUNDRY_HOSTNAME=var.host_name
      OAUTH_CLIENT=var.host_name
      OAUTH_SECRET=var.host_name
    }
  }
}

resource "restapi_object" "dns_record" {
  path = "/domains/ishtanzar.net/records"
  read_path = "/domains/ishtanzar.net/records/{id}/A"
  data = jsonencode({
    rrset_name = var.host_name
    rrset_type = "A"
    rrset_values = [scaleway_instance_ip.public_ip.address]
    rrset_ttl = 300
  })
}

