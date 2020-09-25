#!/bin/bash
set -e

# Update our 'patches' source code
(cd patches && git pull)

# Grab the latest qemu.git commits
GIT_DIR=/home/patches/qemu.git git fetch origin

# Fetch qemu-devel mailing list emails into notmuch database
curl --time-cond mbox-2 --remote-time -o mbox-2 https://lists.gnu.org/archive/mbox/qemu-devel/$(date "--date=$(date +%Y-%m-15) -2 months" +%Y-%m)
curl --time-cond mbox-1 --remote-time -o mbox-1 https://lists.gnu.org/archive/mbox/qemu-devel/$(date "--date=$(date +%Y-%m-15) -1 month" +%Y-%m)
curl --time-cond mbox-0 --remote-time -o mbox-0 https://lists.gnu.org/archive/mbox/qemu-devel/$(date +%Y-%m)
rm -rf Maildir
mkdir -p Maildir
mb2md -s mbox-2
mb2md -s mbox-1
mb2md -s mbox-0

# Skip huge emails to limit notmuch memory consumption
find Maildir -size +2M -exec rm {} \;

notmuch new

patches/patches scan

# Upload patches metadata to HTTP server
rsync -ac .patches/public/* qemu-project.org:public
