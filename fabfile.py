# Copyright Red Hat, Inc. 2014
# Licensed under the GPLv2 or later

from fabric.api import *
from fabric.utils import *
from fabric.contrib.files import *

QEMU_GIT_URI = 'git://git.qemu-project.org/qemu.git'
PATCHES_GIT_URI = 'git://github.com/aliguori/patches.git'
RSYNC_URI = 'your-server:path/to/patches/db'

# Username of an account with sudo access
env.user = 'fedora'

__all__ = ['bootstrap', 'start', 'stop', 'test']

def bootstrap():
    '''Set up the machine for refreshing a patches database'''
    sudo('yum -y update')
    sudo('yum -y install mb2md git notmuch python-notmuch rsync')

    sudo('grep -q ^patches: /etc/passwd || useradd --create-home --shell /sbin/nologin patches')

    put('conf/notmuch-config', '/home/patches/.notmuch-config',
        use_sudo=True, mode=0644)
    sudo('chown patches:patches /home/patches/.notmuch-config')

    put('conf/patchesrc', '/home/patches/.patchesrc',
        use_sudo=True, mode=0644)
    sudo('chown patches:patches /home/patches/.patchesrc')

    upload_template('update-patches.sh.template', '/home/patches/update-patches.sh',
                    use_sudo=True, mode=0755, context={'RSYNC_URI': RSYNC_URI})
    sudo('chown patches:patches /home/patches/update-patches.sh')

    with cd('/home/patches'):
        sudo('test -d qemu.git || git clone --mirror "%s" qemu.git' % QEMU_GIT_URI, user='patches')
        sudo('test -d patches || git clone %s' % PATCHES_GIT_URI, user='patches')

    puts('')
    puts('Please set up a passphrase-less keypair for user \'patches\' with')
    puts('the rsync destination host.  When you are finished, run:')
    puts('  fab ... test')
    puts('')
    puts('If the test succeeds, activate the cronjob by running:')
    puts('  fab ... start')

def start():
    '''Install and activate the cronjob'''
    put('conf/crontab', 'crontab')
    sudo('crontab -u patches crontab')
    run('rm crontab')

def stop():
    '''Deactivate and remove the cronjob'''
    sudo('crontab -u patches -r')

def test():
    '''Invoke the update script to see if it works'''
    with cd('/home/patches'):
        sudo('./update-patches.sh', user='patches')
