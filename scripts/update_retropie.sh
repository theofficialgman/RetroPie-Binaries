#!/bin/bash

function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}
export -f error

# check, if sudo is used
if [[ "$(id -u)" -ne 0 ]]; then
    echo "Script must be run under sudo from the user you want to install for. Try 'sudo $0'"
    exit 1
fi

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export package_list=( lr-atari800 lr-beetle-ngp lr-beetle-nsp lr-beetle-pce-fast lr-beetle-supergrafx lr-beetle-vb \
lr-beetle-wswan lr-bluemsx lr-bsnes lr-caprice32 lr-desmume lr-fbneo lr-fceumm lr-flycast lr-freeintv lr-fuse \
lr-gambatte lr-genesis-plus-gx lr-gw lr-handy lr-hatari lr-mame lr-mame2003 lr-mame2010 lr-mame2016 lr-mesen \
lr-mgba lr-mupen64plus-next lr-nestopia lr-np2kai lr-o2em lr-opera lr-parallel-n64 lr-pcsx-rearmed lr-picodrive  \
lr-pokemini lr-ppsspp lr-prosystem lr-puae lr-px68k lr-quasi88 lr-quicknes lr-smsplus-gx lr-snes9x \
lr-snes9x2005 lr-snes9x2010 lr-stella2014 lr-superflappybirds  lr-tgbdual lr-theodore lr-tyrquake lr-vba-next \
lr-vecx lr-vice lr-virtualjaguar lr-x1 lr-yabause )

# export package_list=( lr-snes9x )

shopt -s expand_aliases

cd /home/$SUDO_USER/RetroPie-Setup || error "could not change directory"
sudo -E -u "$SUDO_USER" git pull || error "could not pull latest RetroPie-Setup"

# the following for loop is a near copy of the retropie https://github.com/RetroPie/RetroPie-Setup/blob/master/scriptmodules/admin/builder.sh script
# instead of creating binaries for upload to the official retropie server (and signing them with that key), we create binaries to upload to a github repo for download
for package in ${package_list[@]}; do
        cd /home/$SUDO_USER/RetroPie-Setup || error "could not change directory"
        sudo sync
        echo 3 | sudo tee /proc/sys/vm/drop_caches
        __platform=tegra-x1 ./retropie_packages.sh $package depends
        __platform=tegra-x1 ./retropie_packages.sh $package sources
        __platform=tegra-x1 ./retropie_packages.sh $package build
        __platform=tegra-x1 ./retropie_packages.sh $package install || sudo rm -rf "/opt/retropie/libretrocores/$package"
        __platform=tegra-x1 ./retropie_packages.sh $package configure
        cd "/home/$SUDO_USER/retropie-local-binaries" || error "could not change directory"
        sudo -E -u "$SUDO_USER" tar -czvf $package.tar.gz -C /opt/retropie/libretrocores $package
        sudo -E -u "$SUDO_USER" cp "/opt/retropie/libretrocores/$package/retropie.pkg" "$package.pkg"
done

cd "/home/$SUDO_USER/retropie-local-binaries" || error "could not change directory"
sudo -E -u "$SUDO_USER" bash "$SCRIPT_DIR/retropie-binaries-updater.sh" "${package_list[@]}"
echo "dropping caches (freeing ram)"
sync
echo 3 > /proc/sys/vm/drop_caches
