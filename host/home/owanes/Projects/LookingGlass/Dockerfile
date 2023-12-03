FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:christianrauch/libdecoration
RUN echo 'deb [trusted=yes] https://pipewire-ubuntu.quantum5.workers.dev ./' > /etc/apt/sources.list.d/pipewire.list
RUN apt-get update
RUN apt-get install -y \
          binutils-dev \
          libspice-protocol-dev nettle-dev \
          libgl-dev libgles-dev \
          libx11-dev libxss-dev libxi-dev libxinerama-dev libxcursor-dev libxpresent-dev \
          libwayland-dev libxkbcommon-dev \
          libsamplerate0-dev libpipewire-0.3-dev libpulse-dev \
          libdecor-0-dev libdbus-1-dev clang-tools python3-pip cmake
RUN apt-get install -y gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 nsis curl
RUN pip3 install pyenchant
RUN useradd -m user -G sudo
USER user
WORKDIR /home/user
