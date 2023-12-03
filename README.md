Windows gaming VM
=================

This is the backup of my windows 11 gaming VM config - a libvirt+qemu+KVM virtual machine with GPU
and NVME passthrough from the host Fedora 39 OS.

* 12 vCPUs, 24GB RAM
* Bridge networking
* Host windows OS SSD passed through as block device
* Host gaming NVME SSD passed through as PCIE device
* GPU passed through
* Resizable BAR / Above 4G Decoding support enabled in VM OVMF UEFI/BIOS
* Using LookingGlass `kvmfr` kernel module for dmabuf-backed ivshmem
* CPU pinning; vCPUs on host CPUs 0-5,11-16
* QEMU CPU threads given realtime (round-robin) priority
* QEMU management thread given realtime priority on host CPU 6
* QEMU IO threads given batch priority (on separate CPUs to CPU threads, 7-8)
* Hugepages for memory
* CPU / VM enlightenments (e.g. hyperv) to improve performance
* Defrag host memory before boot
* SystemD service for waking VM up on WOL packets
* Dockerfile and script for building LookingGlass host and client from git source


# References

[1](https://angrysysadmins.tech/index.php/2022/07/grassyloki/vfio-tuning-your-windows-gaming-vm-for-optimal-performance/)
[2](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)

