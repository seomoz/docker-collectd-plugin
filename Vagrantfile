install = <<-EOF

# Unassisted install for java
echo debconf shared/accepted-oracle-license-v1-1 select true | \
  sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | \
  sudo debconf-set-selections

# Mesos-Key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

# Docker-Key
sudo apt-key adv \
  --keyserver hkp://ha.pool.sks-keyservers.net:80 \
  --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

# Java Repo
sudo add-apt-repository ppa:webupd8team/java

# Mesos Repo
echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" |
  sudo tee /etc/apt/sources.list.d/mesosphere.list

# Docker Repo
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" |
  sudo tee /etc/apt/sources.list.d/docker.list

# Update
sudo apt-get -y update

# Install packages
sudo apt-get install apt-transport-https ca-certificates
sudo apt-get -y install oracle-java8-installer zookeeper docker-engine mesos marathon collectd python-pip
sudo pip install python-dateutil docker-py

# Master Config
echo '192.168.33.33' > /etc/mesos-master/advertise_ip
touch /etc/mesos-master/no-hostname_lookup

# Slave Config
echo '192.168.33.33' > /etc/mesos-slave/advertise_ip
echo 'docker' > /etc/mesos-slave/containerizers
touch /etc/mesos-slave/no-hostname_lookup

services=(zookeeper docker mesos-master mesos-slave marathon collectd)

# Stop
for svc in ${services[@]}; do
  sudo service $svc stop
done

# Start
for svc in ${services[@]}; do
  sudo service $svc start
  sleep 1
done

EOF

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.network(:private_network, ip: '192.168.33.33')
  config.vm.provision(:shell, inline: install)
end
