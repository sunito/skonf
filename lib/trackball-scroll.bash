
# http://blog.karssen.org/2010/09/11/linux-the-logitech-trackman-marble-and-emulating-a-scroll-wheel/
# http://www.robmeerman.co.uk/unix/xinput#enabling_emulation_ubuntu_1004

xinput set-int-prop "Logitech USB Trackball" "Evdev Wheel Emulation Button" 8 8                 # 2015-02-15 20:30:10
xinput set-int-prop "Logitech USB Trackball" "Evdev Wheel Emulation" 8 1                # 2015-02-15 20:30:23
xinput set-int-prop "Logitech USB Trackball" "Evdev Middle Button Emulation" 8 1                # 2015-02-15 20:31:25
xinput set-prop "Logitech USB Trackball" "Evdev Wheel Emulation Axes" 6 7 4 5           # 2015-02-15 20:31:36
