This script allows you to maintain separate icons and backgrounds per desktop
in Linux Mint 21.2 on either Cinnamon, XFCE or MATE.  

It is likely that it will work on most other gnome-based environments with
minimal modification.  (see the platform specific section of the script)

This script will keep a copy of your original Desktop in $CONFIG/switch-desk/Desktop.bak
If you try the script and hate it, just run:

      cp -R $CONFIG/switch-desk/Desktop.bak $HOME/Desktop
      rm -rf $CONFIG/switch-desk

And everytihng will be back to exactly as it was before you used the script.  (you may
need to reset your background, but no images will be lost).  This will obviously 
delete any customizations made to your desktop after you started using the script, 
so use caution and common sense.

 INSTALLATION: 
   * Clone or otherwise download the switch-desk directory
      - Note: you need the entire directory - not just the script.
   * mv /path/to/switch-desk $HOME/.config/  (recommended location - you can change this)
   * set $CONFIG and $DESKTOP in the config section below
   * Define custom shortcuts in Mint's Keyboard app.  You likely want:
      - One per workspace that points to /path/to/switch.sh -n <workspace number>
        NOTE: ***start from 0***.  Your first workspace is zero, second is 1, and so on.
      - One that moves one workspace right and points to /path/to/switch.sh -d right
      - One that moves one workspace left.  You can figure the rest out, right?
   * (OPTIONAL) make $CONFIG/switch.sh somehow available in your $PATH.  This is 
     not strictly necessary unless you want to easily call the script from the CLI.
     easiest way is probably:

          sudo ln -s $HOME/.config/switch-desk/switch.sh /usr/local/bin
          # (remember to delete this if you remove switch-desk later)

 USAGE: $CONFIG/switch-desk/switch.sh [-d <direction>] [-n <number>]
            -d, --direction  Specify the direction (left or right)
            -n, --number     Specify a number (integer)

 LIMITATIONS:
    * This ONLY works via keyboard shortcuts.  If you select a workspace with a mouse,
      such as via Expo or the workspace panel, it will not work.  This script relies
      on custom keyboard shortcuts to execute.
    * It only supports left/right for directional movement.  Up/down may come later.
    * The background is updated every time you switch workspaces via keyboard shortcut
      As a result, the backgrounds are not shown in the Expo view.  Only the current
      background will be shown.
    * If you're one of those weirdos who keeps your life's entire digital contents
      on your desktop, first - seek help.  Second, initial startup of the script
      is going to be slow for you since it cp's stuff around the first time it 
      interacts with each desktop.  It should get faster after that.  But seriously,
      stop being weird and store your shit like a normal human being.
    * "Fast" is a relative term.  There's still a small (<1s) delay each time you
      switch desktop and you'll see the background image painting.  Such is life. 

 CREDITS:
    * Thanks to dj1s for the idea and inspiration
      (https://forums.linuxmint.com/viewtopic.php?f=42&t=360221)
