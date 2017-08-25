VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  # borrowed from the Discourse vagrant file
  config.vm.provider :virtualbox do |v|
    # This setting gives the VM 2048MB of RAM instead of the default 384.
    v.customize ["modifyvm", :id, "--memory", 2048]
    
    # Who has a single core cpu these days anyways?
    cpu_count = 2
    # Determine the available cores in host system.
    # This mostly helps on linux, but it couldn't hurt on MacOSX.
    if RUBY_PLATFORM =~ /linux/
      cpu_count = `nproc`.to_i
    elsif RUBY_PLATFORM =~ /darwin/
      cpu_count = `sysctl -n hw.ncpu`.to_i
    end
    # Assign additional cores to the guest OS.
    v.customize ["modifyvm", :id, "--cpus", cpu_count]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end
  
  # Adapted from https://gorails.com/guides/using-vagrant-for-rails-development
  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks", "site-cookbooks"]
    chef.add_recipe "apt"
    chef.add_recipe "nodejs"
    chef.add_recipe "ruby_build"
    chef.add_recipe "rbenv::user"
    chef.add_recipe "rbenv::vagrant"
    chef.add_recipe "mysql::server"
    chef.add_recipe "mysql::client"

    chef.json = {
      rbenv: {
        user_installs: [{
          user: 'vagrant',
          rubies: ["2.3.1"],
          global: "2.3.1",
          gems: {
            "2.3.1" => [
              { name: "bundler" }
            ]
          }
        }]
      },
      mysql: {
        server_root_password: 'root'
      }
    }
  end
  config.vm.network :forwarded_port, guest: 3000, host: 3000
end
