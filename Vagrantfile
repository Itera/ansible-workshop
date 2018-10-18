Vagrant.configure("2") do |config|
    config.vm.provision :file, source: ".ssh", destination: "/tmp/.ssh"
    config.vm.provision :shell, path: "bootstrap.sh"

    config.vm.define "ansible" do |ansible|
        ansible.vm.box = "centos/7"
        ansible.vm.hostname = "ansible"
        ansible.vm.network :private_network, ip: '10.20.1.10'

        ansible.vm.provision :file, source: "ansible", destination: "/tmp/ansible"
        ansible.vm.provision :shell, path: "ansible.sh"
    end
  
    config.vm.define "web1" do |web1|
        web1.vm.box = "centos/7"
        web1.vm.hostname = "web1"
        web1.vm.network :private_network, ip: '10.20.1.11'
    end
      
    config.vm.define "web2" do |web2|
        web2.vm.box = "centos/7"
        web2.vm.hostname = "web2"
        web2.vm.network :private_network, ip: '10.20.1.12'
    end
        
    config.vm.define "web3" do |web3|
        web3.vm.box = "centos/7"
        web3.vm.hostname = "web3"
        web3.vm.network :private_network, ip: '10.20.1.13'
    end
end