#!/bin/bash

set -e

SCRIPT='gcc2'
source $(dirname $0)/settings.sh

setup_system

sources_append 'updates'
sources_append 'bootstrap'
sources_append 'gcc2'

upgrade_system

install_build_dep gcc-4.8

apt-get install -y binutils-or1k-linux-gnu binutils-multiarch
apt-get remove -y libc6-dev-i386

# Just overwrite everything for now
(
  mkdir -p /tmp/unpack
  cd /tmp/unpack
  rm -f *.deb
  apt-get download -y libc6-dev:or1k linux-libc-dev:or1k
  for i in *.deb
  do
    dpkg -x $i /
  done
  rm -f *.deb
)

# Until I get around to find binutils
ln -sf /usr/include/or1k-linux-gnu /usr/or1k-linux-gnu/include
ln -sf /usr/lib/or1k-linux-gnu /usr/or1k-linux-gnu/lib

apt-get source gcc-4.8

# target gcc-4.8
export DEB_BUILD_OPTIONS=nocheck
(cd gcc-4.8-4.8.2 && \
  DEB_TARGET_ARCH=or1k DEB_BUILD_PROFILE=stage2 with_multiarch_lib=yes \
    with_deps_on_target_arch_pkgs=yes dpkg-buildpackage -b -d)
