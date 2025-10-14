packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "ubuntu_server" {

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  http_directory    = "http"
  http_bind_address = "0.0.0.0"
  http_port_min     = 8803
  http_port_max     = 8803

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end><left><left><left><left>",
    "autoinstall ds=\"nocloud-net;s=http://192.168.88.254:{{ .HTTPPort }}/\"<wait>",
    "<f10><wait>"
  ]
  boot_wait = "10s"

  communicator           = "ssh"
  ssh_username           = "packer"
  ssh_private_key_file   = "~/keys/packer"
  ssh_timeout            = "30m"
  ssh_handshake_attempts = 200


  cpus                 = var.cpu_count
  memory               = var.ram_mb
  disk_size            = var.disk_size_mb
  guest_os_type        = "Linux_64"
  guest_additions_mode = "disable"


  vm_name = var.vm_name


  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--natpf1", "ssh,tcp,,2222,,22"],
    ["modifyvm", "{{.Name}}", "--natpf1", "http,tcp,,8080,,80"]
  ]


  pause_before_connecting = "10s"


  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  shutdown_timeout = "10m"

  headless = false
}

build {
  sources = ["source.virtualbox-iso.ubuntu_server"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install nginx -y",
      "echo '<h1>Built by Packer for Lab 02</h1>' | sudo tee /var/www/html/index.html",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}