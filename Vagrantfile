# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "ansible-roles-test"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
    vb.gui = false
  end

  config.vm.network "private_network",
    virtualbox__intnet: "network",
    ip: "10.1.26.23",
    netmask: "255.255.255.0"

  # # set up IP forwarding for wireguard testing
  # config.vm.network "forwarded_port",
  #   guest: 12345,
  #   host: 12345,
  #   host_ip: "127.0.0.1",
  #   protocol: "udp"

  config.vm.provision "shell", path: "prepare-vagrant-provision.sh"

end
