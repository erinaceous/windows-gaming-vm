#!/bin/bash
set -x


function free_cpus() {
  systemctl set-property --runtime user.slice AllowedCPUs=0-23
  systemctl set-property --runtime system.slice AllowedCPUs=0-23
  systemctl set-property --runtime init.scope AllowedCPUs=0-23
}


function migrate_processes() {
  (find /proc -maxdepth 1 -type d -name '[0-9]*' | xargs -n1 basename | xargs -n1 taskset -pc '0-23') &
}


function efficient_cpus() {
  governor=$(cat /sys/devices/system/cpu/cpu23/cpufreq/scaling_governor)
  for cpu in 0 1 2 3 4 5 12 13 14 15 16 17; do
    echo ${governor} > /sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_governor
  done
}


function smallpages () {
  echo 0 > /proc/sys/vm/nr_hugepages
  #sysctl vm.nr_hugepages=0
}


function clean_memory() {
  echo 3 > /proc/sys/vm/drop_caches
  echo 1 > /proc/sys/vm/compact_memory
}


function restore_gpu() {
  # Re-Bind GPU to Nvidia Driver
  #echo -n "0000:09:00.0" > /sys/bus/pci/drivers/vfio-pci/unbind
  #echo -n "0000:09:00.1" > /sys/bus/pci/drivers/vfio-pci/unbind
  virsh nodedev-reattach pci_0000_09_00_1
  virsh nodedev-reattach pci_0000_09_00_0
  #nvidia-smi drain -p 0000:09:00.0 -m 0

  # Reload nvidia modules
  #modprobe nvidia
  #modprobe nvidia_modeset
  #modprobe nvidia_drm
  #modprobe nvidia_uvm

  # Rebind VT consoles
  #echo 1 > /sys/class/vtconsole/vtcon0/bind
  #echo 1 > /sys/class/vtconsole/vtcon1/bind

  #nvidia-xconfig --query-gpu-info > /dev/null 2>&1
  #echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

  # Restart Display Manager
  #systemctl restart display-manager.service
}


function restore_nvme() {
  virsh nodedev-reattach pci_0000_01_00_0
}


function restore_audio() {
  echo;  # No-op for now
}


function restore_bluetooth() {
  # systemctl unmask bluetooth
  # systemctl restart bluetooth
  echo # no-op for now
}


function unload_kvmfr() {
  rmmod kvmfr
}


#efficient_cpus
#restore_audio
restore_gpu
restore_nvme
#restore_bluetooth
smallpages
unload_kvmfr
clean_memory
free_cpus
migrate_processes
