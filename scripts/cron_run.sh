#!/bin/bash

# check, if sudo is used
if [[ "$(id -u)" -ne 0 ]]; then
    sudo "/home/ubuntu/retropie-local-binaries/update_retropie.sh"
fi

