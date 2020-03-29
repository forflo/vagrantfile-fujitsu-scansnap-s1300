$provision = <<-SCRIPT
  sudo apt-get update -y
  sudo apt-get install -y \
	libsane-extras \
	sane \
	sane-utils \
    tesseract-ocr \
    tesseract-ocr-{jpn,deu} \
    inotify-tools \
    parallel
    
  # sudo apt-get install -y tesseract-ocr-all

  echo "[Vagrantfile] 1300_0C26.nal"
  sudo mkdir -p /usr/share/sane/epjitsu/
  sudo cp /vagrant/1300_0C26.nal /usr/share/sane/epjitsu/1300_0C26.nal

  echo "[Vagrantfile] Make sure 'scanimage' works without root permissions"
  sudo cp /vagrant/79-udev-fujitsu-1300.rules /etc/udev/rules.d/

  echo "[Vagrantfile] You need to restart you system:"
  echo "[Vagrantfile] $ vagrant halt && vagrant up && vagrant ssh"
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "on"]

    # add the scanner automatically using usb filter
    vb.customize ["usbfilter", "add", "0",
        "--target", :id,
        "--name", "Wildcard Filter for Fujitsu devices",
	"--manufacturer", "FUJITSU"]
  end

  config.vm.provision "shell", inline: $provision, privileged: false 
end
