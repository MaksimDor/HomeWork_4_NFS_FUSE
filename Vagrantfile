# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"

#  config.vm.provision "ansible" do |ansible|
#    ansible.verbose = "vvv"
#    ansible.playbook = "playbook.yml"
#    ansible.become = "true"
#  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 256
    v.cpus = 1
  end

  config.vm.define "nfss" do |nfss|
    nfss.vm.network "private_network", ip: "192.168.180.10", virtualbox__intnet: "net1"
    nfss.vm.hostname = "server"
    nfss.vm.provision "shell", path: "Server.sh"
  end

  config.vm.define "nfsc" do |nfsc|
    nfsc.vm.network "private_network", ip: "192.168.180.11", virtualbox__intnet: "net1"
    nfsc.vm.hostname = "client"
    nfsc.vm.provision "shell", path: "Client.sh"
  end

end
