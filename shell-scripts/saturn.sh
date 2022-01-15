#!/bin/bash

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  param_device="anbernic"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    param_device="oga"
  else
    param_device="rk2020"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  param_device="ogs"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  param_device="rg552"
else
  param_device="chi"
fi

if [[ $1 == "standalone" ]]; then
  directory=$(dirname "$2" | cut -d "/" -f2)
  if [[ ! -d "/$directory/saturn/yabasanshiro" ]]; then
    mkdir /$directory/saturn/yabasanshiro
  fi
  cd /opt/yabasanshiro
  if [[ ! -f "input.cfg" ]]; then
    if [[ -f "keymapv2.json" ]]; then
      rm -f keymapv2.json
    fi
    cp -f /etc/emulationstation/es_input.cfg input.cfg
  fi
  sudo ./oga_controls yabasanshiro $param_device &
  ./yabasanshiro -r 3 -i "$2" -b /$directory/bios/saturn_bios.bin
  if [[ ! -z $(pidof oga_controls) ]]; then
    sudo kill -9 $(pidof oga_controls)
  fi
  sudo systemctl restart oga_events &
  cd ~
elif  [[ $1 == "retroarch" ]]; then
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
elif [[ $1 == "retroarch32" ]]; then
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
elif [[ $1 == "retrorun" ]]; then
  if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
    directory=$(dirname "$3" | cut -d "/" -f2)
    sudo rg351p-js2xbox --silent -t oga_joypad &
    sleep 1
    sudo ln -s /dev/input/event4 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    /usr/bin/retrorun -n -s /$directory/saturn -d /$directory/bios /home/ark/.config/retroarch/cores/"$2"_libretro.so "$3"
    sudo kill $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  else
    /usr/bin/retrorun -n -s /$directory/saturn -d /$directory/bios /home/ark/.config/retroarch/cores/"$2"_libretro.so "$3"
  fi
else
  if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
    directory=$(dirname "$3" | cut -d "/" -f2)
    sudo rg351p-js2xbox --silent -t oga_joypad &
    sleep 1
    sudo ln -s /dev/input/event4 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    /usr/bin/retrorun32 -n -s /$directory/saturn -d /$directory/bios /home/ark/.config/retroarch32/cores/"$2"_libretro.so "$3"
    sudo kill $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  else
    /usr/bin/retrorun32 -n -s /$directory/saturn -d /$directory/bios /home/ark/.config/retroarch/cores/"$2"_libretro.so "$3"
  fi
fi

