provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu1804_cloud" {
  name = "ubuntu18.04.qcow2"
  pool = "default"
  source = "/var/lib/libvirt/images/bionic-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "ubuntu1804_resized" {
  name           = "ubuntu-volume-${count.index}"
  base_volume_id = libvirt_volume.ubuntu1804_cloud.id
  pool           = "default"
  size           = 42949672960
  count          = 5
}

resource "libvirt_cloudinit_disk" "cloudinit_ubuntu" {
  name = "cloudinit_ubuntu_resized.iso"
  pool = "default"

  user_data = <<EOF
#cloud-config
disable_root: 0
ssh_pwauth: 1
users:
  - name: ubuntu
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ${file("~/.ssh/sol.key.pub")}
growpart:
  mode: auto
  devices: ['/']
EOF

}

resource "libvirt_network" "kube_network" {
  name = "k8snet"
  mode = "nat"
  domain = "k8s.local"
  addresses = ["10.32.2.0/24"]
  dns {
    enabled = true
  }
}


resource "libvirt_domain" "k8sctl1" {
  name   = "ks8ctl1"
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.cloudinit_ubuntu.id
  
  network_interface {
    network_id     = libvirt_network.kube_network.id
    hostname       = "k8sctl1"
    addresses      = ["10.32.2.91"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.ubuntu1804_resized[0].id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_domain" "k8sctl2" {
  name   = "k8sctl2"
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.cloudinit_ubuntu.id
  
  network_interface {
    network_id     = libvirt_network.kube_network.id
    hostname       = "k8sctl2"
    addresses      = ["10.32.2.92"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.ubuntu1804_resized[3].id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

output "k8sctl1" {
  value = libvirt_domain.k8sctl1.network_interface[0].addresses[0]
}
output "k8sctl2" {
  value = libvirt_domain.k8sctl2.network_interface[0].addresses[0]
}

resource "libvirt_domain" "k8swrk1" {
  name   = "k8swrk1"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.cloudinit_ubuntu.id
  
  network_interface {
    network_id     = libvirt_network.kube_network.id
    hostname       = "k8swrk1"
    addresses      = ["10.32.2.94"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.ubuntu1804_resized[1].id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

output "k8swrk1" {
  value = libvirt_domain.k8swrk1.network_interface[0].addresses[0]
}

resource "libvirt_domain" "k8swrk2" {
  name   = "k8swrk2"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.cloudinit_ubuntu.id
  
  network_interface {
    network_id     = libvirt_network.kube_network.id
    hostname       = "k8swrk2"
    addresses      = ["10.32.2.95"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.ubuntu1804_resized[2].id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

output "k8swrk2" {
  value = libvirt_domain.k8swrk2.network_interface[0].addresses[0]
}

resource "libvirt_domain" "haprx1" {
  name   = "hakrx1"
  memory = "1024"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.cloudinit_ubuntu.id
  
  network_interface {
    network_id     = libvirt_network.kube_network.id
    hostname       = "haprx1"
    addresses      = ["10.32.2.97"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.ubuntu1804_resized[4].id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

output "haprx1" {
  value = libvirt_domain.haprx1.network_interface[0].addresses[0]
}

terraform {
  required_version = ">= 0.12"
}
