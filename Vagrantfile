# -*- mode: ruby -*-
# vi: set ft=ruby :

vms = {
  'Server01' => { 'memory' => '1024', 'cpus' => '1', 'ip' => '201', 'box' => 'debian/bookworm64', 'provision' => 'script_server01.sh' } #,
  #'Client01' => { 'memory' => '1024', 'cpus' => '1', 'ip' => '202', 'box' => 'debian/bookworm64', 'provision' => 'escript_client01.sh' }
}

Vagrant.configure('2') do |config|
    vms.each do |name, conf|
      config.vm.define "#{name}" do |my|
        my.vm.box = conf['box']
        my.vm.hostname = "#{name}.myhome.local"
        my.vm.network 'private_network', ip: "192.168.56.#{conf['ip']}"
        #my.vm.provision 'shell', path: "Provision/#{conf['provision']}"
        my.vm.provider 'virtualbox' do |vb|
          vb.memory = conf['memory']
          vb.cpus = conf['cpus']
          vb.customize ["modifyvm", :id, "--vram", "12"]
        end
      end  
  end
end