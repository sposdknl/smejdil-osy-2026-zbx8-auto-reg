Vagrant.configure("2") do |config|
  config.vm.define "freebsd-zabbix" do |vm|
    vm.vm.box = "freebsd/FreeBSD-14.1-STABLE"
    vm.vm.hostname = "freebsd-zabbix"
    vm.vm.network "forwarded_port", guest: 22, host: 2210, host_ip: "127.0.0.1"

    vm.vm.provider "virtualbox" do |vb|
      vb.name = "spos-freebsd-zabbix"
      vb.memory = 1024
      vb.cpus = 1
    end

    vm.vm.provision "shell", path: "install-zabbix7-agent.sh"
    vm.vm.provision "shell", path: "configure-zabbix7-agent.sh"
  end
end
