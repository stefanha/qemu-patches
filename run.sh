#!/bin/bash

# Populate git repositories on first run
if [ ! -d /home/patches/patches ]; then
	/bin/su - patches -c 'git clone https://github.com/stefanha/patches.git'
fi
if [ ! -d /home/patches/qemu.git ]; then
	/bin/su - patches -c 'git clone --mirror git://git.qemu-project.org/qemu.git'
fi

exec /usr/sbin/crond -n
