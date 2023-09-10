#!/bin/bash
################################################################################
#
# v0.1 - initial version
#
# This script allows you to maintain separate icons and backgrounds per desktop
# in Linux Mint 21.2 on either Cinnamon, XFCE or MATE.  
# 
# It is likely that it will work on most other gnome-based environments with
# minimal modification.  (see the platform specific section below)
#
# This script will keep a copy of your original Desktop in $CONFIG/switch-desk/Desktop.bak
# If you try the script and hate it, just run:
#
#       cp -R $CONFIG/switch-desk/Desktop.bak $HOME/Desktop
#       rm -rf $CONFIG/switch-desk
#
# And everytihng will be back to exactly as it was before you used the script.  (you may
# need to reset your background, but no images will be lost).  This will obviously 
# delete any customizations made to your desktop after you started using the script, 
# so use caution and common sense.
#
#  INSTALLATION: 
#    * Download the switch-desk directory
#    * mv /path/to/switch-desk $HOME/.config/  (recommended location - you can change this)
#    * set $CONFIG and $DESKTOP in the config section below
#    * Define custom shortcuts in Mint's Keyboard app.  You likely want:
#       - One per workspace that points to /path/to/switch.sh -n <workspace number>
#         NOTE: ***start from 0***.  Your first workspace is zero, second is 1, and so on.
#       - One that moves one workspace right and points to /path/to/switch.sh -d right
#       - One that moves one workspace left.  You can figure the rest out, right?
#    * (OPTIONAL) make $CONFIG/switch.sh somehow available in your $PATH.  This is 
#      not strictly necessary unless you want to easily call the script directly
#      easiest way is probably:
#
#           sudo ln -s $HOME/.config/switch-desk/switch.sh /usr/local/bin
#           (remember to delete this if you remove switch-desk later)
#
#  USAGE: $PATH/switch.sh [-d <direction>] [-n <number>]
#             -d, --direction  Specify the direction (left or right)
#             -n, --number     Specify a number (integer)
#
#  LIMITATIONS:
#     * This ONLY works via keyboard shortcuts.  If you select a workspace with a mouse,
#       such as via Expo or the workspace panel, it will not work.  This script relies
#       on custom keyboard shortcuts to execute.
#     * It only supports left/right for directional movement.  Up/down may come later.
#     * The background is updated every time you switch workspaces via keyboard shortcut
#       As a result, the backgrounds are not shown in the Expo view.  Only the current
#       background will be shown.
#     * If you're one of those weirdos who keeps your life's entire digital contents
#       on your desktop, first - seek help.  Second, initial startup of the script
#       is going to be slow for you since it cp's stuff around the first time it 
#       interacts with each desktop.  It should get faster after that.  But seriously,
#       stop being weird and store your shit like a normal human being.
#     * "Fast" is a relative term.  There's still a small (<1s) delay each time you
#       switch desktop and you'll see the background image painting.  Such is life. 
#
#  CREDITS:
#     * Thanks to dj1s for the idea and inspiration
#       (https://forums.linuxmint.com/viewtopic.php?f=42&t=360221)
#
################################################################################
# CONFIGURATION
################################################################################
# WM must be Cinnamon, XFCE or MATE
WM="Cinnamon"
#
# it is recommended you store this in $HOME/.config, but you can change it if you like
# NOTE: You must make sure this directory exists.  The script will not create it.
CONFIG="$HOME/.config/switch-desk"
#
# it would be unusual to have to change this
DESKTOP="$HOME/Desktop"
#
######################################################################################

usage() {
    if [[ $- == *i* ]]; then # checks if the script is being run interactively
        echo "Usage: $0 [-d <direction>] [-n <number>]"
        echo "Options:"
        echo "  -d, --direction  Specify the direction (left or right)"
        echo "  -n, --number     Specify a number (integer)"
        exit 1
    fi
}

# make sure the bare necessities are there
if [[ ! -d "$CONFIG" || ! -d "$DESKTOP" ]]; then
    echo "Either CONFIG or DESKTOP variables are not set properly or the directories don't exist."
    usage
fi
if [[ ! "$WM" =~ ^(MATE|XFCE|Cinnamon) ]]; then
    echo "WM is not defined or unsupported."
    usage
fi

if [[ ! -d $CONFIG/backgrounds || ! -d $CONFIG/desktops ]]; then
    mkdir -p $CONFIG/backgrounds $CONFIG/desktops
fi

