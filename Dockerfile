# QEMU 'patches' database builder
#
# Periodically fetches the QEMU mailing list archives and qemu.git to generate
# the patches.json database using 'patches scan'.  The database is then rsynced
# to a web host where it can be downloaded by clients using 'patches fetch'.
#
# How to build:
# 1. Generate an ssh key pair (./id_rsa) in the same directory as the Dockerfile.
# 2. Add the ssh public key to the web host using:
#   $ echo 'command="rsync --server -logDtprce.iLs . /home/patches/public",no-agent-forwarding,no-port-forwarding,no-pty,no-X11-forwarding ...'
#   (where the '...' is the ssh public key)
# 3. Run "docker build ."

FROM fedora:32
RUN dnf -y update && dnf -y install mb2md git notmuch python-notmuch rsync && dnf clean all
RUN useradd --create-home patches
RUN install -d -o patches -g patches -m 0700 /home/patches/.ssh
COPY id_rsa /home/patches/.ssh/id_rsa
RUN chown patches:patches /home/patches/.ssh/id_rsa
COPY conf/known_hosts /home/patches/.ssh/known_hosts
RUN chown patches:patches /home/patches/.ssh/known_hosts
COPY conf/notmuch-config /home/patches/.notmuch-config
RUN chown patches:patches /home/patches/.notmuch-config
COPY conf/patchesrc /home/patches/.patchesrc
RUN chown patches:patches /home/patches/.patchesrc
COPY update-patches.sh /home/patches/update-patches.sh
RUN chown patches:patches /home/patches/update-patches.sh
COPY conf/crontab /tmp/crontab
RUN crontab -u patches /tmp/crontab && rm /tmp/crontab
COPY run.sh /root/run.sh
CMD ["/root/run.sh"]
