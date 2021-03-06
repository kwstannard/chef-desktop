#
# Cookbook Name:: desktop
# Recipe:: bluetooth
#
# Copyright 2015 Andrew Jones
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Installs the Bluetooth stack on Debian/Ubuntu.
#
directory '/lib/firmware' do
  mode 0755
end

directory '/lib/firmware/brcm' do
  mode 0755
end

#
# This proprietary Broadcom firmware is distributed by Plugable systems.
# Most Bluetooth dongles will not work correctly without it.
#
# http://plugable.com/2014/06/23/plugable-usb-bluetooth-adapter-solving-hfphsp-profile-issues-on-linux
#
remote_file '/lib/firmware/brcm/BCM20702A0-0a5c-21e8.hcd' do
  mode 0444
  source 'https://s3.amazonaws.com/plugable/bin/fw-0a5c_21e8.hcd'
  checksum 'd699c13fe1e20c068a8a88dbbed49edc12527b0ceeeaac3411e3298573451536'
  notifies :run, 'execute[btusb-reload]'
end

execute 'btusb-reload' do
  action :nothing
  command '/sbin/modprobe -r btusb; /sbin/modprobe btusb'
end

[
  'blueman',
  'bluetooth',
  'bluez',
  'bluez-tools',
  'obex-data-server',
].compact.each do |package_name|
  package package_name
end

if node['platform']  == 'debian'
  package [
           'bluez-firmware',
           'firmware-atheros',
           'firmware-linux',
           'firmware-linux-nonfree',
          ] do
    action :install
  end
end

