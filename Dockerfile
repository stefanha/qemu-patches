# QEMU 'patches' database builder
#
# Periodically fetches the QEMU mailing list archives and qemu.git to generate
# the patches.json database using 'patches scan'. The database files are
# typically exposed by a separate web server process. somewhere so they can be
# downloaded by clients using 'patches fetch'.

FROM fedora:37
RUN dnf -y update && dnf -y install cronie findutils mb2md git notmuch python3-notmuch && dnf clean all
RUN useradd --create-home patches
COPY conf/notmuch-config /home/patches/.notmuch-config
RUN chown patches:patches /home/patches/.notmuch-config
COPY conf/patchesrc /home/patches/.patchesrc
RUN chown patches:patches /home/patches/.patchesrc
COPY update-patches.sh /home/patches/update-patches.sh
RUN chown patches:patches /home/patches/update-patches.sh
COPY conf/crontab /tmp/crontab
RUN crontab -u patches /tmp/crontab && rm /tmp/crontab
COPY run.sh /root/run.sh
VOLUME ["/home/patches/public"]
CMD ["/root/run.sh"]
