# -- mode: ruby --
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install  = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote   = true
  end

   # Haproxy
  config.vm.define :haproxy do |haproxy|
    haproxy.vm.box = "bento/ubuntu-22.04"
    haproxy.vm.network :private_network, ip: "192.168.100.2"
    haproxy.vm.hostname = "haproxy"
    haproxy.vm.provision "shell", path: "script1.sh" 
  end

  # Servidores para el cluster Consul
  # Servidor 1
  config.vm.define :server1 do |server1|
    server1.vm.box = "bento/ubuntu-22.04"
    server1.vm.network :private_network, ip: "192.168.100.3"
    server1.vm.hostname = "server1"
    server1.vm.provision "shell", path: "script2.sh"
  end

  # Servidor 2
  config.vm.define :server2 do |server2|
    server2.vm.box = "bento/ubuntu-22.04"
    server2.vm.network :private_network, ip: "192.168.100.4"
    server2.vm.hostname = "server2"
    server2.vm.provision "shell", path: "script3.sh"
  end
end
