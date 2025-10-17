packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "rocky" {

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  cd_content = {
  "ks.cfg" = file("${path.root}/kickstart/ks.cfg") }
  cd_label = "PACKERCONFIG"


  boot_command = [
    "<wait7>",
    "e<wait>",
    "<down><down><end>",
    " inst.ks=cdrom:/ks.cfg inst.text",
    "<wait2>",
    "<f10>"
  ]
  boot_wait = "10s"


  communicator           = "ssh"
  ssh_username           = var.ssh_username
  ssh_private_key_file   = var.ssh_private_key_file
  ssh_skip_nat_mapping   = true
  ssh_port               = 2223
  ssh_timeout            = "60m"
  ssh_handshake_attempts = 100


  cpus                 = var.cpu_count
  memory               = var.ram_mb
  disk_size            = var.disk_size_mb
  guest_os_type        = "RedHat_64"
  guest_additions_mode = "disable"


  vm_name  = var.vm_name
  headless = false

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--natpf1", "ssh-{{.Name}},tcp,,2223,,22"],
    ["modifyvm", "{{.Name}}", "--natpf1", "http-{{.Name}},tcp,,8080,,80"]
  ]

  pause_before_connecting = "10s"

  shutdown_command = "sudo -n /usr/bin/systemctl poweroff"
  shutdown_timeout = "10m"

}

build {
  sources = ["source.virtualbox-iso.rocky"]

  provisioner "shell" {
    inline = [
      "sudo firewall-cmd --permanent --zone=public --add-service=http",
      "sudo firewall-cmd --permanent --zone=public --add-service=https",
      "sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp",
      "sudo firewall-cmd --reload"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y epel-release",
      "sudo dnf install -y nginx",
      "echo '<h1>Hi my name is Justin. Welcome to your Packer-built NGINX server!</h1>' | sudo tee /usr/share/nginx/html/index.html",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }

  provisioner "shell" {
    script = "../scripts/install_docker_rocky.sh"
  }

  provisioner "shell" {
    inline = [
      "docker --version || sudo docker --version",
      "docker run --rm hello-world || sudo docker run --rm hello-world"
    ] 
  }
}