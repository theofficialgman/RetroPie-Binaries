#!/bin/bash

# this script is not intended to be run directly by the user
# the update_retropie.sh script executes this after new emulator binaries and compiled and installed
# each emulator is passed into this script as its own argument
# currently only supports tegra-x1 libretrocores

function error {
  echo -e "\\e[91m$1\\e[39m"
  exit 1
}
export -f error

package_list="$@"

mkdir -p ~/RetroPie-Binaries/Binaries/tegra-x1/libretrocores
cd ~/RetroPie-Binaries || error "could not enter theofficialgman binaries directory"
git pull || error "could not pull latest theofficialgman binaries version"

cd ~/"retropie-local-binaries" || error "could not enter binaries directory"

for package in ${package_list[@]}; do
        new_binary_version=$(cat $package.pkg | grep "pkg_repo_commit" | sed 's/^.*=//' | tr -d '"')
        old_binary_version=$(cat ~/RetroPie-Binaries/Binaries/tegra-x1/libretrocores/$package.pkg | grep "pkg_repo_commit" | sed 's/^.*=//' | tr -d '"')
        if [[ $new_binary_version != $old_binary_version ]] && [[ $new_binary_version != "" ]]; then
                echo "The compiled binary is newer, updating the theofficialgman binaries"
                rm -rf ~/RetroPie-Binaries/Binaries/tegra-x1/libretrocores/$package.pkg
                rm -rf ~/RetroPie-Binaries/Binaries/tegra-x1/libretrocores/$package.tar.gz
                cp $package.pkg ~/RetroPie-Binaries/Binaries/tegra-x1/libretrocores/$package.pkg
                cp $package.tar.gz ~/RetroPie-Binaries/Binaries/tegra-x1/libretrocores/$package.tar.gz
        elif [[ $new_binary_version == "" ]]; then
                echo "WARNING: No new binary was found for $package"

        else
                echo "nothing to be done, version match for $package"
        fi
done
cd ~/RetroPie-Binaries || error "could not enter theofficialgman binaries directory"
now=$(date)
git add .
git commit -m "Retropie cores update - $now"
# read -p "Press any key to resume ..."
git push || error "Push to theofficialgman binaries failed, view log above"
