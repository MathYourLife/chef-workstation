#
# Cookbook Name:: chef-workstation
# Attribute:: default
#
# Copyright (c) 2015 Dan Couture, All Rights Reserved.

default["chef-workstation"]["user"] = "dcouture"
default["chef-workstation"]["packages"] = %w{ git-core meld mercurial htop
  openvpn network-manager-openvpn keepassx openssh-server fail2ban
  mtr-tiny screen curl xclip vim vim-gtk irssi shutter pandoc
  python-statsmodels python3-matplotlib gfortran libblas-dev liblapack-dev
  libatlas-dev protobuf-compiler redshift }

default["chef-workstation"]["golang"] = {
  "version" => "1.4.2"
}
