#!bin/bash
 
## Basic installation
=======================================
 
# Get basic packages
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install subversion git-core mercurial keychain openssh-client openssh-server g++ g++-multilib build-essential zip unzip p7zip-full python2.7 python-dev apt-file vim scons qt4-dev-tools libpng12-dev libjpeg8 libjpeg8-dev libpng3 libilmbase-dev libxerces-c-dev libglewmx1.6-dev libxxf86vm-dev libbz2-dev htop zlib1g-dev aptitude dkms gedit-plugins gedit-latex-plugin ntp gnome-terminal gimp gimp-ufraw ufraw ufraw-batch dcraw valgrind linux-tools-common smartmontools libapache2-mod-perl2 gnome-disk-utility libapache2-svn subversion-tools gnome-system-tools unrar xml-twig-tools linux-headers-$(uname -r) rsync inkscape irssi mutt s3cmd meshlab openexr libopenexr-dev openexr-viewers libgnome2-bin gparted ubuntu-restricted-extras uml-utilities gpick gnome-color-manager libfftw3-3 libfftw3-dev libboost1.58-all-dev pkg-config
 
# Preparation for installations
mkdir ~/Downloads
mkdir ~/install_dirs
echo -e 'PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"' | sudo tee -a /etc/environment > /dev/null
source /etc/environment
 
# Install and link eigen
curl -L -o ~/Downloads/eigen-3.2.10.zip http://bitbucket.org/eigen/eigen/get/3.2.10.zip
cd ~/install_dirs/
unzip ~/Downloads/eigen-3.2.10.zip 
mv eigen-eigen-* eigen_3.2.10
sudo chown -R root:root eigen_3.2.10/
sudo mv eigen_3.2.10/ /usr/local/
cd /usr/local/
sudo ln -sf eigen_3.2.10/ eigen
sudo ln -sf eigen_3.2.10/ eigen3
cd /usr/include/
sudo ln -sf /usr/local/eigen eigen3
cd
 
# Download, install, and link MitsubaToFRenderer
cd
git clone git@github.com:cmu-ci-lab/MitsubaToFRenderer.git
cd mitsuba
scons --clean
scons
cd
echo -e 'mitsuba_plugin_dir="/home/sudarshan/MitsubaToFRenderer/dist/plugins"' | sudo tee -a /etc/environment > /dev/null
sudo sed -e '/^PATH/s/"$/:\/home\/sudarshan\/MitsubaToFRenderer\/dist\/plugins"/g' -i /etc/environment
source /etc/environment
echo "/home/sudarshan/mitsuba/dist" | sudo tee /etc/ld.so.conf.d/mitsuba.conf > /dev/null
sudo ldconfig

sudo reboot
# Download the image_utils fole 
git clone https://github.com/igkiou/image_utils/
# Change the paths in gcc.mk, matlab.mk and mex_utils.mk
cd image_utils/file/exr
make  # Run the command make to make the exrread.mex file
# Navigate to mfiles/exr/ folder
cd /MitsubaToFRenderer/mfiles/exr/
# try running the exxr2avi file in it by including the exrread.mex file into the path
# if it does not work and complains that there is a missing symbol then use the following commands
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6:/usr/lib/x86_64-linux-gnu/libprotobuf.so.9
source ~/.bashrc
# At the end of this you should be able to compile a rendering with the following command
mitsuba filename.xml -D decomposition=transient -D tMin=3 -D tMax=10 -D tRes=0.5

  