#set working variables and go through the CLI options
new_workspace=0
current_workspace=$(wmctrl -d | grep '*' | cut -d ' ' -f 1)
total_workspaces=$(wmctrl -d | wc -l)

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -d|--direction)
            if [[ -n "$number" ]] || [[ ! "$2" =~ ^(left|right) ]]; then
                usage
            elif [ "$2" == "left" ] && (( $((current_workspace-1)) >= 0 )); then
                new_workspace=$(( current_workspace-1 ))
            elif [ "$2" == "right" ] && (( $((current_workspace+1)) < $total_workspaces )); then
                new_workspace=$(( current_workspace+1 ))
            else
                new_workspace=$current_workspace
            fi
            shift
            ;;  
        -n|--number)
            number="$2"
            if [[ -n "$direction" || -z "$2" || ! "$2" =~ ^[0-9]+$ || "$2" -lt 0 || "$2" -gt "$total_workspaces" ]]; then
                echo "Invalid value for -n/--number. Please provide a non-negative integer less than or equal to total # of available workspaces"
                usage
            fi
            new_workspace=$2
            shift 
            ;;  
        *)  
            usage
            ;;
    esac
    shift
done

# these are platform specific variables to make this work cross-platform.
# this should theoretically work in any gnome environment with maybe a little tweaking
# to the gsettings commands.  everything else should work without modification
case $WM in
    "XFCE")
        get_bg="" #not used
        set_bg="" #not used
        icons_off="gsettings set org.nemo.desktop desktop-layout 'false::false'"
        icons_on="gsettings set org.nemo.desktop desktop-layout 'true::false'"
        ;;
    "MATE")
        get_bg="gsettings get org.mate.background picture-filename"
        set_bg="gsettings set org.mate.background picture-filename"
        icons_off="gsettings set org.mate.background show-desktop-icons false"
        icons_on="gsettings set org.mate.background show-desktop-icons true"
        ;;
    "Cinnamon")
        get_bg="gsettings get org.cinnamon.desktop.background picture-uri"
        set_bg="gsettings set org.cinnamon.desktop.background picture-uri"
        icons_off="gsettings set org.nemo.desktop desktop-layout 'false::false'"
        icons_on="gsettings set org.nemo.desktop desktop-layout 'true::false'"
        ;;
    *)
        usage
        ;;
esac

function updateBackground {
    if [[ "$WM" != "XFCE" ]] && [[ "$1" == "get_bg" ]]; then  #XFCE alraeady supports per-workspace backgrounds
        # gsettings returns picture-uri in 'file:///picture-uri' format, 
        # so we need to clean that up to something bash can read
        bg=$($get_bg | sed -e "s/^'file:\/\/\(.*\)'$/\1/")

        # if the symlink doesn't exist - create it for the first time.
        # if it exists, check to see if the inodes are the same.  if not, the background was changed.
        # in that case, use the current background and overwrite the old symlink.
        if [[ ! -h ${DESKTOP}/backgrounds/${current_workspace} || "$(stat -c "%i" ${DESKTOP}/backgrounds/${current_workspace} 2>/dev/null)" -ne "$(stat -c "%i" ${bg} 2>/dev/null)" ]]; then
            ln -sfn "${bg}" "${CONFIG}/backgrounds/${current_workspace}"
        fi

        # get the new background. gsettings wants it in the format of file://
        new_bg="file://$(readlink "${CONFIG}/backgrounds/${new_workspace}" | sed "s/'//g")"
    elif [[ "$WM" != "XFCE" ]] && [[ "$1" == "set_bg" ]]; then 
        $set_bg "$new_bg"
    else
        return 0
    fi
}

function updateDesktop {
    local action=$1
    local value=$2
    if [[ "$1" == "first_run" ]]; then 
        cp -R "${DESKTOP}" "${CONFIG}/Desktop.bak" # because we're paranoid
        mv "$DESKTOP" "${CONFIG}/desktops/${2}"
    elif [[ "$1" == "new_desktop" ]]; then 
        cp -RL "${DESKTOP}" "${CONFIG}/desktops/${2}" # -L makes sure we get the real files
    elif [[ "$1" == "set_desktop" ]]; then
        ln -sfn "${CONFIG}/desktops/${2}" "${DESKTOP}"
    else
        exit 1
    fi
}

if [[ -d "$DESKTOP" && ! -h "$DESKTOP" ]]; then # Likely first time script has been run
    updateDesktop "first_run" "${current_workspace}"
fi

# we could streamline this a bit, but we don't, because this catches if someone creates a new workspace out of the blue
# TODO: we don't have any way of cleaning up after ourselves for workspaces long gone
for ((i = 0; i <= $((total_workspaces-1)); i++)); do
    if [[ ! -d "${CONFIG}/desktops/${i}" ]]; then
        updateDesktop "new_desktop" "${i}"
    fi
done

updateBackground "get_bg"

# and...after all that's done...change the window and refresh stuff.
wmctrl -s $new_workspace
updateBackground "set_bg"
updateDesktop "set_desktop" "${new_workspace}"
$icons_off
$icons_on
        
