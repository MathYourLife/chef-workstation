#
# Cookbook Name:: chef-workstation
# Recipe:: default
#
# Copyright (c) 2015 Dan Couture, All Rights Reserved.

uname = node["chef-workstation"]["user"]
home = ::File.join("/home", node["chef-workstation"]["user"])

node["chef-workstation"]["packages"].each do |p|
  package p
end

include_recipe "apt"
include_recipe "python"

%w{
  .ssh
  notes
}.each do |d|
  directory ::File.join(home, d) do
    owner uname
    group uname
    mode "0700"
  end
end

directory ::File.join(home, ".bashrc.conf") do
  owner uname
  group uname
  mode "0700"
end

# ======== git ========
file ::File.join(home, ".ssh/git_wrapper.sh") do
  owner uname
  group uname
  mode "0700"
  content "#!/bin/sh\nexec /usr/bin/ssh -i #{::File.join(home ,".ssh/id_quaternion_github_rsa")} \"$@\""
end
# exec ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "/home/dcouture/.ssh/id_quaternion_github_rsa" "$@"

# ======== dotfiles ==========
git_mathyourlife = ::File.join(home, "git/mathyourlife")
directory git_mathyourlife do
  owner uname
  group uname
  mode "0700"
end
git ::File.join(git_mathyourlife, "dotfiles") do
  user uname
  group uname
  revision "master"
  repository "git@github.com:MathYourLife/dotfiles.git"
  ssh_wrapper ::File.join(home, ".ssh/git_wrapper.sh")
end
link ::File.join(home, ".bashrc") do
  user uname
  group uname
  to ::File.join(git_mathyourlife, "dotfiles/bashrc/bashrc")
end
%w{
  bash_aliases
  pythonenv
  renv
}.each do |f|
  link ::File.join(home, ".bashrc.conf", f) do
    user uname
    group uname
    to ::File.join(git_mathyourlife, "dotfiles/bashrc", f)
  end
end
link ::File.join(home, ".Rprofile") do
  user uname
  group uname
  to ::File.join(git_mathyourlife, "dotfiles/rstats/Rprofile")
end
bin = ::File.join(home, "bin")
directory bin do
  owner uname
  group uname
  mode "0700"
end
%w{
  epoch
  home-routing
  monitor-reset
  qr
  update-readme-toc
  zoomin
  zoomout
}.each do |f|
  link ::File.join(bin, f) do
    user uname
    group uname
    to ::File.join(git_mathyourlife, "dotfiles/bin", f)
  end
end
link ::File.join(home, ".gitconfig") do
  user uname
  group uname
  to ::File.join(git_mathyourlife, "dotfiles/gitconfig")
end

# =========== sublime ==========
%w{
  Preferences.sublime-settings
  LaTeX.sublime-settings
  Ruby.sublime-settings
  Clojure.sublime-settings
}.each do |f|
  link ::File.join(home, ".config/sublime-text-3/Packages/User", f) do
    user uname
    group uname
    to ::File.join(git_mathyourlife, "dotfiles/sublime", f)
  end
end

# =========== rbenv ==========
sstephenson = ::File.join(home, "git/sstephenson")
directory sstephenson do
  owner uname
  group uname
  mode "0700"
end
git ::File.join(sstephenson, "rbenv") do
  user uname
  group uname
  revision "master"
  repository "https://github.com/sstephenson/rbenv.git"
end
link ::File.join(home, ".rbenv") do
  user uname
  group uname
  to ::File.join(sstephenson, "rbenv")
end
directory ::File.join(home, "git/sstephenson/rbenv/plugins") do
  owner uname
  group uname
  mode "0700"
end
git ::File.join(sstephenson, "ruby-build") do
  user uname
  group uname
  revision "master"
  repository "https://github.com/sstephenson/ruby-build.git"
end
link ::File.join(home, "git/sstephenson/rbenv/plugins/ruby-build") do
  user uname
  group uname
  to ::File.join(sstephenson, "ruby-build")
end


# =========== goglang =============
golang_ver = node["chef-workstation"]["golang"]["version"]
install_dir = ::File.join(home, "go/#{golang_ver}")
directory install_dir do
  owner uname
  group uname
  mode "0700"
  recursive true
end
template ::File.join(home, ".bashrc.conf/golang") do
  source "bashrc/golang"
  user uname
  group uname
  mode "0600"
  variables({
    :goroot => ::File.join(install_dir, "go"),
    :gopath => ::File.join(home, "gocode")
  })
end

remote_file "/tmp/go#{golang_ver}.linux-amd64.tar.gz" do
  source "https://storage.googleapis.com/golang/go#{golang_ver}.linux-amd64.tar.gz"
  not_if { ::File.exist?(::File.join(install_dir, "go/bin/go"))}
  action :create_if_missing
end
execute "install go" do
  command <<-EOF
tar -C #{install_dir} -zxf /tmp/go#{golang_ver}.linux-amd64.tar.gz
chown -R #{uname}:#{uname} #{install_dir}
EOF
  not_if { ::File.exist?(::File.join(install_dir, "go/bin/go"))}
end

# ============ bitly =============
git_bitly = ::File.join(home, "git/bitly")
directory git_bitly do
  owner uname
  group uname
  mode "0700"
end
git ::File.join(git_bitly, "data_hacks") do
  user uname
  group uname
  revision "master"
  repository "https://github.com/bitly/data_hacks.git"
end
%w{
  bar_chart.py
  histogram.py
  ninety_five_percent.py
  run_for.py
  sample.py
}.each do |f|
  link ::File.join(home, "bin", f) do
    user uname
    group uname
    to ::File.join(git_bitly, "data_hacks/data_hacks", f)
  end
end


# =============== data venv =============
venv = ::File.join(home, ".virtualenvs")
directory venv do
  owner uname
  group uname
  mode "0700"
end
python_virtualenv ::File.join(venv, "data") do
  interpreter "python3"
  owner uname
  group uname
  action :create
end
%w{
  ipython
  pyzmq
  jinja2
  tornado
  jsonschema
  mistune
  pygments
  requests
  numpy
  Cython
  beautifulsoup4
  scipy
  mpld3
  scikit-learn
  matplotlib
}.each do |pkg|
  python_pip pkg do
    virtualenv ::File.join(venv, "data")
    action :upgrade
  end
end
git_statsmodels = ::File.join(home, "git/statsmodels")
directory git_statsmodels do
  owner uname
  group uname
  mode "0700"
end
git ::File.join(git_statsmodels, "statsmodels") do
  user uname
  group uname
  revision "master"
  repository "https://github.com/statsmodels/statsmodels.git"
  notifies :run, "execute[install statsmodels]", :immediately
end

execute "install statsmodels" do
  command <<-EOF
#{::File.join(venv, "data")}/bin/pip install -U #{::File.join(git_statsmodels, "statsmodels")}
EOF
  action :nothing
end
