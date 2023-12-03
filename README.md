Windows gaming VM
=================

This is the backup of my windows 11 gaming VM config - a libvirt+qemu+KVM virtual machine with GPU
and NVME passthrough from the host Fedora 39 OS.

* 18 vCPUs, 24GB RAM
* Bridge networking
* Host windows OS SSD passed through as block device
* Host gaming NVME SSD passed through as PCIE device
* GPU passed through
* Using LookingGlass `kvmfr` kernel module for dmabuf-backed ivshmem
* CPU pinning; vCPUs on host CPUs 0-17
* QEMU CPU threads given realtime (round-robin) priority
* QEMU IO threads given batch priority (on separate CPUs to CPU threads, 18-19)
* Hugepages for memory
* CPU / VM enlightenments (e.g. hyperv) to improve performance
* Defrag host memory before boot
* SystemD service for waking VM up on WOL packets
* Dockerfile and script for building LookingGlass host and client from git source
