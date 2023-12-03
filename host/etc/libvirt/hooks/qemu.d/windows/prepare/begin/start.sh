#!/bin/bash
# Helpful to read output when debugging
set -x


AllowedCPUs="20-23"


function isolate_cpus() {
  systemctl set-property --runtime user.slice AllowedCPUs=${AllowedCPUs}
  systemctl set-property --runtime system.slice AllowedCPUs=${AllowedCPUs}
  systemctl set-property --runtime init.scope AllowedCPUs=${AllowedCPUs}
}


function migrate_processes() {
  (find /proc -maxdepth 1 -type d -name '[0-9]*' | xargs -n1 basename | xargs -n1 taskset -pc "${AllowedCPUs}") &
}


function performance_cpus() {
  for cpu in 0 1 2 3 4 5 12 13 14 15 16 17; do
    echo performance > /sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_governor
    echo $(cat /sys/devices/system/cpu/cpu${cpu}/cpufreq/cpuinfo_max_freq) > /sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_max_freq
  done
}


function clean_memory() {
  echo 3 > /proc/sys/vm/drop_caches
  echo 1 > /proc/sys/vm/compact_memory
}


function hugepages() {
  echo 25 > /proc/sys/vm/nr_hugepages
  #sysctl vm.nr_hugepages=25
}


function passthrough_gpu() {
  # Stop display manager
  #systemctl stop display-manager.service
  #killall gdm-x-session
  #while systemctl is-active --quiet "display-manager.service"; do
  #    sleep 1
  #done

  # Unbind VTconsoles
  #echo 0 > /sys/class/vtconsole/vtcon0/bind
  #echo 0 > /sys/class/vtconsole/vtcon1/bind

  # Unbind EFI-Framebuffer
  #echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

  # Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
  #sleep 2

  # Unload nvidia drivers
  #modprobe -r nvidia_drm
  #modprobe -r nvidia_modeset
  #modprobe -r nvidia_uvm
  #modprobe -r nvidia

  # Unbind the GPU from display driver
  #echo -n "0000:09:00.1" > /sys/bus/pci/drivers/snd_hda_intel/unbind
  #nvidia-smi drain -p 0000:09:00.0 -m 1
  #echo -n "0000:09:00.0" > /sys/bus/pci/drivers/nvidia/unbind
  virsh nodedev-detach pci_0000_09_00_0
  virsh nodedev-detach pci_0000_09_00_1
  #echo -n "0000:09:00.1" > /sys/bus/pci/drivers/vfio-pci/bind
  #echo -n "0000:09:00.0" > /sys/bus/pci/drivers/vfio-pci/bind
}


function passthrough_nvme() {
  virsh nodedev-detach pci_0000_01_00_0
}


function passthrough_audio() {
  echo   # no-op for now
}


function passthrough_bluetooth() {
  # systemctl stop bluetooth
  echo  # no-op for now
}


# Make sure network is autostarted
virsh net-autostart bridged-network


# Load VFIO Kernel Module
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1

# Load kvmfr module
modprobe kvmfr static_size_mb=256


#echo "Passing through bluetooth controller" &&
#passthrough_bluetooth &&

echo "Passing through NVME games SSD" &&
passthrough_nvme &&

#echo "Passing through audio" &&
#passthrough_audio &&

echo "Passing through GPU" &&
passthrough_gpu &&

echo "Isolating CPUs" &&
isolate_cpus &&

#echo "Setting performance CPU governor" &&
#performance_cpus &&

echo "Migrating running processes off of isolated CPUs" &&
migrate_processes &&

echo "Clearing cache and defragmenting memory" &&
clean_memory &&
sleep 2s &&

#echo "Adding 25GB of hugepages" &&
hugepages &&
sleep 4s &&

echo "Booting"
