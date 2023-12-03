#!/bin/bash

function docker-build () {
  docker build -t lg-build .
}


function docker-run () {
  docker rm -f lg-build
  docker run \
	  --name lg-build \
	  -it \
	  --user 1000:1000 \
	  --workdir /home/user/lg \
	  -v $PWD:/home/user/lg:z \
	  --entrypoint /home/user/lg/lg-build.sh \
	  lg-build $*
}


function docker-shell () {
  bash
}


function client-build () {
  git pull
  git submodule update --init --recursive
  rm -vrf client/build
  mkdir -p client/build
  cd client/build
  cmake \
	  -DENABLE_LIBDECOR=ON \
	  -DENABLE_X11=1 \
	  -DENABLE_BACKTRACE=0 \
	  -DOPTIMIZE_FOR_NATIVE=ON \
	  ../
  make -j$(nproc)
}


function host-build () {
  git pull
  git submodule update --init --recursive
  docker-run host-build-docker
}


function host-build-docker () {
  rm -vrf host/build
  mkdir -p host/build
  cd host/build
  cmake \
	  -DOPTIMIZE_FOR_NATIVE=ON \
	  -DCMAKE_TOOLCHAIN_FILE=../toolchain-mingw64.cmake ..
  make -j$(nproc)
  curl https://dl.quantum2.xyz/ivshmem.tar.gz | tar xz
  makensis -DIVSHMEM platform/Windows/installer.nsi
}


function client-install () {
  sudo cp -vf client/build/looking-glass-client /usr/local/bin/looking-glass-client
}

function host-install () {
  cp -vf host/build/platform/Windows/looking-glass-host-setup.exe /everything/LookingGlass/
}


if [[ "${1}" = "docker-build" ]]; then
  docker-build
elif [[ "${1}" = "docker-run" ]]; then
  shift
  docker-run ${*}
elif [[ "${1}" = "docker-shell" ]]; then
  shift
  docker-shell ${*}
elif [[ "${1}" = "client-build" ]]; then
  client-build
elif [[ "${1}" = "host-build" ]]; then
  host-build
elif [[ "${1}" = "host-build-docker" ]]; then
  host-build-docker
elif [[ "${1}" = "client-install" ]]; then
  client-install
elif [[ "${1}" = "host-install" ]]; then
  host-install
else
  echo "${0}: Invalid mode - must be (docker-build|docker-run|client-build|host-build|host-build-docker)"
  exit 1
fi
