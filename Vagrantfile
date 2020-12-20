# -*- mode: ruby -*-
# vim: set ft=ruby :
# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
:inetRouter => {
        :box_name => "centos/7",
        #:public => {:ip => '10.10.10.1', :adapter => 1},
        :net => [
                   {ip: '192.168.255.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"}, # связь с centralRouter
                ]
  },
  :centralRouter => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.255.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"}, # связь с inetRouter
				   {ip: '192.168.254.1', adapter: 4, netmask: "255.255.255.252", virtualbox__intnet: "hw-net"}, # связь с office1Router
				   {ip: '192.168.253.1', adapter: 3, netmask: "255.255.255.252", virtualbox__intnet: "dir-net"}, # связь с office2Router
                  # {ip: '192.168.0.1', adapter: 3, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"}, # этот адрес вручную прописан ниже в ifcfg-eth2:0
                  # {ip: '192.168.0.33', adapter: 4, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"}, # а этот в ifcfg-eth3:0
                   {ip: '192.168.0.65', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "mgt-net"},
                ]
  },
  
  :centralServer => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.0.2', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"},
                   {adapter: 3, auto_config: false, virtualbox__intnet: true},
                   {adapter: 4, auto_config: false, virtualbox__intnet: true},
                ]
  },
   :office1Router => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.2.1', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "office1-dev-net"},
				 #  {ip: '192.168.254.2', adapter: 5, netmask: "255.255.255.252", virtualbox__intnet: "hw-net"}, # связь с centralRouter, прописана ниже вручную в ifcfg-eth4:0
                   {ip: '192.168.2.65', adapter: 3, netmask: "255.255.255.192", virtualbox__intnet: "office1-test-net"},
                   {ip: '192.168.2.129', adapter: 4, netmask: "255.255.255.192", virtualbox__intnet: "managers-net"},
                   {ip: '192.168.2.193', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "hw-net"},
                ]
  },
   :office2Router => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.1.1', adapter: 2, netmask: "255.255.255.128", virtualbox__intnet: "office2-dev-net"},
                   {ip: '192.168.1.129', adapter: 3, netmask: "255.255.255.192", virtualbox__intnet: "office2-test-net"},
                   {ip: '192.168.1.193', adapter: 4, netmask: "255.255.255.192", virtualbox__intnet: "office2-hw-net"},
				   {ip: '192.168.253.2', adapter: 5, netmask: "255.255.255.252", virtualbox__intnet: "dir-net"}, # связь с centralRouter
                ]
  },
  :office1Server => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.2.66', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "office1-test-net"},
                   {adapter: 3, auto_config: false, virtualbox__intnet: true},
                   {adapter: 4, auto_config: false, virtualbox__intnet: true},
                ]
  },
  :office2Server => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.1.130', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "office2-test-net"},
                   {adapter: 3, auto_config: false, virtualbox__intnet: true},
                   {adapter: 4, auto_config: false, virtualbox__intnet: true},
                ]
  },
  
}


class FixGuestAdditions < VagrantVbguest::Installers::Linux
    def install(opts=nil, &block)
        communicate.sudo("yum update kernel -y; yum install -y gcc binutils make perl bzip2 kernel-devel kernel-headers", opts, &block)
        super
    end
end

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|
	config.vbguest.installer = FixGuestAdditions
    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end
        
        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end
		
		 box.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "256"]
          end

        box.vm.provision "shell", path: "prepare.sh" 
        
        case boxname.to_s
        when "inetRouter"
          box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
			sysctl -p /etc/sysctl.conf
            iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
			echo "192.168.0.0/16 via 192.168.255.2 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
			systemctl restart network
            SHELL
        when "centralRouter"
          box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
			sysctl -p /etc/sysctl.conf
            echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
            echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
		    echo "192.168.1.0/24 via 192.168.253.2 dev eth2" > /etc/sysconfig/network-scripts/route-eth2
			echo "192.168.2.0/24 via 192.168.254.2 dev eth3" > /etc/sysconfig/network-scripts/route-eth3
			file=/etc/sysconfig/network-scripts/ifcfg-eth2:0
			cp /etc/sysconfig/network-scripts/ifcfg-eth2 $file
			sed -i 's/eth2/eth2:0/' $file
			sed -i 's/IPADDR=.*/IPADDR=192.168.0.1/' $file
			sed -i 's/NETMASK=.*/NETMASK=255.255.255.240/' $file
			file=/etc/sysconfig/network-scripts/ifcfg-eth3:0
			cp /etc/sysconfig/network-scripts/ifcfg-eth3 $file
			sed -i 's/eth3/eth3:0/' $file
			sed -i 's/IPADDR=.*/IPADDR=192.168.0.33/' $file
			sed -i 's/NETMASK=.*/NETMASK=255.255.255.240/' $file
            systemctl restart network
            SHELL
        when "centralServer"
          box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
            echo "GATEWAY=192.168.0.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1		
            systemctl restart network
            SHELL
		when "office1Router"
			box.vm.provision "shell", run: "always", inline: <<-SHELL
			echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
			sysctl -p /etc/sysctl.conf
			echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 			
			file=/etc/sysconfig/network-scripts/ifcfg-eth4:0
			cp /etc/sysconfig/network-scripts/ifcfg-eth4 $file
			sed -i 's/eth4/eth4:0/' $file
			sed -i 's/IPADDR=.*/IPADDR=192.168.254.2/' $file
			sed -i 's/NETMASK=.*/NETMASK=255.255.255.252/' $file
			echo "GATEWAY=192.168.254.1" >> $file
			systemctl restart network
			SHELL
		when "office2Router"
			box.vm.provision "shell", run: "always", inline: <<-SHELL
			echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
			sysctl -p /etc/sysctl.conf
			echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
			echo "GATEWAY=192.168.253.1" >> /etc/sysconfig/network-scripts/ifcfg-eth4
			systemctl restart network
			SHELL
		when "office1Server"
			box.vm.provision "shell", run: "always", inline: <<-SHELL
			echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
			echo "GATEWAY=192.168.2.65" >> /etc/sysconfig/network-scripts/ifcfg-eth1
			systemctl restart network
			SHELL
		when "office2Server"
			box.vm.provision "shell", run: "always", inline: <<-SHELL
			echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
			echo "GATEWAY=192.168.1.129" >> /etc/sysconfig/network-scripts/ifcfg-eth1
			systemctl restart network
			SHELL
		end

      end

  end
  
  
end