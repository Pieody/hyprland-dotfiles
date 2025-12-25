#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Fixed   : Wayland-only (grim + slurp)
## Maintainer fix by ChatGPT

# --------------------------------------------------
# Import Current Theme
# --------------------------------------------------
source "$HOME/.config/rofi/applets/shared/theme.bash"

# Correct theme path
theme="$type/$style"

# --------------------------------------------------
# Theme Elements
# --------------------------------------------------
prompt='Screenshot'
dir="$(xdg-user-dir PICTURES)/Screenshots"
mesg="DIR: $dir"

if [[ "$theme" == *'type-1'* ]]; then
  list_col='1'
  list_row='5'
  win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
  list_col='1'
  list_row='5'
  win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
  list_col='1'
  list_row='5'
  win_width='520px'
else
  list_col='5'
  list_row='1'
  win_width='670px'
fi

# --------------------------------------------------
# Options
# --------------------------------------------------
layout=$(grep 'USE_ICON' "$theme" | cut -d'=' -f2)

if [[ "$layout" == 'NO' ]]; then
  option_1=" Capture Desktop"
  option_2=" Capture Area"
  option_3=" Capture Window"
  option_4=" Capture in 5s"
  option_5=" Capture in 10s"
else
  option_1=""
  option_2=""
  option_3=""
  option_4=""
  option_5=""
fi

# --------------------------------------------------
# Rofi Command
# --------------------------------------------------
rofi_cmd() {
  rofi -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme-str "window { width: $win_width; }" \
    -theme-str "listview { columns: $list_col; lines: $list_row; }" \
    -theme-str 'textbox-prompt-colon { str: ""; }' \
    -theme "$theme"
}

run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# --------------------------------------------------
# Helpers
# --------------------------------------------------
mkdir -p "$dir"
time="$(date +%Y-%m-%d-%H-%M-%S)"
file="Screenshot_$time.png"

close_rofi_delay() {
  sleep 0.35
}

notify() {
  notify-send "screenshot" "$1"
}

copy_shot() {
  wl-copy -t image/png <"$dir/$file"
}

preview() {
  imv "$dir/$file" &
}

countdown() {
  for sec in $(seq "$1" -1 1); do
    notify "Taking screenshot in $sec"
    sleep 1
  done
}

# --------------------------------------------------
# Screenshot Actions (Wayland)
# --------------------------------------------------
shot_desktop() {
  close_rofi_delay
  grim "$dir/$file"
  copy_shot
  notify "Screenshot saved & copied"
  preview
}

shot_area() {
  close_rofi_delay
  grim -g "$(slurp)" "$dir/$file" || exit 1
  copy_shot
  notify "Area captured & copied"
  preview
}

shot_window() {
  close_rofi_delay
  grim -g "$(slurp -r)" "$dir/$file"
  copy_shot
  notify "Window captured & copied"
  preview
}

shot_5s() {
  close_rofi_delay
  countdown 5
  shot_desktop
}

shot_10s() {
  close_rofi_delay
  countdown 10
  shot_desktop
}

# --------------------------------------------------
# Execute
# --------------------------------------------------
chosen="$(run_rofi)"

case "$chosen" in
"$option_1") shot_desktop ;;
"$option_2") shot_area ;;
"$option_3") shot_window ;;
"$option_4") shot_5s ;;
"$option_5") shot_10s ;;
esac
